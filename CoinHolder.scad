// coin holder

// inspired by http://www.thingiverse.com/thing:9116/#comments

use <write/Write.scad>;

/* [General] */

//Number of coin slots
numSlots = 5; // [1:8]
coin1 = 1; // [0:None, 1:US Dollar, 2:US half dollar, 3:US quarter, 4:US dime, 5:US nickle, 6:US penny, 7:euro cent, 8:2 euro cents, 9:5 euro cents, 10:10 euro cents, 11:20 euro cents, 12:50 euro cents, 13:1 euro, 14:2 euros]
coin2 = 4; // [0:None, 1:US Dollar, 2:US half dollar, 3:US quarter, 4:US dime, 5:US nickle, 6:US penny, 7:euro cent, 8:2 euro cents, 9:5 euro cents, 10:10 euro cents, 11:20 euro cents, 12:50 euro cents, 13:1 euro, 14:2 euros]
coin3 = 3; // [0:None, 1:US Dollar, 2:US half dollar, 3:US quarter, 4:US dime, 5:US nickle, 6:US penny, 7:euro cent, 8:2 euro cents, 9:5 euro cents, 10:10 euro cents, 11:20 euro cents, 12:50 euro cents, 13:1 euro, 14:2 euros]
coin4 = 5; // [0:None, 1:US Dollar, 2:US half dollar, 3:US quarter, 4:US dime, 5:US nickle, 6:US penny, 7:euro cent, 8:2 euro cents, 9:5 euro cents, 10:10 euro cents, 11:20 euro cents, 12:50 euro cents, 13:1 euro, 14:2 euros]
coin5 = 6; // [0:None, 1:US Dollar, 2:US half dollar, 3:US quarter, 4:US dime, 5:US nickle, 6:US penny, 7:euro cent, 8:2 euro cents, 9:5 euro cents, 10:10 euro cents, 11:20 euro cents, 12:50 euro cents, 13:1 euro, 14:2 euros]
coin6 = 0; // [0:None, 1:US Dollar, 2:US half dollar, 3:US quarter, 4:US dime, 5:US nickle, 6:US penny, 7:euro cent, 8:2 euro cents, 9:5 euro cents, 10:10 euro cents, 11:20 euro cents, 12:50 euro cents, 13:1 euro, 14:2 euros]
// Scale of text
scale = 2;
// Part to display
part = 1; //[1:Preview, 2:Coin Holder, 3:Plungers, 4:Cover, 5:Plated]

/* [Cup Holder] */

// width of your cup holder (mm)
cupHolderWidth = 75;
cupHolderR = cupHolderWidth/2;
// depth of your cup holder
cupHolderDepth = 50;
// Spring width
springWidth = 10;
// cupHolderFloor (mm)
cupHolderFloor = 5;
// Top lip to hold coins in
lip = 2;

/* [Tweaks] */
// Clearance, adjust to suit your printer
clearance = 0.4;
// Chop into coin holder to see how it assembles
chop = 0; //[0:Whole, 1:Hole]

/* [Hidden] */

$fn=64;
coin=[coin1,coin2,coin3,coin4,coin5,coin6];
echo("coin ",coin);

// coin definitions, from WikiPedia and
// Some from http://www.air-tites.com/coin_size_chart.htm
// Some from http://www.usmint.gov/about_the_mint/?action=coin_specifications

coinName = ["None", "$1", "50", "25", "10",
	"5", "1",
	"1", "2", "5", "10",
	"20", "50", "E", "2E"];
coinSize = [0, 26.49, 30.6, 24.3, 17.9,
	20, 19,
	16.25,18.75,21.25,19.75,
	22.25,24.25, 23.25, 25.75, 29];
coinHeight = [0,2,2.15,1.75,1.35,1.95,1.55,
	1.67, 1.67, 1.67, 1.93,
	2.14, 2.38, 2.33, 2.20];

wall = 2; // wall thickness
clearance = 0.4;
gap = 0.01; // to make surfaces not perfectly aligned

// computations

slotHeight = cupHolderDepth-wall;
springR = springWidth/2;

// modules

module CoinSlot(coin) {
	union() {
		cylinder(r=coinSize[coin]/2+clearance, h=slotHeight+1);
		}
	}

