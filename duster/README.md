Cinnamon duster
===============

A rake-over-stencil powder duster: powder sits on a stencil card, pressing
the shutter spins a toothed rake across the card, and the rake pushes
cinnamon through the openings onto the drink below.

`concept.scad` is a first-pass concept, not a print-ready part. Set `view`
to `section`, `assembly`, `exploded`, `rake` or `card` to draw it.

Why there is no gate under the card
-----------------------------------

Ground cinnamon is cohesive: over a small opening it arches instead of
flowing, so the card can be the chamber floor with nothing beneath it. The
rake is what breaks the arches. That only holds inside a window of opening
sizes:

* at least ~1.5mm, or raking will not push powder through
* at most ~8mm, or it pours out before you press

Both numbers are estimates from powder behaviour, and finding the real ones
for a given cinnamon is what the first prototype is for.

Consequences for the cards
--------------------------

Cards are Polaroid format, 88 x 106.5mm, 1.0mm thick, with the deep bottom
border as the caption strip and the grip you pull them by. The chamber bore
is round, so artwork has to stay inside a 76mm circle even though the card
window is square.

Bridges in a card now do three jobs: hold the middles of letters in, brace
those islands against the sideways load of the rake, and divide any wide
opening into cells small enough to still arch.
