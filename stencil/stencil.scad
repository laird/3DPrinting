// Parametric text stencil.
// A flat plate with text cut through it, plus bridges so the middles of
// letters like O and A stay attached to the plate.
//
// Needs an OpenSCAD development snapshot with the textmetrics feature
// enabled (Preferences > Features > textmetrics, or --enable=textmetrics
// on the command line).

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

// Exact bounds of the rendered text, so the plate fits whatever the message,
// font and size turn out to be, and the bridges cover the letters as drawn
// (descenders included) rather than an assumed height.
tm = textmetrics(message, size=text_size, font=font, spacing=letter_spacing,
	halign="center", valign="center");

text_w = tm.size[0];
text_h = tm.size[1];
text_cx = tm.position[0] + text_w/2;
text_cy = tm.position[1] + text_h/2;

module message_text() {
	text(message, size=text_size, font=font, spacing=letter_spacing,
		halign="center", valign="center");
	}

module plate() {
	r = min(corner, margin);
	translate([text_cx, text_cy])
		offset(r=r) offset(delta=margin-r)
			square([text_w, text_h], center=true);
	}

// Horizontal bars across the letters, evenly spaced over the text. They only
// ever trim the cutouts, so running them out to the plate edge costs nothing.
module bridges() {
	if (bridge_count > 0) {
		step = text_h / (bridge_count + 1);
		for (i = [1:bridge_count]) {
			translate([text_cx, tm.position[1] + i * step])
				square([text_w + margin*2, bridge_width], center=true);
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
