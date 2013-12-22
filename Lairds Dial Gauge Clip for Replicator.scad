// Dial Gauge (Harbor Freight/Pittsburg item 623) clip

// Modified by Laird Popkin <laird@popk.in> to fit the Pittsburg Travel Machinist's 
// Dial Indicator, item 623 (as sold by Harbor Freight).

// First, install the guage into the clip. To do this, first put the end of the probe through the guide hole
// in the triangle at the bottom of the clip, then put the log back (the hoop on the back of the dial) into the
// slot at the top of the clip, and hold in place with an M4 bolt (e.g. M4-30 or longer) and an M4 nut.

// It clips to the front of the Makerbot Replicator carriage. The top hooks over the fans, and the bottom then
// snaps under the bottom of the carriage. This puts the dial guage vertical, with the dial facing the front 
// so that it is easily readable, with the probe just below the level of the extruders.

// If you're running the Sailfish firmware, the "level build plate" command moves the build plate up into
// position, and disengages the X and Y stepper motors, allowing you to move the extruder carriage freely.

// Adjust the print bed to the proper height in the center, ideally using a feeler guage (0.001 in), then
// move the probe there and set the 'zero' of the dial indicator to that position. Then move the guage around 
// the print bed and adjust the print bed's height to be 'zero' on the guage. 

width = 24;
height=55;
shaftrad = 3; //2.15;  // this gave a slip fit on mine, might go 2.1 or less for a friction fit.
				 // or whatever fits your guage.
shaftx = 12;	// position of shaft in front of origin
hoopthickness = 6.5; // thickness of hoop on back of gauge
hoopheight = 20;	// height of hoop on back of gauge
boltrad = 2.3;		// size of bolt through back of gauge
t=1;					// thickness of walls around hook
t2=3;					// thickness around guide hole

// vertical sections and bottom clip
cube (size = [3, height, width]);
translate ([-2.5, 18, 0]) cube (size = [3, 35, width]);
translate ([-3, 0, 0]) cube (size = [7, 2, width]);
// these two bumps help retain the fixture
translate ([-2.27, 2, 8]) sphere (r = .5, $fn = 20);
translate ([-2.27, 2, width - 8]) sphere (r = .5, $fn = 20);

difference () {
// top clip
	translate ([-15.25, 52, 0]) cube (size = [17.5, 3, width]);
	// slanting the top clip
	translate ([-15.25, 53.5, 0]) rotate (a = [0, 0, 7]) cube (size = [18.5, 3, width]);
	// these 3mm holes could be used for set screws if the fixture is loose
	//translate ([-5, 58, 17]) rotate (a = [90, 0, 0]) cylinder (h = 10, r = 1.5, $fn = 20);
	//translate ([-5, 58, 7]) rotate (a = [90, 0, 0]) cylinder (h = 10, r = 1.5, $fn = 20);
}

// top clip hook
translate ([-14.5, 50.5, 0]) cylinder (h = width, r = .75, $fn = 20);
translate ([-15.25, 50.5, 0]) cube (size = [1.5, 3, width]);

difference () {
// guage mount
	// main block
	translate ([0, 0, 0]) cube (size = [shaftx+shaftrad+t2, 2, width]);
	// vertical hole for guage
	translate ([shaftx, -1, 12]) rotate (a = [-90, 0, 0]) cylinder (h = 17, r = shaftrad, $fn = 20);
	// trim the excess corners of the block
	translate ([shaftx-7+t2, -1, 0]) rotate (a = [0, 45, 0]) cube (size = [20, 20, 20]);
	translate ([shaftx-7+t2, -1, width]) rotate (a = [0, 45, 0]) cube (size = [20, 20, 20]);	
	// set screw hole, for 3mm screw
	translate ([shaftx, 5, width / 2]) rotate (a = [0, 90, 0]) cylinder (h = 10, r = 1.5, $fn = 20);
}

echo(hoopheight,hoopheight,width);
translate([-hoopheight+3,55,0]) difference() {
	union () {
		translate([hoopheight/2,0,0]) cube([hoopheight/2,hoopheight,width]);
		translate([hoopheight/2, hoopheight/2, 0]) cylinder(r=hoopheight/2, h=width, $fn=20);
		}
	translate([(width-hoopthickness)/2,t,(width-hoopthickness)/2]) cube([hoopheight,hoopheight-2*t,hoopthickness]);
	translate([hoopheight/2,hoopheight/2,-1]) cylinder(r=boltrad, h=width+2, $fn=20);
	translate([hoopheight/2, hoopheight/2, (width-hoopthickness)/2]) cylinder(r=hoopheight/2-t, h=hoopthickness);
	}

//translate([-20,73,13.5]) rotate([90,180,0]) import("Dial_Indicator_Mount_V2_Part.stl");