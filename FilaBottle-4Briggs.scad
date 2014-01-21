// FilaBottle System
//
// (c) 2013 Laird Popkin.
//
// System for using 2 Liter bottles with the FilaStruder.
//
// FilaFunnel that screws onto a 2 Liter bottle, for pouring plastic pellets into a 2 Liter bottle.
//
// FilAdapter that screws onto a 2 Liter bottle, that fits into the Filastruder hopper.

<<<<<<< HEAD
part="comb"; // "threads" for the part to print, "neck" for the part to subtract from your part
=======
part="fila"; // "threads" for the part to print, "neck" for the part to subtract from your part
>>>>>>> f49c02c81ad8ab46c2f2d170480c03a12e3a0fc6

half=0;	// 1=show cross section

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

// funnel params

funnelOD=100;
funnelOR=funnelOD/2;
funnelWall=2;
funnelIR=bottleNeckID/2;
funnelRim = 5;

// Filastruder hopper params

filaX = 31.8;
filaY = 48;
filaDepth = 12.7+10;
filaHoleD = filaX*.7;
filaHoleR = filaHoleD/2;
filaGap = bottleIR-filaHoleR;

// hole for plug

otherD = 3; // Diameter of plug
otherR = otherD/2;


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
			translate([0,0,filaDepth+filaGap]) bottleHolder();
<<<<<<< HEAD
			translate([-filaX/2,-filaY/2,0]) cube([filaX,filaY,filaDepth+filaGap]);
			translate([0,0,filaDepth]) cylinder(r1=filaX/2,r2=holderOR, h=filaGap);
			}
		translate([0,-8,12]) rotate([-20,0,0]) filaCombHole();
=======
//			translate([-filaX/2,-filaY/2,0]) cube([filaX,filaY,filaDepth+filaGap]);

			difference() {
				translate([-filaX/2,-filaY/2,0]) cube([filaX,filaY,filaDepth+filaGap]);
				for (x = [-filaX/2,filaX/2]) {
					for (y = [-filaY/2,filaY/2]) {
						translate([x,y,filaDepth/2+1]) cube([8,8,filaDepth+3], center=true);
						}
					}
				}
			for (x = [-filaX/2+4,filaX/2-4]) {
				for (y = [-filaY/2+4,filaY/2-4]) {
					translate([x,y,filaDepth/2+1/2]) cylinder(r=4, h=filaDepth+1.9, center=true);
					}
				}

			translate([0,0,filaDepth]) cylinder(r1=filaX/2,r2=holderOR, h=filaGap);
			}
		translate([0,-8,2]) rotate([-20,0,0]) filaCombHole();
>>>>>>> f49c02c81ad8ab46c2f2d170480c03a12e3a0fc6
		//translate([0,-8,12]) rotate([-20,0,0]) for (x=[-filaX/2:filaX/4:filaX/2]) {
		//	translate([x-otherR,-2-otherR,7]) rotate([-hAngle,0,0]) cube([otherD,otherD,holderZ+20]);
		//	}	//translate([0,0,filaDepth]) difference() {
		if (half) translate([1,-50,-1]) cube([120,120,120]);
		translate([0,0,-1]) cylinder(r=filaHoleR, h=filaDepth+2);
		translate([0,0,filaDepth]) translate([0,0,-.1]) cylinder(r1=filaHoleR,r2=bottleIR, h=filaGap+.2);
		echo("fila funnel ",funnelIR);
		}
	//	cylinder(r1=filaX/2,r2=holderOR, h=filaGap);
	//	translate([0,0,-.1]) cylinder(r1=filaHoleR,r2=bottleIR, h=filaGap+.2);
	//	}
	}

holderZ = filaDepth+filaGap+15;
holderY = -13-1;
thin = 0.5;
wide=10;
wideR=7;

hAngle=40;//23;
hOffset=14;
hGap = 0.4;
hHandle = 10;

off=-10;

combOver = 10;

