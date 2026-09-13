// Cinnamon duster: a stencil disk with a rim to hold the powder and a rake
// you spin by hand.
//
// Sit it on the mug, sprinkle cinnamon inside the rim, spin the rake a
// couple of turns, lift it off. Two printed parts, no hardware.
//
// Needs an OpenSCAD development snapshot with textmetrics enabled
// (Preferences > Features > textmetrics, or --enable=textmetrics).

//Which part to draw
part = "assembly"; //[assembly,plate,rake]

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
//Letter height (mm). The pivot sits in the middle of the disk, so the text
//runs round it on an arc rather than across it.
text_size = 13;
//Radius the text runs around (mm)
arc_r = 32;
//Space between letters, 1 is the font default
letter_spacing = 1.15;
//Rings that tie the cutouts together. They cap how tall an opening can get,
//which is what stops powder falling through before it is raked.
bridge_mode = "rings"; //[rings,none]
//Width of each ring (mm)
bridge_width = 1.6;
//No opening may be wider than this or powder pours out unraked (mm)
max_cell = 8;
//Slot width, when pattern is sunburst (mm)
slot_w = 3;
//Number of slots, when pattern is sunburst
slot_count = 24;

/* [Rake] */
//Hub outside diameter (mm)
hub_d = 14;
//Pivot post diameter (mm)
post_d = 5;
//Radial spacing of teeth on one arm; arms are offset by half of this (mm)
tooth_pitch = 6;
//Tooth width (mm)
tooth_w = 1.4;
//Tooth height (mm)
tooth_h = 3;
//Gap between tooth tip and the disk (mm)
tooth_clear = 0.3;
//Finger knob height above the disk (mm)
knob_h = 13;

$fn = 96;

// ---- derived ---------------------------------------------------------
rake_d = disk_d - rim_t*2 - 4;		// sweeps just inside the wall
hub_h = 6;
arm_t = 2;
post_h = disk_t + tooth_clear + hub_h + 1.5;

// Per-character advances, so the letters can be spaced around the arc by
// their real widths instead of an assumed average.
function adv(c) = textmetrics(c, size=text_size, font=font,
	spacing=letter_spacing).advance[0];
function cum(i) = i <= 0 ? 0 : cum(i-1) + adv(message[i-1]);

chars = len(message);
arc_len = cum(chars);
tm = textmetrics(message, size=text_size, font=font, spacing=letter_spacing,
	halign="center", valign="center");
band = tm.size[1];					// radial depth of the lettering

// ---- artwork ---------------------------------------------------------

// Concentric rings subdividing the cutouts, spaced by max_cell so nothing
// is left wide enough for powder to fall through unraked, and nothing is
// left floating once the middles of the letters drop out.
module ties(r_in, r_out) {
	if (bridge_mode == "rings") {
		n = max(0, ceil((r_out - r_in) / max_cell) - 1);
		if (n > 0) for (i = [1:n]) {
			r = r_in + i * (r_out - r_in)/(n+1);
			difference() {
				circle(r = r + bridge_width/2);
				circle(r = r - bridge_width/2);
				}
			}
		}
	}

// Letters set around the arc, each turned to stand upright on it.
module arc_text() {
	for (i = [0:chars-1]) {
		a = (cum(i) + adv(message[i])/2 - arc_len/2) / arc_r * 180 / PI;
		rotate(-a) translate([0, arc_r])
			text(message[i], size=text_size, font=font,
				halign="center", valign="center");
		}
	}

module artwork() {
	intersection() {
		circle(d=art_d);
		difference() {
			if (pattern == "sunburst") {
				for (i = [0:slot_count-1]) rotate(360/slot_count*i)
					translate([art_d/4 + hub_d/4 + 2, 0])
						square([art_d/2 - hub_d/2 - 8, slot_w], center=true);
				}
			else {
				difference() {
					arc_text();
					ties(arc_r - band/2, arc_r + band/2);
					}
				}
			// keep the cuts clear of the pivot
			circle(d=hub_d + 4);
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
			cylinder(d=post_d, h=post_h);	// pivot
			}
		translate([0, 0, -1]) linear_extrude(disk_t + 2) artwork();
		}
	}

// Two arms of teeth, the second offset by half a pitch so the swept
// spacing is half the pitch on either arm. A stub tooth covers the hub.
module rake() {
	difference() {
		union() {
			cylinder(d=hub_d, h=hub_h);
			for (i = [0:1]) rotate(180*i) {
				translate([0, -arm_t/2, tooth_h])
					cube([rake_d/2, arm_t, 2]);
				for (r = [hub_d/2 + 2 + (i % 2) * tooth_pitch/2
						: tooth_pitch : rake_d/2])
					translate([r - tooth_w/2, -arm_t/2, 0])
						cube([tooth_w, arm_t, tooth_h]);
				}
			translate([hub_d/2 - tooth_w, -arm_t/2, 0])
				cube([tooth_w, arm_t, tooth_h]);		// stub tooth
			translate([rake_d/2 - 7, 0, 0])				// finger knob
				cylinder(d=6, h=knob_h);
			}
		translate([0, 0, -1]) cylinder(d=post_d + 0.5, h=hub_h + 2);
		}
	}

// ---- output ----------------------------------------------------------

if (part == "plate") plate();
else if (part == "rake") rake();
else {
	color("Gainsboro") plate();
	color("IndianRed") translate([0, 0, disk_t + tooth_clear]) rake();
	}
