#!/usr/bin/env python3
"""Prove a stencil plate will hold together.

Two tests on each plate, both rendered with OpenSCAD:

  pieces      the STL must be one connected piece; a second piece is an
              island that falls out of the cut.
  connectors  every part of the plate that is only held on by ties must
              hang on at least MIN_TIES of them. Two ties make a hinge, and
              if one breaks the part swings free. Found by rendering the
              plate from above, eroding it until the ties disappear, and
              counting the necks that touch each thick region left over.

    ./check.py                 every pattern in duster.scad
    ./check.py heart cup       just those
    ./check.py some/file.stl   pieces only, for an STL you already have
"""
import os, re, struct, subprocess, sys, tempfile, zlib
from collections import deque

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, "duster.scad")
PATTERNS = ["text", "sunburst", "heart", "star", "cup", "snowflake", "rosetta",
            "tulip", "mandala", "smiley", "bean", "cupcake", "croissant", "maple",
            "lips", "cherry", "peach", "eggplant", "boobs", "butt", "penis", "handcuffs", "kissme"]
MIN_TIES = 3
TIE_MM = 1.0        # erode this far: features under twice it count as ties
MIN_TIE_MM = 1.2    # a tie thinner than this is a sliver, not a tie
MERGE_MM = 1.9      # a seam this wide is not a tie, just the erosion cutoff
DISK_MM = 100       # disk_d, used to scale the image
PX = 900

def scad(out, *defs):
    r = subprocess.run(["xvfb-run", "-a", "openscad-nightly", "-o", out,
                        *sum((["-D", d] for d in defs), []), SCAD],
                       capture_output=True, text=True)
    if r.returncode or not os.path.exists(out):
        sys.exit(f"render failed: {defs}\n{r.stderr[-800:]}")
    return out

# ---- pieces, from the STL --------------------------------------------

def pieces(stl):
    verts, tris = {}, []
    for tri in re.findall(r"outer loop(.*?)endloop", open(stl).read(), re.S):
        tris.append([verts.setdefault(v, len(verts))
                     for v in re.findall(r"vertex\s+(\S+\s+\S+\s+\S+)", tri)])
    parent = list(range(len(verts)))
    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]; a = parent[a]
        return a
    for a, b, c in tris:
        parent[find(a)] = find(b); parent[find(b)] = find(c)
    return len({find(i) for i in range(len(verts))})

# ---- connectors, from a top view -------------------------------------

