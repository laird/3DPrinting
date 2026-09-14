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

Set `pattern` to `text` for a message or `sunburst` for radial slots, and
`layout` to `line` (straight across the middle) or `arc` (around the disk).
`text_size` of 0 fits the message to the disk.

`rake_style` picks `teeth`, which break the powder up and meter it through
a little at a time, or `flat`, a plain blade that squeegees everything
across the stencil in one sweep. Print both and see which you reach for.

    openscad-nightly -D 'part="plate"' -o plate.stl duster.scad
    openscad-nightly -D 'part="rake"'  -o rake.stl  duster.scad

Needs a development snapshot with `textmetrics` enabled, as `stencil.scad`
does — it measures the text to fit it, and each letter to space them round
the arc.

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
