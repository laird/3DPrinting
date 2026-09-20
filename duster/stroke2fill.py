#!/usr/bin/env python3
"""Turn a stroked SVG drawing into filled shapes OpenSCAD can import.

OpenSCAD's SVG import fills every path and ignores strokes, so a stencil
drawn as 3mm lines comes through as filled silhouettes. This lays a filled
rectangle along every segment of every stroked path and a disc at every
vertex (round joins and caps), and writes them to a second file.

    ./stroke2fill.py art/maple.svg          # writes art/maple.fill.svg

Handles <path> with M L H V C S Q A Z (absolute or relative), <line>,
<circle> and <polyline>. Curves are sampled, so the output is polygons.
"""
import math, re, sys, xml.etree.ElementTree as ET

STEPS = 24        # samples per curve or arc
CAP = 20          # sides on each vertex disc

def num(s, d=None):
    try: return float(re.sub(r"[a-z%]+$", "", s.strip()))
    except (ValueError, AttributeError): return d

def stroke_width(el, inherited):
    w = num(el.get("stroke-width"), None)
    style = dict(kv.split(":") for kv in el.get("style", "").split(";") if ":" in kv)
    if "stroke-width" in style: w = num(style["stroke-width"], w)
    return inherited if w is None else w

def cubic(p0, p1, p2, p3):
    return [(((1-t)**3)*p0[0] + 3*((1-t)**2)*t*p1[0] + 3*(1-t)*t*t*p2[0] + t**3*p3[0],
             ((1-t)**3)*p0[1] + 3*((1-t)**2)*t*p1[1] + 3*(1-t)*t*t*p2[1] + t**3*p3[1])
            for t in (i/STEPS for i in range(1, STEPS+1))]

def quad(p0, p1, p2):
    return [(((1-t)**2)*p0[0] + 2*(1-t)*t*p1[0] + t*t*p2[0],
             ((1-t)**2)*p0[1] + 2*(1-t)*t*p1[1] + t*t*p2[1])
            for t in (i/STEPS for i in range(1, STEPS+1))]

def arc(p0, rx, ry, phi, large, sweep, p1):
    # SVG spec F.6.5: endpoint parameterisation to centre parameterisation
    if rx == 0 or ry == 0 or p0 == p1: return [p1]
    phi = math.radians(phi); cp, sp = math.cos(phi), math.sin(phi)
    dx, dy = (p0[0]-p1[0])/2, (p0[1]-p1[1])/2
    x1 = cp*dx + sp*dy; y1 = -sp*dx + cp*dy
    rx, ry = abs(rx), abs(ry)
    lam = (x1/rx)**2 + (y1/ry)**2
    if lam > 1: rx *= math.sqrt(lam); ry *= math.sqrt(lam)
    n = rx*rx*ry*ry - rx*rx*y1*y1 - ry*ry*x1*x1
    d = rx*rx*y1*y1 + ry*ry*x1*x1
    k = math.sqrt(max(0, n/d)) * (-1 if large == sweep else 1)
    cx1, cy1 = k*rx*y1/ry, -k*ry*x1/rx
    cx = cp*cx1 - sp*cy1 + (p0[0]+p1[0])/2
    cy = sp*cx1 + cp*cy1 + (p0[1]+p1[1])/2
    def ang(ux, uy, vx, vy):
        a = math.atan2(ux*vy - uy*vx, ux*vx + uy*vy)
        return a
    t1 = ang(1, 0, (x1-cx1)/rx, (y1-cy1)/ry)
    dt = ang((x1-cx1)/rx, (y1-cy1)/ry, (-x1-cx1)/rx, (-y1-cy1)/ry)
    if not sweep and dt > 0: dt -= 2*math.pi
    if sweep and dt < 0: dt += 2*math.pi
    pts = []
    for i in range(1, STEPS+1):
        t = t1 + dt*i/STEPS
        x, y = rx*math.cos(t), ry*math.sin(t)
        pts.append((cp*x - sp*y + cx, sp*x + cp*y + cy))
    return pts

