Cinnamon duster
===============

A stencil disk that sits on a mug. Sprinkle cinnamon inside the rim, spin
the rake a couple of turns, lift it off.

* `duster.scad` — the thing to print. Two parts, no hardware.
* `concept.scad` — an earlier, more elaborate shutter-driven version, kept
  for the notes on how powder behaves.

Printing
--------

Set `part` to `plate` or `rake` and export each. Both print flat on the bed
with no supports; the rake drops onto the pivot post and is only held by
gravity, so it lifts straight off for washing.

Set `pattern` to `text` for a message or `sunburst` for radial slots.

    openscad-nightly -D 'part="plate"' -o plate.stl duster.scad
    openscad-nightly -D 'part="rake"'  -o rake.stl  duster.scad

Needs a development snapshot with `textmetrics` enabled, as `stencil.scad`
does — it measures each letter to space them around the arc.

Why it is built this way
------------------------

**No gate under the stencil.** Ground cinnamon is cohesive: over a small
opening it arches instead of flowing. So powder can sit straight on the
stencil and stay there until the rake breaks the arches. That only holds
inside a window of opening sizes — at least about 1.5mm or raking will not
push powder through, at most about 8mm or it pours out on its own. Both
numbers are estimates from how powders behave; a print will settle them.

**Tie rings, not just bridges.** The concentric rings crossing the letters
are spaced from `max_cell`, so no opening is ever taller than the window
allows. They also hold the middles of letters like O in place, and brace
them against the sideways push of the rake.

**Text runs around the arc.** The rake pivots on a post at the centre, so
the middle of the disk cannot carry artwork — a centred word would have its
middle letters cut away by the pivot. The lettering runs around the pivot
instead. Keep `text_size` under about a third of `arc_r` or the letters
crowd into each other at their inner edges.

**Staggered teeth.** A rake spinning about its centre sweeps the rim fast
and the middle barely at all. The second arm is offset by half a tooth
pitch, so the swept spacing is half the pitch on either arm alone, and a
stub tooth covers the hub.