def read_png(path):
    """Minimal PNG reader: 8-bit RGB/RGBA, non-interlaced. Returns (w, h, rows of (r,g,b))."""
    data = open(path, "rb").read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    pos, idat, w = 8, b"", None
    while pos < len(data):
        n, typ = struct.unpack(">I4s", data[pos:pos+8]); body = data[pos+8:pos+8+n]; pos += 12 + n
        if typ == b"IHDR":
            w, h, depth, ctype, _, _, inter = struct.unpack(">IIBBBBB", body)
            assert depth == 8 and ctype in (2, 6) and inter == 0, "unexpected PNG format"
            bpp = 3 if ctype == 2 else 4
        elif typ == b"IDAT": idat += body
    raw = zlib.decompress(idat); stride = w * bpp
    rows, prev, p = [], bytearray(stride), 0
    for _ in range(h):
        f = raw[p]; line = bytearray(raw[p+1:p+1+stride]); p += 1 + stride
        for i in range(stride):
            a = line[i-bpp] if i >= bpp else 0; b = prev[i]; c = prev[i-bpp] if i >= bpp else 0
            if f == 1: line[i] = (line[i] + a) & 255
            elif f == 2: line[i] = (line[i] + b) & 255
            elif f == 3: line[i] = (line[i] + (a + b)//2) & 255
            elif f == 4:
                q = a + b - c; pa, pb, pc = abs(q-a), abs(q-b), abs(q-c)
                line[i] = (line[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append([tuple(line[i:i+3]) for i in range(0, stride, bpp)]); prev = line
    return w, h, rows

def write_png(path, w, h, px):
    raw = b"".join(b"\x00" + bytes(c for p in px[y*w:(y+1)*w] for c in p) for y in range(h))
    def chunk(t, b): return struct.pack(">I", len(b)) + t + b + struct.pack(">I", zlib.crc32(t + b) & 0xffffffff)
    open(path, "wb").write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
                            + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))

def chamfer(w, h, sources, inside, limit):
    """Euclidean-ish distance from the source pixels through `inside`, capped
    at limit, with the nearest source's label carried along (3-4 chamfer via
    Dijkstra: 1 orthogonal, sqrt 2 diagonal)."""
    import heapq
    INF = limit + 1.0
    dist = [INF]*(w*h); owner = [0]*(w*h); q = []
    for i, k in sources:
        dist[i] = 0.0; owner[i] = k; q.append((0.0, i))
    heapq.heapify(q)
    while q:
        d, i = heapq.heappop(q)
        if d > dist[i] or d >= limit: continue
        x, y = i % w, i // w
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                nx, ny = x+dx, y+dy
                if 0 <= nx < w and 0 <= ny < h:
                    j = ny*w + nx
                    if inside[j]:
                        nd = d + (1.41421356 if dx and dy else 1.0)
                        if nd < dist[j]: dist[j] = nd; owner[j] = owner[i]; heapq.heappush(q, (nd, j))
    return dist, owner

def label(w, h, mask):
    lab, n = [0]*(w*h), 0
    for s in range(w*h):
        if mask[s] and not lab[s]:
            n += 1; lab[s] = n; q = deque([s])
            while q:
                i = q.popleft(); x, y = i % w, i // w
                for dy in (-1, 0, 1):
                    for dx in (-1, 0, 1):
                        nx, ny = x+dx, y+dy
                        if 0 <= nx < w and 0 <= ny < h:
                            j = ny*w + nx
                            if mask[j] and not lab[j]: lab[j] = n; q.append(j)
    return lab, n

def connectors(png):
    w, h, rows = read_png(png)
    bg = rows[0][0]
    mat = [sum(abs(c - b) for c, b in zip(px, bg)) > 60 for row in rows for px in row]
    xs = [i % w for i in range(w*h) if mat[i]]
    px_mm = (max(xs) - min(xs) + 1) / DISK_MM
    r = TIE_MM * px_mm
    # depth into the material from the background; deeper than r survives
    # eroding by r, and is a thick region
    dist, _ = chamfer(w, h, [(i, 1) for i in range(w*h) if not mat[i]], mat, w + h)
    thick = [mat[i] and dist[i] > r for i in range(w*h)]
    lab, n = label(w, h, thick)
    if n == 0: return px_mm, [], 0
    body = max(range(1, n+1), key=lambda k: sum(1 for v in lab if v == k))
    # every bit of material belongs to its nearest thick region; a tie is
    # where two regions' territories meet, and it is as wide as the
    # material is deep along that seam
    _, owner = chamfer(w, h, [(i, lab[i]) for i in range(w*h) if lab[i]], mat, w + h)
    seam = [False]*(w*h)
    for i in range(w*h):
        if not owner[i]: continue
        x, y = i % w, i // w
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                nx, ny = x+dx, y+dy
                if 0 <= nx < w and 0 <= ny < h:
                    j = ny*w + nx
                    if owner[j] and owner[j] != owner[i]: seam[i] = True
    slab, sn = label(w, h, seam)
    touches = [set() for _ in range(sn+1)]
    width = [0.0]*(sn+1)
    for i in range(w*h):
        if slab[i]:
            touches[slab[i]].add(owner[i])
            width[slab[i]] = max(width[slab[i]], 2*dist[i]/px_mm)
    # regions joined by a seam about as wide as the erosion cutoff are one
    # region that erosion happened to nick, not two parts tied together
    parent = list(range(n+1))
    def find(a):
        while parent[a] != a: parent[a] = parent[parent[a]]; a = parent[a]
        return a
    for t in range(1, sn+1):
        if width[t] >= MERGE_MM:
            ks = list(touches[t])
            for k in ks[1:]: parent[find(k)] = find(ks[0])
    body = find(body)
    per = {k: 0 for k in range(1, n+1) if find(k) == k and k != body}
    thin = {k: 0 for k in per}
    seen = set()
    for t in range(1, sn+1):
        ks = {find(k) for k in touches[t]}
        if len(ks) < 2: continue
        for k in ks:
            if k in per:
                if width[t] >= MIN_TIE_MM: per[k] += 1
                else: thin[k] += 1
    if DEBUG:
        colours, img = {}, []
        for i in range(w*h):
            if not mat[i]: img.append((250, 250, 250))
            elif slab[i]: img.append((220, 40, 40) if width[slab[i]] >= MIN_TIE_MM else (255, 160, 0))
            elif not thick[i]: img.append((215, 220, 225))
            elif find(lab[i]) == body: img.append((150, 160, 170))
            else:
                k = find(lab[i])
                colours.setdefault(k, ((k*67) % 200 + 30, (k*131) % 200 + 30, (k*29) % 200 + 30))
                img.append(colours[k])
        write_png(DEBUG, w, h, img)
    return px_mm, sorted(per.values()), sum(thin.values())

def report(name, npieces, ties, thin=0):
    isl = len(ties)
    bad = npieces != 1 or any(t < MIN_TIES for t in ties)
    detail = f"{npieces} piece{'s' if npieces != 1 else ''}"
    if npieces != 1: detail += f", {npieces-1} will fall out"
    detail += f", {isl} tied part{'s' if isl != 1 else ''}"
    if isl: detail += f", fewest ties {min(ties)}" + (f" (<{MIN_TIES})" if min(ties) < MIN_TIES else "")
    if thin: detail += f", {thin} sliver{'s' if thin != 1 else ''} under {MIN_TIE_MM}mm ignored"
    print(f"{'FAIL' if bad else 'ok  '} {name:<12} {detail}")
    return not bad

DEBUG = None

def main(args):
    global DEBUG
    ok = True
    debug = "--debug" in args
    args = [a for a in args if a != "--debug"]
    for a in args or PATTERNS:
        if a.endswith(".stl"):
            ok &= report(a, pieces(a), []); continue
        tmp = tempfile.gettempdir()
        stl = scad(os.path.join(tmp, f"check-{a}.stl"), 'part="plate"', f'pattern="{a}"')
        png = os.path.join(tmp, f"check-{a}.png")
        subprocess.run(["xvfb-run", "-a", "openscad-nightly", "-o", png, f"--imgsize={PX},{PX}",
                        "--projection=o", "--camera=0,0,0,0,0,0,290", "-D", 'part="plate"',
                        "-D", f'pattern="{a}"', SCAD], capture_output=True)
        DEBUG = os.path.join(tmp, f"check-{a}-debug.png") if debug else None
        _, ties, thin = connectors(png)
        ok &= report(a, pieces(stl), ties, thin)
        if debug: print(f"     debug image: {DEBUG}")
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main(sys.argv[1:])
