Cinnamon duster
===============

A stencil disk that sits on a mug. Sprinkle cinnamon inside the rim, twirl
the rake a couple of turns by its knob, lift it off.

* `duster.scad` — the thing to print. Two parts, no hardware.
* `concept.scad` — an earlier, more elaborate shutter-driven version, kept
  for the notes on how powder behaves.

Printing
--------

Set `part` to `plate` or `rake` and export each, no supports. The rake
prints as drawn: its teeth stand on the bed and the arms bridge the short
gaps between them. It is loose in use — nothing holds it but the rim, which
keeps it roughly centred while you twirl it.

Set `pattern` to `text` for a message (`layout` puts it in a `line` across
the middle or on an `arc`; `text_size` of 0 fits it to the disk), or to one
of the pictures: `sunburst`, `heart`, `star`, `cup`, `snowflake`,
`rosetta`, `tulip`, `mandala` (`mandala_style` of `snowflake`, `flower` or
`burst`), `smiley`, `bean`, `cupcake`, `croissant`, `maple`. `part` of
`gallery` draws them all.

Two idioms, both inside the powder window:

* **Holes.** The mandalas, tulip and rosetta are built the way commercial
  coffee stencils are: from small isolated holes — dots, teardrops,
  petals, commas, crescents — in solid material. A hole can never enclose
  anything, so nothing can fall out, and a hole a few mm wide passes
  powder however long it is. Rings of holes with n-fold symmetry are the
  whole trick behind the mandalas: `mandala_rings()` is a list of
  `[radius, count, start angle, kind, length, width]`, one row per ring.
  The one rule: holes whose bases meet at the centre must overlap into one
  hole; bases that merely touch fence the centre off.
* **Lines.** The rest are strokes and outlines about 3mm wide. Anything an
  outline closes off is tied back to the plate by gaps.

Drawing your own
----------------

`croissant` and `maple` are drawn as SVG in `art/`, and `pattern` of `svg`
cuts any file you name in `svg_file`. The rules:

* Draw in mm on an 84mm square page (`width="84mm" height="84mm"
  viewBox="0 0 84 84"`) with the disk centre at (42,42), keeping everything
  inside an 80mm circle.
* Draw with strokes, about 3mm wide: never under 1.5 or powder will not
  pass, never over 8 or it pours out on its own.
* Closed shapes are fine: the model cuts `svg_ties` gaps through the
  artwork on radial lines from the centre, so whatever a closed stroke
  encloses stays attached. Lines inside a shape should stop a few mm short
  of its outline, or they fence off regions the gaps do not reach.
* OpenSCAD imports fills only and ignores strokes, so convert first:

      ./stroke2fill.py art/mine.svg      # writes art/mine.fill.svg

  and point `svg_file` at the `.fill.svg`. Edit the stroked original, not
  the generated file.

Then prove it will not fall apart:

    ./check.py maple          # or ./check.py, for every pattern

`check.py` renders the plate and counts the pieces in the result. One piece
is a stencil; two means an island that will drop out of the cut. It caught
the sunburst doing exactly that: its slots overlapped at their inner ends
and fenced off the middle of the disk.

Why it is built this way
------------------------

**No gate under the stencil.** Ground cinnamon is cohesive: over a small
opening it arches instead of flowing. So powder can sit straight on the
stencil and stay there until the rake breaks the arches. That only holds
inside a window of opening sizes — at least about 1.5mm or raking will not
push powder through, at most about 8mm or it pours out on its own. Both
numbers are estimates from how powders behave; a print will settle them.

**Ties.** The bars crossing the letters (rings, for the arc layout) are
spaced from `max_cell`, so no opening is ever taller than the window
allows. They also hold the middles of letters like O in place, and brace
them against the sideways push of the rake.

**No pivot.** An earlier version spun the rake on a post in the middle of
the disk, which cost the middle of the disk: a centred word had its middle
letters cut away, and the text had to run round the post on an arc. Twirling
a loose rake by hand costs nothing, so the artwork can sit where it wants
and the arc is just an option. For the arc, keep `text_size` under about a
third of `arc_r` or the letters crowd into each other at their inner edges.

**Staggered teeth.** A rake spinning about its centre sweeps the rim fast
and the middle barely at all. The second arm is offset by half a tooth
pitch, so the swept spacing is half the pitch on either arm alone, and with
no post in the way the teeth run right in to the centre.
