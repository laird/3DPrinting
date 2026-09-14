// Cinnamon duster — rake-over-stencil concept.
//
// Powder sits in a chamber whose floor is the stencil card. Pressing the
// shutter drives a rack down a pinion, spinning a toothed rake across the
// card; the rake breaks up the powder and pushes it through the openings
// onto the foam below. Cohesive powder arches over small openings, so it
// stays put until raked — no gate needed, as long as the artwork keeps
// every opening inside the pass/hold window (see README).
//
// Dimensions are a first pass for discussion, not a print-ready part.

//Which drawing to produce
view = "section"; //[section,assembly,exploded,rake,card]

/* [Body] */
body = 100;			// outside, rounded square
body_r = 12;		// corner radius
wall = 3;
chamber_id = 80;	// powder chamber bore, leaves a 4mm ledge for the card
chamber_h = 22;

/* [Card] */
card_border = 4.5;	// Polaroid format: thin top/side borders...
card_foot = 23;		// ...and a deep bottom border for the caption and grip
card_t = 1.0;
slot_z = 2;			// card underside above the cup rim
window = 79;		// square image area, as a Polaroid
window_d = 76;		// usable circular artwork area inside it

/* [Rake] */
rake_d = 76;
rake_arms = 2;
tooth_pitch = 6;	// radial spacing along one arm
tooth_w = 1.2;
tooth_h = 3;
tooth_clear = 0.3;	// tip to card
hub_d = 12;

/* [Drive] */
shaft_d = 6;
pinion_pd = 6.4;	// 8 teeth, module 0.8 -> 1 turn per press
travel = 20;
spring_od = 6;
spring_coils = 6;
tower = 26;			// mechanism housing above the chamber

$fn = 64;

// ---- derived ---------------------------------------------------------
card_w = window + card_border*2;
card_l = window + card_border + card_foot;

slot_t = card_t + 0.4;
card_top = slot_z + card_t;
floor_z = slot_z + slot_t;			// top of the card ledge
chamber_top = floor_z + chamber_h;
top_plate = chamber_top + wall;
tower_top = top_plate + tower;

module rsq(w, r) { offset(r=r) square([w-2*r, w-2*r], center=true); }

// ---- parts -----------------------------------------------------------

// Shell: chamber bore all the way through, with a slot the card slides into
// from the front and a ledge for it to rest on.
module shell() {
	difference() {
		linear_extrude(top_plate) rsq(body, body_r);
		// powder chamber and the open bottom the powder falls through
		translate([0, 0, floor_z]) cylinder(d=chamber_id, h=chamber_h + 1);
		translate([0, 0, -1]) cylinder(d=chamber_id, h=slot_z + 1);
		// card slot, open at the front for insertion
		translate([-(card_w + 1)/2, -body, slot_z])
			cube([card_w + 1, body, slot_t]);
		// shaft bore through the top plate
		translate([0, 0, chamber_top - 1])
			cylinder(d=shaft_d + 0.4, h=wall + 2);
		}
	}

// Mechanism housing: a box over the top plate carrying the plunger.
module tower_housing() {
	difference() {
		translate([0, 0, top_plate]) linear_extrude(tower)
			offset(r=4) square([34, 26], center=true);
		translate([0, 0, top_plate - 1]) linear_extrude(tower + 2)
			offset(r=3) square([28, 20], center=true);
		}
	}

module card() {
	// Window centred on the axis; the card hangs forward so the caption
	// strip sticks out of the body as the grip you pull it by.
	difference() {
		translate([0, (card_border - card_foot)/2, 0])
			linear_extrude(card_t)
				square([card_w, card_l], center=true);
		// stand-in artwork: a ring of radial slots, all within the
		// pass/hold window, bridged so nothing comes loose
		for (a = [0:15:359])
			rotate(a) translate([window_d/4, 0])
				linear_extrude(card_t + 0.2) square([window_d/4, 3], center=true);
		linear_extrude(card_t + 0.2) circle(d=10);
		}
	}

// Rake: arms carrying teeth, staggered between arms so the swept pitch is
// half the pitch on any one arm. Inner stub tooth covers the hub dead zone.
module rake() {
	translate([0, 0, card_top + tooth_clear]) {
		cylinder(d=hub_d, h=tooth_h + 2);
		for (i = [0:rake_arms-1]) rotate(180/rake_arms*2*i) {
			translate([0, -2, tooth_h]) cube([rake_d/2, 4, 2]);
			// teeth, offset by half a pitch on alternating arms
			for (r = [hub_d/2 + 2 + (i % 2) * tooth_pitch/2 : tooth_pitch : rake_d/2])
				translate([r, 0, 0]) rotate([0, -15, 0])
					translate([-tooth_w/2, -2, 0]) cube([tooth_w, 4, tooth_h + 1]);
			}
		// inner stub tooth
		translate([hub_d/2 - 1, -2, 0]) cube([tooth_w, 4, tooth_h + 1]);
		}
	}

module shaft() {
	translate([0, 0, card_top]) cylinder(d=shaft_d, h=tower_top - card_top - 6);
	// pinion, drawn schematically
	translate([0, 0, top_plate + 2]) {
		cylinder(d=pinion_pd, h=6);
		for (a = [0:45:359]) rotate(a)
			translate([pinion_pd/2, 0, 3]) cube([1.4, 1.4, 6], center=true);
		}
	}

module plunger(pressed = false) {
	z = top_plate + (pressed ? 0 : travel);
	translate([0, 0, z]) {
		// rack bar
		translate([pinion_pd/2 + 1.2, -3, 2]) cube([4, 6, travel + 6]);
		for (t = [0 : 2.5 : travel + 3])
			translate([pinion_pd/2 + 0.4, -3, 3 + t]) cube([1.2, 6, 1.2]);
		// button
		translate([0, 0, travel + 12]) cylinder(d=16, h=5);
		translate([pinion_pd/2 + 1.2, -3, travel + 6]) cube([4, 6, 6]);
		}
	}

// Return spring, drawn as stacked coils (reads correctly in section).
module spring(pressed = false) {
	h = pressed ? 8 : travel + 8;
	n = spring_coils;
	for (i = [0:n-1])
		translate([0, 0, top_plate + 4 + i * (h / n)])
			rotate_extrude() translate([spring_od/2, 0]) circle(d=0.9, $fn=12);
	}

// ---- assembly --------------------------------------------------------

module parts(explode = 0) {
	color("LightSteelBlue")	translate([0, 0, explode * 0])	shell();
	color("LightSteelBlue")	translate([0, 0, explode * 1.4])	tower_housing();
	color("Khaki")			translate([0, explode * 1.2, slot_z + explode * 0.3]) card();
	color("IndianRed")		translate([0, 0, explode * 2.2])	rake();
	color("Gray")			translate([0, 0, explode * 3.0])	shaft();
	color("DarkSeaGreen")	translate([0, 0, explode * 4.0])	plunger();
	color("Silver")			translate([0, 0, explode * 4.0])	spring();
	}

if (view == "assembly") parts();
else if (view == "exploded") parts(explode = 14);
else if (view == "rake") { color("IndianRed") rake(); color("Khaki") translate([0,0,slot_z]) card(); }
else if (view == "card") card();
else difference() {					// section
	parts();
	translate([-body, 0, -20]) cube([body*2, body*2, tower_top + 60]);
	}
