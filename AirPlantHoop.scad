
// Diameter of plant base
plantD = 24;
plantR=plantD/2;
// Diameter of platform
outerD = 48;
// Diameter of largest hoop
hoopD = 96; 
// Number of Hoops
numHoops = 1; //[1,2]
// Thickness of hoops, base, etc.
thick=3;
// Height of plant stand
height=10;
// Diameter of hooks on links
linkD = 10;
// Length of links (for hanging)
linkLen = 200;
// Gap between assembled parts (0 is very tight, 0.4 = loose)
gap=0.4;
// Part to show
part= 0; //[0:Assembled, 1:Plated, 2:Base, 3:Large hoop, 4: Small hoop, 5:Link, 6: Links Plated]

/* [Hidden] */

$fn=64;

outerR=outerD/2;
linkR = linkD/2;
hoopR = hoopD/2;

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
		if (numHoops==2) rotate([0,0,90]) hoopPositioned(hoopR-thick-gap, gap) ;
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
	translate([0,thick/2,hoopR+thick-thick]) rotate([90,0,0]) 
		hoop(r, g);
	}

// hoop radius r
// if g>0 then we're making a hole for a hoop, with gap g

module hoop(r, g) {
	difference() {
		if (g>0) {
			cylinder(r=r+3*thick+g, h=thick+g);
			}
		else {
			cylinder(r=r+thick+g, h=thick+g);
			}
		translate([0,0,-1]) cylinder(r=r, h=thick+2);
		}
	}

module link() {
	difference() {
	union() {
		hoop(linkR,0);
		translate([linkLen,0,0]) hoop(linkR,0);
		}
	translate([0,-linkR, -1]) 
		cube([linkLen,linkR,thick+2]);
	}
	translate([0,-linkR-thick,0]) cube([linkLen,thick,thick]);
	}

module linkPlate() {
	spacing = linkD+3*thick;
	for (y = [-2*spacing:spacing:2*spacing]) {
		translate([-linkLen/2,y,0]) link();
		}
	}

module assembled() {
	base();
	hoopPositioned(hoopR, 0);
	if (numHoops==2) rotate([0,0,90]) hoopPositioned(hoopR-thick-2*gap, 0);
	}

module plated() {
	base();
	hoop(hoopR, 0);
	if (numHoops==2) hoop(hoopR-thick-2*gap, 0);
	}

if (part==0) assembled();
if (part==1) plated();
if (part==2) base();
if (part==3) hoop(hoopR, 0);
if (part==4) hoop(hoopR-thick-gap, 0);
if (part==5) link();
if (part==6) linkPlate();



