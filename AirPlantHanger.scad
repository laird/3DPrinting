
// Diameter of plant base
plantD = 24;
plantR=plantD/2;
outerD = 48;
outerR=outerD/2;
thick=2;
height=10;
gap=0.4;

/* [Hidden] */

$fn=64;

hoopR = 2*outerR;

module base() {
	difference() { 
	   union() {
			difference() {
				cylinder(r=plantR+thick, h=height+thick);
				translate([0,0,-1]) cylinder(r=plantR, h=height+thick+2);
				}
			cylinder(r=outerR, h=thick);
			}
		hoopPositioned(hoopR, gap) ;
		rotate([0,0,90]) hoopPositioned(hoopR-thick, gap) ;
		//translate([0,0,-thick]) cylinder(r=outerR+thick,h=thick);
		}
	}

module holder() {
	difference() {
		cube([3*thick,3*thick,height], center=true);
		cube([thick,thick,height+1], center=true);
		}
	}

module hoopPositioned(r, g) {
	translate([0,thick/2,hoopR+thick-6]) rotate([90,0,0]) 
		hoop(r, g);
	}

module hoop(r, g) {
	difference() {
		cylinder(r=r+thick+g, h=thick+g);
		translate([0,0,-1]) cylinder(r=r, h=thick+2);
		}
	}

module assembled() {
	base();
	hoopPositioned(hoopR, 0);
	rotate([0,0,90]) hoopPositioned(hoopR-thick-gap, 0);
	}

module plated() {
	base();
	hoop(hoopR, 0);
	hoop(hoopR-thick-gap, 0);
	}

plated();
assembled();