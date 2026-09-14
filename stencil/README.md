Stencil
=======

Working directory for stencil designs — flat plates with shapes or text cut
through them, for painting, marking, etching or icing.

Files
-----

* `stencil.scad` — parametric text stencil. Set the text, plate size and
  thickness, then render and export STL.

Requirements
------------

`stencil.scad` uses `textmetrics()` to measure the text it is about to cut,
which is still an experimental feature: it needs an OpenSCAD development
snapshot, with the feature switched on under Preferences > Features >
textmetrics, or `--enable=textmetrics` on the command line. The release
builds (2021.01) do not have it.

Notes
-----

Stencils print flat on the bed with no supports. A plate 0.8–1.5mm thick is
stiff enough to handle while still letting paint sit close to the surface.

Letters with enclosed counters (A, B, D, O, P, Q, R, 4, 6, 8, 9, 0) leave
loose islands when cut all the way through. `stencil.scad` adds horizontal
bridges across the cutouts to hold those islands in place; adjust
`bridge_count` and `bridge_width` until every island is tied to the plate.
