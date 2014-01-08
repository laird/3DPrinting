// TwoUp Extruder model

/* todo:

- Add bumps/holes so two halves of parts mate together
- make hot end toghter
- make spring shorter
- move spring out slightly
- move bearing away 0.5mm

*/

$fn=32;
part = 11 ; //[0:Preview Assembled, 1:Preview lever pressed, 4:body back, 5:body front, 6:Body plated, 7:Lever back, 8:Lever front, 9:Lever plated]

// box x
bx=57;
// box y
by=47.72;
// box z
bz=30.72-4;
// hot end Z
hz=15.36-2;
// Hot end X
hx = 27;
// Hot end y
hy=7;
// motor X
mx = 21;
// motor y
my = 26.72;
// Wall thickness
wall = 5;
// Clearance
clearance = 0.4;
// middle width
midW = bz-2*wall-2*clearance;
// Screws X Y position
sx1 = 5.5+1;
sx2 = 37.5;
sy1 = 11.22;
sy2 = 42.22;
sr = 1.5; //M3 screws' radius
// Lever angle
la = 10;

// Tension bearing inner diameter
bid = 9.525;
// Tension bearing outer diameter
bod = 15.875;
// Tension bearing width
bw = 3.967;
// Offset (to leave room for filament)
boff = 0.5;

bir=bid/2;
bor=bod/2;

// Vent length
vh = 55;
// Vent into body
vin = 10;
// Radius
vr = 5;
// Wall thickness
vw = 1;
// Opening at bottom
vopenw = 7;
vopenh = 5;

module fan() {
	translate([bx+clearance, 0, 40]) rotate([0,90,0]) cube([40,40,10]);
	}

// screw holes, enlarged so screw threads slide through
module screws () {
	//echo("screw x ",sx2-sx1);
	// echo("screw y ",sy2-sy1);
	h=bz+2;
	translate([0,0,-1]) {
	translate([sx1,sy1,0]) cylinder(r=sr+2*clearance, h=h);
	translate([sx2,sy1,0]) cylinder(r=sr+2*clearance, h=h);
	translate([sx1,sy2,0]) cylinder(r=sr+2*clearance, h=h);
	translate([sx2,sy2,0]) cylinder(r=sr+2*clearance, h=h);
	}
}

module hotend() {
	hh=30; // how far to clear outside
	hin=12; // how far to clear inside
	gr=(16.5-2*1.25)/2; // groove radius
	gy = 7; // y position of groove center
	gh=2*1.25;
	hr = 7.94;

	translate([hx,hy+hin,hz]) rotate([90,0,0]) {
		difference() {
			cylinder(r=hr+clearance, h=hh+hin);
			translate([0,0,gy+hin-hy]) cylinder(r=hr+1,h=gh-clearance*2,center=true);
		}
		cylinder(r=gr, h=hh);
	}
}

module vent() {
	translate([sx1+vr+vw, vin, bz/2]) rotate([90,0,0]) difference() {
		rotate([0,0,360/16]) {
		difference() {
			union() {
				cylinder($fn=8, r=vr, h=vh+vin); // 60 mm to reach extruder, 10mm fit into extruder body
				translate([0,0,vin]) cylinder($fn=8, r=vr+1, h=1); // 60 mm to reach extruder, 10mm fit into extruder body
				}
			translate([0,0,-1]) cylinder($fn=8, r=vr-vw, h=vh+vin); // 60 mm to reach extruder, 10mm fit into extruder body
			rotate([0,0,-360/16]) translate([vr,0,vh+vin-vopenh/2-1]) cube([2*vr,vopenw, vopenh], center = true);
			translate([0,vr,vin]) cube([2*vr,2,1], center=true);
			}
		}
		translate([-(vr+.1),0,vin]) cube([1,2*vr,3],center=true);
		}
	}

// hole in body to fit vent
module ventHole(){
	translate([sx1+vr+vw, wall, bz/2])
	rotate([90,0,0]) rotate([0,0,360/16]) cylinder($fn=8, r=vr+clearance, h=20, center=true);
}

module ventPlate(){
	translate([bx+30,by+vin+13,0]) translate([0,0,-bz/2+vr+.476]) rotate([0,-90,0]) vent();
	}

module motorHole() {
	mz = bz+1;
	mh = bz+2;

	translate([mx,my,mz]) rotate([180,0,0]) {
		cylinder(r=16, h=mh);
		}
	}

module motor() {
	mz = bz+1;
	mh = bz+2;

	translate([mx,my,mz]) rotate([180,0,0]) {
		//%translate([0,0,1]) cylinder(r=15, h=2);
		%translate([0,0,1]) cylinder(r=6, h=bz-5);
		}
	}

module bearing() {
	echo("bearing", hx, bor, my, hz, bw, bir);
	translate([hx+bor+boff, my, hz])
	difference() {
		cylinder(r=bor,h=bw, center=true);
		cylinder(r=bir, h=bw+1, center=true);
		}
	}

