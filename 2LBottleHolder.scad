// 2 Liter Bottle Holder
//
// (c) 2013 Laird Popkin, based on http://www.threadspecs.com/assets/Threadspecs/ISBT-PCO-1881-Finish-3784253-18.pdf.
// Credit to eagleapex for creating and then deleting http://www.thingiverse.com/thing:10489 
// which inspired me to create this.

part="funnel"; // "threads" for the part to print, "neck" for the part to subtract from your part
clearance=0.4; // tune to get the right 'fit' for your printer

// Bottle params

bottleID=25.07;
bottleOD=27.4;
bottlePitch=2.7;
bottleHeight=9;
bottleAngle=2;
threadLen=15;

// holder params

holderOD=bottleOD+5;
holderOR=holderOD/2;

// funnel params

funnelOD=100;
funnelWall=2;

// Bottle Computations

threadHeight = bottlePitch/3;
echo("thread height ",threadHeight);
echo("thread depth ",(bottleOD-bottleID)/2);

module bottleNeck() {
	difference() {
		union() {
			translate([0,0,-0.5]) cylinder(r=bottleOD/2+clearance,h=bottleHeight+1);
			}
		union() {
			rotate([0,bottleAngle,0]) translate([-threadLen/2,0,bottleHeight/2]) cube([threadLen,bottleOD,threadHeight]);
			rotate([0,bottleAngle,90]) translate([-threadLen/2,0,bottleHeight/2+bottlePitch/4]) cube([threadLen,bottleOD,threadHeight]);
			rotate([0,bottleAngle,-90]) translate([-threadLen/2,0,bottleHeight/2+bottlePitch*3/4]) cube([threadLen,bottleOD,threadHeight]);
			rotate([0,bottleAngle,180]) translate([-threadLen/2,0,bottleHeight/2+bottlePitch/2]) cube([threadLen,bottleOD,threadHeight]);
			translate([0,0,-bottlePitch]) {
				rotate([0,bottleAngle,0]) translate([-threadLen/2,0,bottleHeight/2]) cube([threadLen,bottleOD,threadHeight]);
				rotate([0,bottleAngle,90]) translate([-threadLen/2,0,bottleHeight/2+bottlePitch/4]) cube([threadLen,bottleOD,threadHeight]);
				rotate([0,bottleAngle,-90]) translate([-threadLen/2,0,bottleHeight/2+bottlePitch*3/4]) cube([threadLen,bottleOD,threadHeight]);
				rotate([0,bottleAngle,180]) translate([-threadLen/2,0,bottleHeight/2+bottlePitch/2]) cube([threadLen,bottleOD,threadHeight]);
				}
			//translate([0,0,bottleHeight/2+bottlePitch/2]) rotate([0,0,90]) cube([10,bottleOD,threadHeight], center=true);
			}
		}
	translate([0,0,-1]) cylinder(r=bottleID/2+clearance,h=bottleHeight+2);
	}

module bottleHolder() {
	difference() {
		cylinder(r=holderOR,h=bottleHeight);
		bottleNeck();
		}
	}

module funnel() {
	translate([0,0,bottleHeight]) difference() {
		difference() {
			cylinder(r=holderOR, h=funnelWall);
			translate([0,0,-.1]) cylinder(r=bottleID/2, h=funnelWall+.2);
			}
		}
	translate([0,0,bottleHeight+funnelWall]) difference() {
		cylinder(r1=holderOR,r2=funnelOD, h=funnelOD-bottleOD);
		translate([0,0,-.1]) cylinder(r1=bottleID/2,r2=funnelOD-funnelWall, h=funnelOD-bottleOD+.2);
		}
	bottleHolder();
	}

if (part=="threads") bottleHolder();;
if (part=="neck") bottleNeck();
if (part=="funnel") funnel();