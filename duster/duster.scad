// Cinnamon duster: a stencil disk with a rim to hold the powder and a rake
// you spin by hand.
//
// Sit it on the mug, sprinkle cinnamon inside the rim, twirl the rake a
// couple of turns by its knob, lift it off. Two printed parts, no hardware.
// The rake is loose — the rim keeps it roughly centred.
//
// Needs an OpenSCAD development snapshot with textmetrics enabled
// (Preferences > Features > textmetrics, or --enable=textmetrics).

//Which part to draw; gallery lays out a plate of every pattern
part = "assembly"; //[assembly,plate,rake,gallery]

//Teeth break the powder up and meter it through; a flat blade squeegees
//everything across the stencil in one sweep
rake_style = "teeth"; //[teeth,flat]

//What to cut through the disk
pattern = "text"; //[text,sunburst,heart,star,cup,snowflake,rosetta,tulip,mandala,smiley,bean,cupcake,croissant,maple,svg]

//Which mandala, when pattern is mandala
mandala_style = "snowflake"; //[snowflake,flower,burst]

//Your own artwork, when pattern is svg. Draw it as strokes about 3mm wide
//and run it through stroke2fill.py first; OpenSCAD only imports fills.
//See art/ for examples and the README for the rules.
svg_file = "art/maple.fill.svg";
//Tie gaps cut through it, evenly spaced around the centre
svg_ties = 4;

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
//Radius the sunburst slots start from, or further out if they would touch (mm)
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
// At least two, so the middle of every letter hangs on four ties, not two.
module line_ties() {
	h = tm.size[1];
	n = max(2, ceil(h / max_cell) - 1);
	if (n > 0) for (i = [1:n])
		translate([tm.position[0] + tm.size[0]/2,
				tm.position[1] + i * h/(n+1)])
			square([tm.size[0] + 10, bridge_width], center=true);
	}

