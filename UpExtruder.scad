// TwoUp Extruder model

/* todo:

- Add bumps/holes so two halves of parts mate together (done)
- make body more airtight to force more air to vent
- add second vent to fan (done)
- make hot end tighter (done)
- make spring shorter (done)
- move spring out slightly (done, added holder)
- move bearing away 0.5mm (done)

*/

$fn=32;
part = 12; //[0:Preview Assembled, 1:Preview lever pressed, 4:body back,5:body front, 6:Body plated, 7:Lever back, 8:Lever front, 9:Lever plated, 10:Vent Plated, 11:Fan vent, 12:Everything Plated]

// box x
bx=57;
// box y
by=47.72;
// box z
bz=30.72;
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
// motor size (approx)
ms = by-5;
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
// lever length
ll=20;


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
// vent1 angle
va1 = -5;
// Radius
vr = 6;
// Wall thickness
vw = 1;
// Opening at bottom
vopenw = 7;
vopenh = 5;
// vent sphere for clearance
vhr = midW*.4;

// fan size
fs = 40;

module fan() {
	translate([bx+clearance, 5, fs]) rotate([0,90,0]) cube([fs,fs,10]);
	}

module fanScrews() {
	fso = 31/2;

	translate([bx+clearance-5, 5, fs]) rotate([0,90,0]) translate([fs/2,fs/2,0]) {
		for (x=[-fso,fso]) {
			for (y=[-fso,fso]) {
				translate([x,y,0]) cylinder(r=1.5,h=15);
				}
			}
		}
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

module fanVent() {
	echo("fan vent pos ", mx,0,bz+clearance);
	echo("fan vent size ", bx-mx,fs,fs-bz-clearance);
	difference() {
		translate([ms+clearance,0,bz+clearance])
		difference() {
			cube([bx-ms-2*clearance,fs+5,fs-bz-clearance+4+clearance]);
			translate([1,1+11,1]) cube([bx-2*mx-2*clearance,fs-2-12,fs-bz-clearance-2]);
			}
		ventHole2();
		fanScrews();
		}
	}

module fanVentPlated() {
	rotate([0,-90,0])
		translate([-(ms+clearance),0,-(bz+clearance)-(fs-bz-clearance)])
			fanVent();
}

// hole for hot end in body
module hotend() {
	hh=80; // how far to clear outside
	hin=12; // how far to clear inside
	gr=(16.5-2*1.25)/2; // groove radius
	gy = 7; // y position of groove center
	gh=2*1.25;
	hr = 7.94;

	translate([hx,hy+hin,hz]) rotate([90,0,0]) {
		difference() {
			cylinder(r=hr+clearance/2, h=hh+hin);
			translate([0,0,gy+hin-hy]) cylinder(r=hr+1,h=gh-clearance/2,center=true);
		}
		cylinder(r=gr, h=hh);
	}
}

module vent1() {
	difference() {
		rotate([0,0,va1]) translate([1+vr, vin, bz/2])
			difference() {
				vent();
				//translate([vr,vr,0]) sphere(vhr);
				translate([vhr/2,vhr/2,0]) sphere(vhr);
				}
		hotend();
		}
	}

module vent() {
	vLen = 2*vr;
	difference() {
		rotate([90,0,0]) difference() {
			rotate([0,0,360/16]) {
			difference() {
				union() {
					cylinder($fn=8, r=vr, h=vh+vin); // 60 mm to reach extruder, 10mm fit into extruder body
					translate([0,0,vin]) cylinder($fn=8, r=vr+1, h=1); // 60 mm to reach extruder, 10mm fit into extruder body
					rotate([0,0,-360/16]) translate([vr,0,vh+vin-vopenh/2-1])
						rotate([0,-30,0]) cube([vLen,vopenw+2, vopenh+2], center = true);
					}
				translate([0,0,-1]) cylinder($fn=8, r=vr-vw, h=vh+vin); // 60 mm to reach extruder, 10mm fit into extruder body
				rotate([0,0,-360/16]) translate([vr,0,vh+vin-vopenh/2-1])
					rotate([0,-30,0]) cube([vLen+1,vopenw, vopenh], center = true);
				}
			}
			translate([-(vr+.1),0,vin]) cube([1,2*vr,3],center=true);
			}
		//#hotend();
		}
	}

module vent2() {
	difference() {
		translate([(2*mx+bx)/2, vin, bz+(fs-bz)/2+2]) rotate([0,360*3/8,0])
			vent();
		hotend();
		}
	}

// hole in body to fit vent
module ventHole(){
	rotate([0,0,va1]) translate([1+vr, vin, bz/2])rotate([90,0,0]) rotate([0,0,360/16]) {
		cylinder($fn=8, r=vr+clearance/2, h=16, center=true);
		translate([vhr/2,0,-vhr/2]) sphere(vhr);
	}
}

// hole in fan vent for vent
module ventHole2(){
	echo("vent 2 ",(2*mx+bx)/2, wall, bz+(fs-bz)/2+3);
	translate([(2*mx+bx)/2+clearance, wall, bz+(fs-bz)/2+2+clearance])
	rotate([90,0,0]) rotate([0,0,360/16])
		cylinder($fn=8, r=vr+clearance/2, h=fs+20, center=true);
}

module ventPlate(){
	translate([bx+30,by+vin+13,1.6])
		translate([0,0,-bz/2+2*vr+.36]) rotate([0,-90,0])
			rotate([0,0,-va1]) vent1();
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