module FilaAngledBottle() {
	difference() {
		union() {
			difference() {
				translate([-filaX/2,-filaY/2,0]) cube([filaX,filaY,filaDepth+filaGap]);
				for (x = [-filaX/2,filaX/2]) {
					for (y = [-filaY/2,filaY/2]) {
						translate([x,y,filaDepth/2+1]) cube([8,8,filaDepth+3], center=true);
						}
					}
				}
			for (x = [-filaX/2+4,filaX/2-4]) {
				for (y = [-filaY/2+4,filaY/2-4]) {
					translate([x,y,filaDepth/2+1/2]) cylinder(r=4, h=filaDepth+1.9, center=true);
					}
				}
			translate([0,holderY,holderZ]) rotate([45,0,0]) translate([0,off,0]) cylinder(r1=filaX/2,r2=holderOR, h=filaGap);
			translate([0,hOffset,-10]) rotate([hAngle,0,0]) cylinder(r=filaHoleR+2, h=holderZ+20);
			for (x=[-filaX/4:filaX/4:filaX/4]) {
				translate([x,-filaY/2,filaDepth+filaGap-wideR]) rotate([45,0,0]) cube([thin,wide,wide]);
				}
			}
		translate([0,hOffset,-10]) rotate([hAngle,0,0]) cylinder(r=filaHoleR, h=holderZ+20);
		filaCombHole();
		translate([0,holderY,holderZ]) rotate([45,0,0]) translate([0,0,-.1]) translate([0,off,0]) cylinder(r1=filaHoleR,r2=bottleIR, h=filaGap+.2);
		echo("fila funnel ",funnelIR);
		translate([0,holderY,holderZ]) rotate([45,0,0]) translate([0,0,filaGap]) translate([0,off,0]) cylinder(r=bottleIR,h=bottleHeight);
		translate([-20,-30,-20]) cube([40,60,20]);
		if (half) translate([1,-50,-1]) cube([120,120,120]);
		}
<<<<<<< HEAD
	translate([0,holderY,holderZ]) rotate([45,0,0]) translate([0,0,filaGap]) translate([0,off,0]) 
=======
	translate([0,holderY,holderZ]) rotate([45,0,0]) translate([0,0,filaGap]) translate([0,off,0])
>>>>>>> f49c02c81ad8ab46c2f2d170480c03a12e3a0fc6
		bottleHolder();
	}

module filaComb() {
	for (x=[-filaX/4:filaX/4:filaX/4]) {
<<<<<<< HEAD
			translate([x-otherR+hGap,-2-otherR+hGap,7+hGap]) rotate([-hAngle,0,0]) translate([0,0,abs(x)-combOver]) 
=======
			translate([x-otherR+hGap,-2-otherR+hGap,7+hGap]) rotate([-hAngle,0,0]) translate([0,0,abs(x)-combOver])
>>>>>>> f49c02c81ad8ab46c2f2d170480c03a12e3a0fc6
				cube([otherD-hGap*2,otherD-hGap*2,holderZ+combOver-abs(x)]);
		}
	translate([-filaX/2,-2-otherR+hGap,7+hGap]) rotate([-hAngle,0,0]) translate([0,0,holderZ-hHandle])cube([filaX,otherD-hGap*2,hHandle]);
	}

module filaCombHole() {
	for (x=[-filaX/2:filaX/4:filaX/2]) {
<<<<<<< HEAD
			translate([x-otherR,-2-otherR,7]) rotate([-hAngle,0,0]) translate([0,0,abs(x)-combOver]) 
=======
			translate([x-otherR,-2-otherR,7]) rotate([-hAngle,0,0]) translate([0,0,abs(x)-combOver])
>>>>>>> f49c02c81ad8ab46c2f2d170480c03a12e3a0fc6
				cube([otherD,otherD,holderZ+combOver-abs(x)]);
		}
	}

module filaCap() {
	bottleHolder();
	translate([0,0,bottleHeight]) cylinder(r=holderOR,h=thin);
	}

if (part=="threads") bottleHolder();
if (part=="neck") bottleNeck();
if (part=="funnel") funnel();
if (part=="cap") filaCap();
if (part=="fila") FilaBottle();
if (part=="angle") rotate([-90,0,0]) FilaAngledBottle();
if (part=="comb") rotate([-90,0,0]) filaComb();
if (part=="both") rotate([-90,0,0]) { FilaAngledBottle(); filaComb(); }
if (part=="both-s") { FilaBottle(); translate([0,-8,12]) rotate([-20,0,0]) filaComb(); }