def parse_path(d):
    """Path data -> list of polylines (one per subpath)."""
    toks = re.findall(r"[MmLlHhVvCcSsQqAaZz]|-?\d*\.?\d+(?:e-?\d+)?", d)
    polys, cur, pos, start, cmd, i = [], [], (0, 0), (0, 0), None, 0
    prev_c = None
    def take(n):
        nonlocal i
        v = [float(t) for t in toks[i:i+n]]; i += n; return v
    while i < len(toks):
        if re.match(r"[A-Za-z]", toks[i]): cmd = toks[i]; i += 1
        rel = cmd.islower(); c = cmd.upper()
        if c == "M":
            x, y = take(2); pos = (pos[0]+x, pos[1]+y) if rel else (x, y)
            if cur: polys.append(cur)
            cur, start = [pos], pos; cmd = "l" if rel else "L"; prev_c = None
        elif c == "Z":
            if cur and cur[0] != cur[-1]: cur.append(start)
            polys.append(cur); cur, pos = [], start; prev_c = None
        elif c == "L":
            x, y = take(2); pos = (pos[0]+x, pos[1]+y) if rel else (x, y); cur.append(pos); prev_c = None
        elif c == "H":
            x, = take(1); pos = (pos[0]+x if rel else x, pos[1]); cur.append(pos); prev_c = None
        elif c == "V":
            y, = take(1); pos = (pos[0], pos[1]+y if rel else y); cur.append(pos); prev_c = None
        elif c in "CS":
            if c == "C": x1, y1, x2, y2, x, y = take(6)
            else:
                x2, y2, x, y = take(4)
                r = (2*pos[0]-prev_c[0], 2*pos[1]-prev_c[1]) if prev_c else pos
                x1, y1 = (r[0]-pos[0], r[1]-pos[1]) if rel else r
            o = pos if rel else (0, 0)
            p1, p2, p3 = (o[0]+x1, o[1]+y1), (o[0]+x2, o[1]+y2), (o[0]+x, o[1]+y)
            cur += cubic(pos, p1, p2, p3); prev_c, pos = p2, p3
        elif c == "Q":
            x1, y1, x, y = take(4); o = pos if rel else (0, 0)
            p1, p2 = (o[0]+x1, o[1]+y1), (o[0]+x, o[1]+y)
            cur += quad(pos, p1, p2); pos = p2; prev_c = None
        elif c == "A":
            rx, ry, phi, large, sweep, x, y = take(7)
            p1 = (pos[0]+x, pos[1]+y) if rel else (x, y)
            cur += arc(pos, rx, ry, phi, int(large), int(sweep), p1); pos = p1; prev_c = None
        else:
            raise SystemExit(f"unsupported path command {cmd}")
    if cur: polys.append(cur)
    return polys

def ribbons(poly, w):
    """Filled polygons covering a stroke of width w along poly."""
    r, out = w/2, []
    for (ax, ay), (bx, by) in zip(poly, poly[1:]):
        dx, dy = bx-ax, by-ay; L = math.hypot(dx, dy)
        if L == 0: continue
        nx, ny = -dy/L*r, dx/L*r
        out.append([(ax+nx, ay+ny), (bx+nx, by+ny), (bx-nx, by-ny), (ax-nx, ay-ny)])
    for x, y in poly:
        out.append([(x + r*math.cos(2*math.pi*k/CAP), y + r*math.sin(2*math.pi*k/CAP)) for k in range(CAP)])
    return out

def shapes(el, inherited_w=None):
    tag = el.tag.split("}")[-1]
    w = stroke_width(el, inherited_w)
    if tag == "path" and w:
        for poly in parse_path(el.get("d", "")): yield from ribbons(poly, w)
    elif tag == "line" and w:
        yield from ribbons([(num(el.get("x1"), 0), num(el.get("y1"), 0)), (num(el.get("x2"), 0), num(el.get("y2"), 0))], w)
    elif tag == "polyline" and w:
        pts = [tuple(map(float, p.split(","))) for p in el.get("points", "").split()]
        yield from ribbons(pts, w)
    elif tag == "circle" and w:
        cx, cy, r = num(el.get("cx"), 0), num(el.get("cy"), 0), num(el.get("r"), 0)
        ring = [(cx + r*math.cos(2*math.pi*k/64), cy + r*math.sin(2*math.pi*k/64)) for k in range(65)]
        yield from ribbons(ring, w)
    for child in el: yield from shapes(child, w)

def main(src):
    root = ET.parse(src).getroot()
    polys = list(shapes(root))
    if not polys: sys.exit(f"{src}: no stroked shapes found")
    out = re.sub(r"\.svg$", ".fill.svg", src)
    keep = {k: root.get(k) for k in ("width", "height", "viewBox") if root.get(k)}
    attrs = " ".join(f'{k}="{v}"' for k, v in keep.items())
    body = "\n".join('  <polygon points="' + " ".join(f"{x:.3f},{y:.3f}" for x, y in p) + '"/>' for p in polys)
    open(out, "w").write(f'<svg xmlns="http://www.w3.org/2000/svg" {attrs}>\n'
                         f'  <!-- generated from {src.split("/")[-1]} by stroke2fill.py; edit that, not this -->\n'
                         f"{body}\n</svg>\n")
    print(f"{out}: {len(polys)} shapes")

if __name__ == "__main__":
    if len(sys.argv) < 2: sys.exit(__doc__)
    for f in sys.argv[1:]: main(f)