	translate([mx,my,mz]) {
		rotate([180,0,0]) {
			%translate([0,0,1]) cylinder(r=15, h=2);
			%translate([0,0,1]) cylinder(r=6, h=bz-5);
			}

		}
	translate([0,by-ms,bz+clearance]) cube([ms,ms,ms]);
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
	translate([hx+bor+boff, my, bz/2])
		cylinder(r=bir-clearance, h=midW-2*clearance, center=true);
	translate([hx+bor+boff, my, hz]) {
		translate([0,0,bw/2+(bor-bir)/2]) cylinder(r1=(bir+bor)/2, r2=bir-clearance, h=(bor-bir), center=true);
		translate([0,0,-(bw/2+(bor-bir)/2)]) cylinder(r2=(bir+bor)/2, r1=bir-clearance, h=(bor-bir), center=true);
		}
	}

module lever(showBearing=0) {
	difference() {
		union() {
			translate([hx+bor+2.5, my+by/4, bz/2])
				rotate([0,0,-13]) cube([bor,by/2,midW-2*clearance], center=true);
			translate([-ll,by-2*wall,wall+2*clearance]) cube([bx*.7+ll, 2*wall, midW-2*clearance]);
			translate([wall*2+2*clearance,by-2.5*wall,bz/2])
				cube([wall,2*wall,midW],center=true);
			}
		translate([-ll,by-.1,wall+clearance-1]) cube([bx+ll, 2*wall, midW+2]);
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
	if (showBearing) color("yellow") bearing();
	}

// lever rotated to allow filament to enter
module rotLever(showBearing=0) {
	translate([sx2, sy2, 0]) rotate([0,0,la]) translate([-sx2, -sy2, 0]) lever(showBearing);
	}

// hole into which lever fits
module leverHole() {
	echo("lever hole ", hx, bor, my, hz, bx, by, midW);
	translate([mx, sy1+0.5, wall+clearance])
		cube([bx-15,(by+5)/2,midW]);
	translate([2-ll,by-2*wall-clearance,wall+clearance])
		cube([bx*.7+clearance+2+ll, 2*wall+2*clearance, midW]);
	translate([sx2, sy2, 0]) rotate([0,0,la]) translate([-sx2, -sy2, 0])
		translate([-1,by-2*wall-clearance,wall+clearance])
			cube([bx*.7+clearance+2, 2*wall+10, midW]);
	}

module box() {
	cube([bx,by,bz]);
	}

module spring() {
	translate([4, by/2+wall+2,bz/2]) rotate([-90,0,0])
		cylinder(r=3-clearance, h=18-2*clearance, center = true);
	}

module springHole() {
	translate([4, by/2+wall+2,bz/2]) rotate([-90,0,0])
		cylinder(r=3, h=18, center = true);
	}

module springHolder() {
	translate([4, by/2+wall,bz/2]) rotate([-90,0,0])
		cylinder(r=3+1, h=20+2, center = true);
	}

module holes() {
	screws();
	fanScrews();
	hotend();
	difference() {
		motorHole();
		springHolder();
		}
	filamentHole();
	leverHole();
	springHole();
	ventHole();
	ventHole2();
	}

module filament () {
	translate([hx,hy,hz]) rotate([90,0,0]) cylinder(r=1.75/2,h=2*by,center=true);
	}

module filamentHole() {
	translate([hx,hy,hz]) rotate([90,0,0]) cylinder(r=1.75/2+2,h=2*by,center=true);
	}

module assembled(tilt=0) {
	//color("yellow") translate([0,0,clearance]) LBackHanging();
	color("orange") LFrontHanging();
	color("green") BFrontHanging();
	//translate([0,0,clearance]) Bback();
	//extruderBody();
	color("grey") motor();
	color("red") filament();
	color("grey") screws();
	color("grey") spring();
	%fan();
	//if (tilt==1) rotLever(1);
	//if (tilt==0) lever(1);
	color("blue") vent1();
	color("blue") vent2();
	fanVent();
	color("black") hotend();
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
	for (x=[sx1,sx2]) {
		for (y=[sy1,sy2]) {
			translate([x,y,splitZ]) cylinder(r=3,h=2, center=true);
			}
		}
	}

module Bback() {
	intersection() {
		extruderBody();
		backShape();
		}
	}

module Bfront() {
	translate([0,by,bz]) rotate([180,0,0]) BFrontHanging();
	}

module BFrontHanging() {
	difference() {
		extruderBody();
		backShape();
		}
	}

module Bplate() {
	Bfront();
	translate([0,by+5,0]) Bback();
	}

module Lback() {
	translate([0,0,-wall-clearance]) LBackHanging();
	}

module LBackHanging() {
	intersection() {
		lever();
		backShape();
		}
	}

module Lfront() {
	translate([0,by,bz-wall-clearance-clearance]) rotate([180,0,0])
		LFrontHanging();
	}

module LFrontHanging() {
	difference() {
		lever();
		backShape();
		}
	}

module Lplate() {
	Lfront();
	translate([0,by+5,-clearance]) #Lback();
	}

module allPlated() {
	Bplate();
	translate([bx+30,0,0]) Lplate();
	translate([-5,5,0]) ventPlate();
	translate([vr*3-5,5,0]) ventPlate();
	translate([bx+vr*10-17,by/2+4,0]) fanVentPlated();
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
if (part==11) fanVentPlated();
if (part==12) allPlated();
