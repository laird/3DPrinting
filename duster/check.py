#!/usr/bin/env python3
"""Count the connected pieces in an STL.

A stencil plate must be exactly one piece: any second piece is an island
that falls out when the cut is made. Renders a plate with OpenSCAD, or
reads an STL you give it, and reports.

    ./check.py                 every pattern in duster.scad
    ./check.py heart cup       just those
    ./check.py some/file.stl   an STL you already have
"""
import re, subprocess, sys, os, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PATTERNS = ["text", "sunburst", "heart", "star", "cup", "snowflake", "rosetta",
            "tulip", "mandala", "smiley", "bean", "cupcake", "croissant", "maple"]

def pieces(stl):
    """Number of connected components, joining triangles on shared vertices."""
    verts, tris = {}, []
    for tri in re.findall(r"outer loop(.*?)endloop", open(stl).read(), re.S):
        tris.append([verts.setdefault(v, len(verts))
                     for v in re.findall(r"vertex\s+(\S+\s+\S+\s+\S+)", tri)])
    parent = list(range(len(verts)))
    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a
    for a, b, c in tris:
        parent[find(a)] = find(b)
        parent[find(b)] = find(c)
    return len({find(i) for i in range(len(verts))}), len(tris)

def render(pattern):
    out = os.path.join(tempfile.gettempdir(), f"check-{pattern}.stl")
    r = subprocess.run(["xvfb-run", "-a", "openscad-nightly", "-o", out,
                        "-D", 'part="plate"', "-D", f'pattern="{pattern}"',
                        os.path.join(HERE, "duster.scad")],
                       capture_output=True, text=True)
    if r.returncode or not os.path.exists(out):
        sys.exit(f"{pattern}: render failed\n{r.stderr[-800:]}")
    return out

def main(args):
    bad = 0
    for a in args or PATTERNS:
        stl = a if a.endswith(".stl") else render(a)
        n, tris = pieces(stl)
        ok = n == 1
        bad += not ok
        print(f"{'ok  ' if ok else 'FAIL'} {a:<12} {n} piece{'s' if n != 1 else ''}"
              f"{'' if ok else f'  <- {n-1} island(s) will fall out'}   ({tris} triangles)")
    sys.exit(1 if bad else 0)

if __name__ == "__main__":
    main(sys.argv[1:])