module ring_ties() {
	h = tm.size[1];
	n = max(2, ceil(h / max_cell) - 1);
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

// ---- holes -----------------------------------------------------------
// The commercial stencils are built almost entirely from small isolated
// holes rather than lines: a hole can never enclose anything, so nothing
// can fall out, and a hole a few mm across sits inside the powder window
// however long it is. These are the shapes they use. Each points along +X
// from the origin, so ring() can aim it outward.

module dot(d) circle(d=d);

// Teardrop: round at the origin, tapering to a point at L.
module drop(L, w) hull() { circle(d=w); translate([L - 0.6, 0]) circle(d=1.2); }

// Petal: pointed at both ends, w wide in the middle, from 0 to L.
module lens(L, w) {
	R = w/4 + L*L/(4*w);
	c = R - w/2;
	intersection() {
		translate([L/2, c]) circle(R);
		translate([L/2, -c]) circle(R);
		}
	}

// Comma: a teardrop bent through `bend` degrees, curving toward -Y.
module comma(L, w, bend = 70) {
	R = L / (bend * PI / 180);
	K = 8;
	for (k = [0:K-1]) hull() for (j = [k, k+1]) {
		a = bend * j / K;
		translate([R*sin(a), -(R - R*cos(a))])
			circle(d = max(1.2, w * (1 - j/K)));
		}
	}

// Crescent: t thick at the bottom, horns up, R across.
module crescent(R, t) difference() { circle(R); translate([0, t]) circle(R); }

// Part of a ring, from angle a1 to a2, w wide.
module ring_arc(r, a1, a2, w = slot_w) {
	intersection() {
		difference() { circle(r + w/2); circle(r - w/2); }
		polygon(concat([[0, 0]],
			[for (a = [a1:5:a2]) [2*r*cos(a), 2*r*sin(a)]], [[2*r*cos(a2), 2*r*sin(a2)]]));
		}
	}

// n copies of a hole around the centre, each at radius r pointing outward.
module ring(r, n, a0 = 0) for (i = [0:n-1]) rotate(a0 + 360/n*i) translate([r, 0]) children();

// ---- pictures --------------------------------------------------------
// All line art: strokes slot_w wide, and outlines of the same width. A
// stroke is a long narrow opening, which is exactly what the powder window
// wants. Anything an outline closes off is tied back to the plate by
// gaps cut with radial bars.

module outline(w = slot_w) {
	difference() {
		offset(r=w/2) children();
		offset(r=-w/2) children();
		}
	}

// Start a little out from the centre so the bars' junction never lands
// inside an opening that passes through it.
module radial_ties(n, a0 = 0, w = bridge_width) {
	for (i = [0:n-1]) rotate(a0 + 360/n*i)
		translate([6, -w/2]) square([art_d, w]);
	}

module tied_outline(n, a0 = 0, w = slot_w) {
	difference() {
		outline(w) children();
		radial_ties(n, a0);
		}
	}

// A wavy stroke, h tall, swinging amp either side of centre.
module wave(h, amp, w = slot_w) {
	polygon(concat(
		[for (y = [0:2:h]) [amp*sin(y/h*360) - w/2, y]],
		[for (y = [h:-2:0]) [amp*sin(y/h*360) + w/2, y]]));
	}

// Upper half of a ring, open at the bottom so it closes nothing off.
module arch(r, y, w = slot_w) {
	difference() {
		translate([0, y]) circle(r=r);
		translate([0, y]) circle(r=r - w);
		translate([-r - 1, y - r - 1]) square([2*r + 2, r + 1]);
		}
	}

module heart_shape(width) {
	s = width / 1.71;
	translate([0, -0.78*s]) rotate(45) {
		square(s);
		translate([s/2, s]) circle(d=s);
		translate([s, s/2]) circle(d=s);
		}
	}

module star_shape(ro, ri) {
	polygon([for (i = [0:9]) let (a = 90 + i*36, r = i % 2 == 0 ? ro : ri)
		[r*cos(a), r*sin(a)]]);
	}

module cup_body() {
	hull() {
		translate([-13, -16]) circle(4);
		translate([13, -16]) circle(4);
		translate([-17, 4]) circle(4);
		translate([17, 4]) circle(4);
		}
	}

module art_heart() {
	tied_outline(4, 0) heart_shape(62);	// gaps at notch, tip and both sides
	tied_outline(4, 0) heart_shape(36);
	}

module art_star() {
	tied_outline(5, 126) star_shape(38, 17);
	}

module art_cup() {
	tied_outline(4, 45) cup_body();
	difference() {						// handle, a C so it closes nothing
		translate([22, -6]) outline() circle(r=8);
		offset(r=slot_w/2 + 2) cup_body();
		}
	for (x = [-8, 0, 8]) translate([x, 12]) wave(18, 2.5);
	translate([0, -25]) square([50, slot_w], center=true);
	}

module art_snowflake() {
	for (a = [0:60:359]) rotate(a) {
		translate([0, -slot_w/2]) square([38, slot_w]);
		for (r = [15, 26]) for (side = [-1, 1])
			translate([r, 0]) rotate(side*60)
				translate([0, -slot_w/2]) square([9, slot_w]);
		}
	}

// Leaves are commas fanning from a stem. They may curl into the leaf below
// (a chain encloses nothing) but must stay clear of the stem and the frame,
// or stem + two leaves fence off a pocket.
module art_rosetta() {
	translate([0, -30]) rotate(90) drop(50, 3.5);			// stem
	for (i = [0:6]) for (side = [-1, 1])
		mirror([side < 0 ? 1 : 0, 0])
			translate([5.75, -20 + i*7.5]) rotate(-5) comma(17 - i*1.8, 4.5, 55);
	translate([0, 28]) heart_shape(8);
	ring_arc(39.5, 200, 340);								// the cup of the pour
	}

// Stacked crescents opening upward, a heart on top, framed like the rosetta.
module art_tulip() {
	for (i = [0:4]) {
		R = 24 - i*4;
		translate([0, -30 + i*8 + R]) crescent(R, 5);
		}
	translate([0, 21]) heart_shape(8);
	ring_arc(39.5, 200, 340);
	}

// Rings of holes with n-fold symmetry. Each ring is
// [radius, count, start angle, kind, length, width]; a hole's base sits at
// the radius and it points outward. Bases at the very centre overlap into
// one star-shaped hole; bases that merely touch would fence the centre off.
function mandala_rings(style) =
	style == "flower" ? [
		[0,    1,  0,    "dot",  5,  0],
		[4,    6,  0,    "lens", 10, 5],
		[15,   12, 0,    "dot",  2.5, 0],
		[18,   6,  30,   "lens", 14, 7],
		[18,   6,  0,    "drop", 9,  3],
		[34,   12, 0,    "drop", 6,  3]] :
	style == "burst" ? [
		[0.5,  8,  0,    "drop", 14, 3],
		[17,   8,  22.5, "lens", 9,  4],
		[28,   16, 0,    "dot",  2.5, 0],
		[31,   8,  22.5, "drop", 9,  4]] :
	[	[0.5,  8,  0,    "drop", 10, 3.5],
		[13,   8,  22.5, "lens", 11, 5],
		[15,   16, 0,    "dot",  2.5, 0],
		[24,   8,  0,    "drop", 10, 5],
		[27,   8,  22.5, "lens", 8,  3.5],
		[37.5, 16, 0,    "dot",  3,  0],
		[36,   8,  22.5, "lens", 5,  3]];

module hole(kind, L, w) {
	if (kind == "dot") dot(L);
	else if (kind == "drop") drop(L, w);
	else if (kind == "lens") lens(L, w);
	else if (kind == "comma") comma(L, w);
	}

module art_mandala() {
	for (rg = mandala_rings(mandala_style))
		ring(rg[0], rg[1], rg[2]) hole(rg[3], rg[4], rg[5]);
	}

module art_smiley() {
	tied_outline(4, 45) circle(r=34);
	for (x = [-11, 11]) translate([x, 9]) circle(d=6);
	difference() {
		circle(r=22);
		circle(r=19);
		translate([-30, -6]) square([60, 40]);
		}
	}

module art_bean() {
	tied_outline(4, 45) scale([1, 1.5]) circle(r=18);
	intersection() {					// crease stops short of the edge
		translate([0, -25]) wave(50, 3);
		offset(r=-5) scale([1, 1.5]) circle(r=18);
		}
	}

module art_cupcake() {
	intersection() {					// pleated wrapper
		polygon([[-18, -30], [18, -30], [22, -4], [-22, -4]]);
		for (x = [-18:6:18]) translate([x - slot_w/2, -40]) square([slot_w, 50]);
		}
	translate([0, -4]) square([48, slot_w], center=true);
	for (i = [0:2]) arch(20 - i*6, 2 + i*7);
	translate([0, 29]) circle(d=6);
	}

// Artwork drawn as SVG (as filled shapes, see stroke2fill.py): any closed
// stroke is opened up by the tie bars, which is what keeps whatever it
// enclosed attached to the plate.
module art_svg(file, ties, a0 = 45, tie_w = bridge_width) {
	difference() {
		import(file, center=true);
		radial_ties(ties, a0, tie_w);
		}
	}

// The slots must not touch each other at their inner ends, or they merge
// into a ring and the middle of the disk falls out: start them no closer
// in than the radius where a slot and a tie fit in every pitch.
module art_sunburst() {
	r0 = max(slot_inner, slot_count * (slot_w + bridge_width) / (2*PI));
	for (i = [0:slot_count-1]) rotate(360/slot_count*i)
		translate([r0, -slot_w/2])
			square([art_d/2 - r0, slot_w]);
	}

module art_text() {
	if (layout == "arc") difference() {
		arc_text();
		if (bridges) ring_ties();
		}
	else difference() {
		line_text();
		if (bridges) line_ties();
		}
	}

module art(name) {
	if (name == "sunburst") art_sunburst();
	else if (name == "heart") art_heart();
	else if (name == "star") art_star();
	else if (name == "cup") art_cup();
	else if (name == "snowflake") art_snowflake();
	else if (name == "rosetta") art_rosetta();
	else if (name == "tulip") art_tulip();
	else if (name == "mandala") art_mandala();
	else if (name == "smiley") art_smiley();
	else if (name == "bean") art_bean();
	else if (name == "cupcake") art_cupcake();
	else if (name == "croissant") art_svg("art/croissant.fill.svg", 4, 0, 3);	// ties as heavy as its strokes
	else if (name == "maple") art_svg("art/maple.fill.svg", 4, 22.5);
	else if (name == "svg") art_svg(svg_file, svg_ties);
	else art_text();
	}

module artwork(name = pattern) {
	intersection() {
		circle(d=art_d);
		art(name);
		}
	}

// ---- parts -----------------------------------------------------------

module plate(name = pattern) {
	difference() {
		union() {
			cylinder(d=disk_d, h=disk_t);
			difference() {					// rim
				cylinder(d=disk_d, h=rim_h);
				translate([0, 0, -1])
					cylinder(d=disk_d - rim_t*2, h=rim_h + 2);
				}
			}
		translate([0, 0, -1]) linear_extrude(disk_t + 2) artwork(name);
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

gallery = ["text", "sunburst", "heart", "star", "cup", "snowflake", "rosetta",
	"tulip", "mandala", "smiley", "bean", "cupcake", "croissant", "maple"];

if (part == "plate") plate();
else if (part == "rake") rake();
else if (part == "gallery")
	for (i = [0:len(gallery)-1])
		translate([(i % 7) * (disk_d + 10), -floor(i / 7) * (disk_d + 10), 0])
			plate(gallery[i]);
else {
	color("Gainsboro") plate();
	color("IndianRed") translate([0, 0, disk_t + 0.3]) rake();
	}
