// FilaBottle System
//
// (c) 2013 Laird Popkin.
//
// System for using 2 Liter bottles with the FilaStruder.
//
// FilaFunnel that screws onto a 2 Liter bottle, for pouring plastic pellets into a 2 Liter bottle.
//
// FilAdapter that screws onto a 2 Liter bottle, that fits into the Filastruder hopper.
//
// BottleCap that closes a bottle, in case you lose the cap that came with the bottle.

part="cap"; // "threads" for the part to print, "neck" for the part to subtract from your part
clearance=0.4; // tune to get the right 'fit' for your printer

$fn=64;

// Bottle params

bottleID=25.07;
bottleIR=bottleID/2;
bottleOD=27.4;
bottlePitch=2.7;
bottleHeight=9;
bottleAngle=2;
threadLen=15;
bottleNeckID = 21.74;

// holder params

holderOD=bottleOD+5;
holderOR=holderOD/2;

// Cap params

capHeight = 1;

// funnel params

funnelOD=100;
funnelOR=funnelOD/2;
funnelWall=2;
funnelIR=bottleNeckID/2;
funnelRim = 5;

// Filastruder hopper params

filaX = 20;
filaY = 39;
filaDepth = 40;
filaHoleD = filaX*.7;
filaHoleR = filaHoleD/2;
filaGap = bottleIR-filaHoleR;

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
			translate([0,0,-.1]) cylinder(r=funnelIR, h=funnelWall+.2);
			}
		}
	translate([0,0,bottleHeight+funnelWall]) difference() {
		cylinder(r1=holderOR,r2=funnelOR, h=funnelOR-bottleOD/2);
		translate([0,0,-.1]) cylinder(r1=funnelIR,r2=funnelOR-funnelWall, h=funnelOR-bottleOD/2+.2);
		}
	translate([0,0,bottleHeight+funnelOR-bottleOD/2]) difference() {
		difference() {
			cylinder(r=funnelOR, h=funnelRim);
			translate([0,0,-.1]) cylinder(r=funnelOR-funnelRim, h=funnelRim+.2);
			}
		}
	bottleHolder();
	}

module FilaBottle() {
	difference() {
		union() {
			translate([-filaX/2,-filaY/2,0]) cube([filaX,filaY,filaDepth+filaGap]);
			translate([0,0,filaDepth]) cylinder(r1=filaX/2,r2=holderOR, h=filaGap);
			}
		translate([0,0,-1]) cylinder(r=filaHoleR, h=filaDepth+2);
		translate([0,0,filaDepth]) translate([0,0,-.1]) cylinder(r1=filaHoleR,r2=bottleIR, h=filaGap+.2);
		echo("fila funnel ",funnelIR);
		}
	//translate([0,0,filaDepth]) difference() {
	//	cylinder(r1=filaX/2,r2=holderOR, h=filaGap);
	//	translate([0,0,-.1]) cylinder(r1=filaHoleR,r2=bottleIR, h=filaGap+.2);
	//	}
	translate([0,0,filaDepth+filaGap]) bottleHolder();
	}

module BottleCap() {
	cylinder(r=holderOR,h=capHeight);
	translate([0,0,capHeight]) bottleHolder();
	}

if (part=="threads") bottleHolder();;
if (part=="neck") bottleNeck();
if (part=="funnel") funnel();
if (part=="fila") FilaBottle();
if (part=="cap") BottleCap();