// Parametric text stencil.
// A flat plate with text cut through it, plus bridges so the middles of
// letters like O and A stay attached to the plate.

//Text to cut out of the plate
message = "STENCIL";

//Font (as named in OpenSCAD's font list)
font = "Liberation Sans:style=Bold";

//Letter height (mm)
text_size = 20;

//Space between letters, 1 is the font default
letter_spacing = 1.1;

//Plate thickness (mm)
thick = 1.2;

//Border of plate around the text (mm)
margin = 8;

//Number of bridges across the text, 0 for none
bridge_count = 2; //[0:5]

//Width of each bridge (mm)
bridge_width = 1.6;

//Corner rounding of the plate (mm), 0 for square corners
corner = 4;

$fn = 32;

module message_text() {
	text(message, size=text_size, font=font, spacing=letter_spacing,
		halign="center", valign="center");
	}

// OpenSCAD cannot measure text, so the plate is built out from the text
// itself: smear the letters sideways and up, and the two overlap exactly on
// the box that contains them.
module text_box() {
	big = text_size * len(message) * 4;
	eps = 0.01;
	intersection() {
		minkowski() {
			hull() message_text();
			square([big, eps], center=true);
			}
		minkowski() {
			hull() message_text();
			square([eps, big], center=true);
			}
		}
	}

// Plate: the text box grown by the margin, with rounded corners. Grown from
// the text, so it always fits whatever the message and font turn out to be.
module plate() {
	r = min(corner, margin);
	offset(r=r) offset(delta=margin-r) text_box();
	}

// Horizontal bars across the letters, evenly spaced over the letter height.
// They are only ever used to trim the cutouts, so running them well past
// the ends of the text costs nothing.
module bridges() {
	if (bridge_count > 0) {
		span = text_size * len(message) * 2;
		step = text_size / (bridge_count + 1);
		for (i = [1:bridge_count]) {
			translate([0, -text_size/2 + i * step])
				square([span, bridge_width], center=true);
			}
		}
	}

linear_extrude(height=thick)
	difference() {
		plate();
		difference() {
			message_text();
			bridges();
			}
		}