module CoinSlotPlunger(c) {
	difference() {
		cylinder(r=coinSize[c]/2, h=cupHolderDepth/2);
		translate([0,0,-1]) cylinder(r=springR, h=cupHolderDepth/2-wall);
		translate([0,0,cupHolderDepth/2-.49]) scale([scale,scale,1]) write(coinName[c], center=true);
		}
	}

module coinHolder() {
	echo("start");
	difference() {
		cylinder(r=cupHolderR-clearance,h=cupHolderDepth);
		for (c=[0:numSlots-1]) {
			assign (a=c*360/numSlots) {
				echo("coin",c,"is ",coinName[coin[c]]);
				rotate([0,0,a])
					translate([cupHolderR-coinSize[coin[c]]/2-wall,0,cupHolderFloor]) {
					CoinSlot(coin[c]);
					translate([coinSize[coin[c]]/2,0,
					          cupHolderDepth-cupHolderFloor-coinHeight[coin[c]]+2*clearance])
						cube([coinSize[coin[c]]+2*clearance,
						     coinSize[coin[c]]+2*clearance,
						     1.5*coinHeight[coin[c]]+2*clearance], center=true);
					}
				}
			}
		}
	// add cones to keep the springs centered in the coin slots
	for (c=[0:numSlots-1]) {
		assign (a=c*360/numSlots) {
			echo("coin",c,"is ",coinName[coin[c]]," angle ",a);
			rotate([0,0,a]) translate([cupHolderR-coinSize[coin[c]]/2-wall,0,cupHolderFloor]) {
						cylinder(r1=springR*0.9,r2=springR/2,h=springR);
				}
			}
		}
	cylinder(r=cupHolderR/7, h=cupHolderDepth+wall+clearance, $fn=3);
	cylinder(r=cupHolderR/7, h=cupHolderDepth+wall+clearance, $fn=4);
	}

// circle of plungers
module coinPlungers(extra) {
	for (c=[0:numSlots-1]) {
		assign (a=c*360/numSlots) {
			echo("coin",c,"is ",coinName[coin[c]]," angle ",a);
			rotate([0,0,a])
				translate([cupHolderR-coinSize[coin[c]]/2-wall+extra,0,cupHolderDepth/2-cupHolderFloor-2*clearance]) {
					CoinSlotPlunger(coin[c]);
					}
			}
	 	}
	 }

module cover() {
	difference() {
		cylinder(r=cupHolderR, h=wall);

		for (c=[0:numSlots-1]) {
			assign (a=c*360/numSlots) {
				rotate([0,0,a])
					translate([cupHolderR-coinSize[coin[c]]/2-wall-lip,0,-1]) {
					cylinder(r=coinSize[coin[c]]/2-lip+clearance, h=wall+2);
					translate([coinSize[coin[c]]/2+2*lip,0,
					          (2*coinHeight[coin[c]]+wall+2*clearance)/2])
						cube([coinSize[coin[c]]+2*lip+2*clearance,
						     coinSize[coin[c]]-2*lip+2*clearance,
						     2*coinHeight[coin[c]]+wall+2*clearance], center=true);
					}
				}
			}
		translate([0,0,-1]) cylinder(r=cupHolderR/7+clearance, h=wall+2, $fn=3);
		translate([0,0,-1]) cylinder(r=cupHolderR/7+clearance, h=wall+2, $fn=4);
		}
	}

module assembled() {
	coinHolder();
	translate([0,0,cupHolderFloor]) coinPlungers(0);
	translate([0,0,cupHolderDepth+clearance]) cover();
	}

module plated() {
	coinHolder();
	translate([cupHolderWidth+5,0,0]) rotate([180,0,0]) translate([0,0,-cupHolderDepth+cupHolderFloor+clearance*2]) coinPlungers(wall);
	translate([-cupHolderWidth-5,0,0]) cover();
	}

part=5;
difference() {
	if (part==1) assembled();
	if (part==2) coinHolder();
	if (part==3) rotate([180,0,0]) translate([0,0,-cupHolderDepth+cupHolderFloor+clearance*2]) coinPlungers(wall);
	if (part==4) cover();
	if (part==5) plated();
	if (chop) cube([200,200,200]);
	}