module bearingHole() {
	echo("bearing hole ", hx, bor, my, hz, bw, bir, clearance);
	translate([hx+bor+boff, my, hz])
		difference() {
			cylinder(r=bor+2*clearance,h=bw+4*clearance, center=true);
			cylinder(r=bir-clearance, h=bw+4*clearance+1, center=true);
			}
	}

module bearingHub() {
	translate([hx+bor+boff, my, hz]) {
		cylinder(r=bir-clearance, h=midW-2*clearance, center=true);
		translate([0,0,bw/2+(bor-bir)/2]) cylinder(r1=(bir+bor)/2, r2=bir-clearance, h=(bor-bir), center=true);
		translate([0,0,-(bw/2+(bor-bir)/2)]) cylinder(r2=(bir+bor)/2, r1=bir-clearance, h=(bor-bir), center=true);
		}
	}

module lever() {
	difference() {
		union() {
			translate([hx+bor+2.5, my+by/4, hz])
				rotate([0,0,-13]) cube([bor,by/2,midW-2*clearance], center=true);
			translate([0,by-2*wall,wall+2*clearance]) cube([bx*.7, 2*wall, midW-2*clearance]);
			}
		translate([0,by-clearance,wall+clearance-1]) cube([bx, 2*wall, midW+2]);
		bearingHole();
		translate([sx1,sy2,-1]) cylinder(r=sr+clearance, h=bz+2);
		translate([sx1-sr-clearance,sy2,-1])
			cube([2*(sr+clearance),by-sy2+1,bz+2]);
		filamentHole();
		screws();
		springHole();
		}
	bearingHub();
	//translate([0,by-wall,wall+clearance]) cube([bx*.7, wall, midW]);
	%bearing();
	}

// lever rotated to allow filament to enter
module rotLever() {
	translate([sx2, sy2, 0]) rotate([0,0,la]) translate([-sx2, -sy2, 0]) lever();
	}

// hole into which lever fits
module leverHole() {
	echo("lever hole ", hx, bor, my, hz, bx, by, midW);
	translate([sx2, sy2, hz])
		cube([bx-15,by+5,midW], center=true);
	translate([-1,by-2*wall-clearance,wall+clearance])
		cube([bx*.7+clearance+2, 2*wall+2*clearance, midW]);
	translate([sx2, sy2, 0]) rotate([0,0,la]) translate([-sx2, -sy2, 0])
		translate([-1,by-2*wall-clearance,wall+clearance])
			cube([bx*.7+clearance+2, 2*wall+10, midW]);
	}

module box() {
	cube([bx,by,bz]);
	}

module spring() {
	translate([4, by/2+wall,bz/2]) rotate([-90,0,0])
		cylinder(r=3-clearance, h=20-2*clearance, center = true);
	}

module springHole() {
	translate([4, by/2+wall,bz/2]) rotate([-90,0,0])
		cylinder(r=3, h=20+2, center = true);
	}

module springHolder() {
	translate([4, by/2+wall,bz/2]) rotate([-90,0,0])
		cylinder(r=3+1, h=20, center = true);
	}

module holes() {
	screws();
	hotend();
	difference() {
		motorHole();
		springHolder();
		}
	filamentHole();
	leverHole();
	springHole();
	ventHole();
	}

module filament () {
	translate([hx,hy,hz]) rotate([90,0,0]) cylinder(r=1.75/2,h=2*by,center=true);
	}

module filamentHole() {
	translate([hx,hy,hz]) rotate([90,0,0]) cylinder(r=1.75/2+2,h=2*by,center=true);
	}

module assembled(tilt=0) {
	extruderBody();
	color("grey") motor();
	color("red") filament();
	color("grey") screws();
	color("grey") spring();
	%fan();
	if (tilt==1) rotLever();
	if (tilt==0) lever();
	vent();
	}

module extruderBody() {
	difference() {
		box();
		holes();
		}
	}


module backShape() {
	splitZ = hz;
	translate([-1,-1,-1]) cube([bx+2,by+2,splitZ+1]);
	}

module Bback() {
	intersection() {
		extruderBody();
		backShape();
		}
	}

module Bfront() {
	translate([0,by,bz]) rotate([180,0,0]) difference() {
		extruderBody();
		backShape();
		}
	}

module Bplate() {
	Bfront();
	translate([0,by+5,0]) Bback();
	}

module Lback() {
	translate([0,0,-wall-clearance]) intersection() {
		lever();
		backShape();
		}
	}

module Lfront() {
	translate([0,by,bz-wall-clearance]) rotate([180,0,0]) difference() {
		lever();
		backShape();
		}
	}

module Lplate() {
	Lfront();
	translate([0,by+5,0]) Lback();
	}

module allPlated() {
	Bplate();
	translate([bx+10,0,0]) Lplate();
	ventPlate();
	}

if (part==0) assembled(0); // no tilt
if (part==1) assembled(1); // tilt
if (part==2) extruderBody();
if (part==3) lever();
if (part==4) Bback();
if (part==5) Bfront();
if (part==6) Bplate();
if (part==7) Lback();
if (part==8) Lfront();
if (part==9) Lplate();
if (part==10) ventPlate();
if (part==11) allPlated();
