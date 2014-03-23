// parts to make TwoUp printer gantry level

// bearing to go on M3-6 bolt

// bearing outer radius
bor = 12;
// bearing outer radius at rim
borim = 13;
// bearing inner radius
bir = 2;
// hearing height
bh = 3;
// bearing offset from body of printer
boff = 3;

// upper bearing inside radius
uir = 2;
// upper bearing outer radius at center (lowest part)
uor=2.5;
// upper bearing outer radius at rim
uorim=3.5;
// upper bearing height
uh=5;

thick = 6;
thin = 1;
tall = 10;

hr = 2;
ht = 2;

$fn=64;

module lowerBearing() {
	echo(borim, bor, bh);
	difference() {
		union() {
			cylinder(r1=borim, r2=bor, h=bh/2);
			translate([0,0,bh/2]) 	cylinder(r2=borim, r1=bor, h=bh/2);
			cylinder(r=bir+boff, h=bh+boff);
			}
		translate([0,0,-1]) cylinder(r=bir, h=bh+boff+2);
		}
	echo(hr, ht);
	}

// bearing around nail at top of printer

module upperBearing() {
	echo(uorim, uor, uh);
	difference() {
		union() {
			cylinder(r1=uorim, r2=uor, h=uh/2);
			translate([0,0,uh/2]) 	cylinder(r2=uorim, r1=uor, h=uh/2);
			}
		translate([0,0,-1]) cylinder(r=uir, h=uh+2);
		}
	}

module gantryClip(){
	cube([tall, thin, tall]);
	cube([thin, tall, tall]);
	cube([tall, tall, thin]);
	translate([6,6+1,0]) cube([tall-6,tall-6-1,3]);
	translate([6,0,0]) cube([tall-6,2,tall]);
	translate([0,0,hr+ht]) rotate([-90,0,0]) difference() {
		cylinder(r=hr+ht, h=ht);
		translate([0,0,-1]) cylinder(r=hr, h=ht+2);
		rotate([0,-90,0]) translate([0,0,-ht-hr-1]) cylinder(r=hr+ht+1, h=hr+ht+.5);
		}
	}

module hemiCircle(r, h=1) {
	echo(r, h);
	difference() {
		cylinder(r=r, h=h);
		translate([-r-1, -r-1, -1]) cube([2*r+2,r+1,h+2]);
		}
	}

module gantryBearing() {
	difference() {
		union() {
			translate([0,-26/2,8/2]) difference() {
				cube([54, 26, 8], center=true);
				cube([54-2, 26+2, 6], center=true);
				translate([0,0,-2]) cube([52-2, 26+2, 6], center=true);
				}
			hemiCircle(27,8);
			translate([-27, 0,0]) cube([6,26+5,8]);
			translate([-10, 0,0]) cube([20,26+5,8]);
			translate([21, 0,0]) cube([6,26+5,8]);
			}
		translate([0,-.1,-1]) hemiCircle(20,10);
		translate([0,-.1,1]) hemiCircle(26,6);
		translate([0,-.1,-1]) hemiCircle(25,3);
		translate([0,0,-1]) cylinder(r=5, h=12);
		translate([0,27+1,8-1]) rotate([0,90,0]) cylinder(r=uir, h=55, center=true);
		}
	}

//translate([65,0,8]) rotate([0,180,0]) gantryBearing();
//translate([65+55,0,8]) rotate([0,180,0]) gantryBearing();
//
//translate([borim+5, borim+5,0]) lowerBearing();
//translate([-(borim+5), borim+5,0]) lowerBearing();
translate([hr+ht+5,0,0]) rotate([90,0,0]) gantryClip();
mirror([1,0,0]) translate([hr+ht+5,0,0]) rotate([90,0,0]) gantryClip();

//translate([65,10,0]) upperBearing();
//translate([65+55,10,0]) upperBearing();
