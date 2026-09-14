// Cinnamon duster: a stencil disk with a rim to hold the powder and a rake
// you spin by hand.
//
// Sit it on the mug, sprinkle cinnamon inside the rim, twirl the rake a
// couple of turns by its knob, lift it off. Two printed parts, no hardware.
// The rake is loose — the rim keeps it roughly centred.
//
// Needs an OpenSCAD development snapshot with textmetrics enabled
// (Preferences > Features > textmetrics, or --enable=textmetrics).

//Which part to draw
part = "assembly"; //[assembly,plate,rake]

//Teeth break the powder up and meter it through; a flat blade squeegees
//everything across the stencil in one sweep
rake_style = "teeth"; //[teeth,flat]

//What to cut through the disk
pattern = "text"; //[text,sunburst]

/* [Plate] */
//Disk diameter, sized to sit on a mug rim (mm)
disk_d = 100;
//Disk thickness (mm)
disk_t = 1.5;
//Wall around the edge that keeps the cinnamon in (mm)
rim_h = 10;
//Wall thickness (mm)
rim_t = 2;
//Diameter the artwork has to stay inside (mm)
art_d = 84;

/* [Artwork] */
//Text to cut, when pattern is text
message = "HELLO";
//Font
font = "Liberation Sans:style=Bold";
//Straight across the middle, or around an arc
layout = "line"; //[line,arc]
//Letter height (mm), 0 fits the text to the disk
text_size = 0;
//Radius the text runs around, for the arc layout (mm)
arc_r = 32;
//Space between letters, 1 is the font default
letter_spacing = 1.1;
//Bars tying the cutouts together: straight for line text, rings for arc
bridges = true;
//Width of each bar (mm)
bridge_width = 1.6;
//No opening may be taller than this or powder pours out unraked (mm)
max_cell = 8;
//Slot width, when pattern is sunburst (mm)
slot_w = 3;
//Number of slots, when pattern is sunburst
slot_count = 24;
//Radius the sunburst slots start from (mm)
slot_inner = 8;

/* [Rake] */
//Knob you twirl it by: diameter and height above the disk (mm)
knob_d = 14;
knob_h = 18;
//Radial spacing of teeth on one arm; arms are offset by half of this (mm)
tooth_pitch = 6;
//Tooth width, along the arm (mm)
tooth_w = 2;
//Tooth height (mm)
tooth_h = 3;
//Arm width and height (mm)
arm_w = 2.5;
arm_h = 3;

$fn = 96;

// ---- derived ---------------------------------------------------------
rake_d = disk_d - rim_t*2 - 4;		// swings just inside the wall

// Measured at a reference size, then scaled so the text's bounding box
// just fits inside the artwork circle (the diagonal is the limit).
tm0 = textmetrics(message, size=10, font=font, spacing=letter_spacing,
	halign="center", valign="center");
fit_size = 10 * 0.95 * art_d / norm(tm0.size);
size = text_size > 0 ? text_size
	: layout == "arc" ? arc_r / 2.5 : fit_size;
tm = textmetrics(message, size=size, font=font, spacing=letter_spacing,
	halign="center", valign="center");

// Per-character advances, for spacing letters around the arc by their real
// widths instead of an assumed average.
function adv(c) = textmetrics(c, size=size, font=font,
	spacing=letter_spacing).advance[0];
function cum(i) = i <= 0 ? 0 : cum(i-1) + adv(message[i-1]);
chars = len(message);
arc_len = cum(chars);

// ---- artwork ---------------------------------------------------------

// Bars subdividing the cutouts, spaced from max_cell so no opening is left
// tall enough for powder to fall through unraked, and nothing is left
// floating once the middles of the letters drop out.
module line_ties() {
	h = tm.size[1];
	n = max(0, ceil(h / max_cell) - 1);
	if (n > 0) for (i = [1:n])
		translate([tm.position[0] + tm.size[0]/2,
				tm.position[1] + i * h/(n+1)])
			square([tm.size[0] + 10, bridge_width], center=true);
	}

module ring_ties() {
	h = tm.size[1];
	n = max(0, ceil(h / max_cell) - 1);
	if (n > 0) for (i = [1:n]) {
		r = arc_r - h/2 + i * h/(n+1);
		difference() {
			circle(r = r + bridge_width/2);
			circle(r = r - bridge_width/2);
			}
		}
	}

module line_text() {
	text(message, size=size, font=font, spacing=letter_spacing,
		halign="center", valign="center");
	}

// Letters set around the arc, each turned to stand upright on it.
module arc_text() {
	for (i = [0:chars-1]) {
		a = (cum(i) + adv(message[i])/2 - arc_len/2) / arc_r * 180 / PI;
		rotate(-a) translate([0, arc_r])
			text(message[i], size=size, font=font,
				halign="center", valign="center");
		}
	}

module artwork() {
	intersection() {
		circle(d=art_d);
		if (pattern == "sunburst") {
			for (i = [0:slot_count-1]) rotate(360/slot_count*i)
				translate([slot_inner, -slot_w/2])
					square([art_d/2 - slot_inner, slot_w]);
			}
		else if (layout == "arc") difference() {
			arc_text();
			if (bridges) ring_ties();
			}
		else difference() {
			line_text();
			if (bridges) line_ties();
			}
		}
	}

// ---- parts -----------------------------------------------------------

module plate() {
	difference() {
		union() {
			cylinder(d=disk_d, h=disk_t);
			difference() {					// rim
				cylinder(d=disk_d, h=rim_h);
				translate([0, 0, -1])
					cylinder(d=disk_d - rim_t*2, h=rim_h + 2);
				}
			}
		translate([0, 0, -1]) linear_extrude(disk_t + 2) artwork();
		}
	}

// Two arms under a knob. Toothed: the second arm's teeth are offset by half
// a pitch, so the swept spacing is half the pitch on either arm alone, and
// with no pivot in the way the teeth run right in to the centre. Flat: each
// arm is a full-depth blade, so one sweep pushes everything ahead of it.
//
// Both print as drawn. The toothed rake stands on its teeth and the arms
// bridge the short gaps between them; the flat one stands on its edge.
module rake() {
	translate([0, 0, tooth_h]) cylinder(d=knob_d, h=knob_h - tooth_h);
	for (i = [0:1]) rotate(180*i) {
		if (rake_style == "flat")
			translate([0, -arm_w/2, 0]) cube([rake_d/2, arm_w, tooth_h + arm_h]);
		else {
			translate([0, -arm_w/2, tooth_h]) cube([rake_d/2, arm_w, arm_h]);
			for (r = [tooth_pitch/2 * (1 + i) : tooth_pitch : rake_d/2])
				translate([r - tooth_w/2, -arm_w/2, 0])
					cube([tooth_w, arm_w, tooth_h]);
			}
		}
	}

// ---- output ----------------------------------------------------------

if (part == "plate") plate();
else if (part == "rake") rake();
else {
	color("Gainsboro") plate();
	color("IndianRed") translate([0, 0, disk_t + 0.3]) rake();
	}
