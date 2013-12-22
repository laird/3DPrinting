use <write/Write.scad>
use <utils/build_plate.scad>	 // build plate

// Text on Buckle
buckleText="<3";
// Font
Font = "write/Letters.dxf";//["write/Letters.dxf":Basic,"write/orbitron.dxf":Futuristic,"write/BlackRose.dxf":Fancy]
// Font size
fontSize = 15;
// Font scaling. <1 is narrower, >1 is wider
fontScaling = 1;
// Font spacing. <1 is tighter, >1 is looser
fontSpacing = 1;

// number of rows of links to print
rows=1;

// End with a clip (so the end clips to the other end) or an X (for using a buckle).
endShape = 2;//[1:Clip, 2:X Link]

// Cut a sphere on the buckle?
bsphere=1*1; // [0:No sphere, 1:Sphere]
	
// Shape, full belt, buckle, or previews
printShape = 4;//[2:Belt, 5:Buckle, 6:Belt & Buckle, 1:Test links, 3:X Link, 4:Preview Buckle]

// Show length of belt (show for configuring, hide for printing)
sl=1*1; // [0:Hide, 1:Show]

// Radius of pivot bars	
ir=2*1;
		
// gap between bar and enclosing shape to provide smooth rotation
g=0.75;
			
// Number of sides to cylinders (smoother is slower to render, any resolution will work)
sides=8;	// [6:hexagons, 8:octagons, 16:round, 32:super-smooth]

// Print whole or half belt
half=0; // [0:Whole, 1:Slice through belt to check alignments]

// Width of the belt (height of links)
h=30*1;				
or=ir+g;			// radius of cylinder around bar
// Thickness of the belt (width of links)
oor=4*1;			
round=1*1;
octagon=2*1;
// Shape of links
shape=1*1; // [1:Round, 2:Octagon]	
// roundness of round links: 1 - round, 0.1 is extremely skinny, 0.7 is what I use. If you change this, make sure you preview the belt carefully to make sure that the links don't intersect.
ooratio = 1.1*1;	
// spacing between links (if you change this, be prepared for advanced tweaking)
s=13*1;				
// radius on corners of rectangle links
m=2*1;				
oorm=oor-m/2;	// inner rectangle width for minkowski for rectangle links
irm=ir-m;			// inner rectangle height "
// number of links in a row. Adjust this to fit your build platform
numlinksinrow=12*1;		
rl=numlinksinrow*s; 	// row length
// spacing between rows in 'snake', must be correct to align rows properly. If you change the spacing or number of links, you have to tweak (or calculate) this to get an exact fit.
rw=35.5*1;			
// Angle to use to pack rows closer together
angle=3*1;

numrows=rows-1;

linksnake=numlinksinrow*2+8;
links=(numrows+1)*linksnake+numlinksinrow;
length=(links-1)*s+h;

$fn=sides;	

echo ("number of links is ",links,".");
echo ("length is ",length," mm or ", length/24," inches.");

//for display only, doesn't contribute to final object
build_plate_selector = 0; //[0:Replicator 2,1: Replicator,2:Thingomatic,3:Manual]

//when Build Plate Selector is set to "manual" this controls the build plate x dimension
build_plate_manual_x = 100; //[100:400]

//when Build Plate Selector is set to "manual" this controls the build plate y dimension
build_plate_manual_y = 100; //[100:400]

// End Customizer params

module bar() {
	if (shape==round) {
		translate([0,0,-2*ir]) scale([1,ooratio,1]) cylinder(r=oor,h=h,$fn=16);
		}
	else {
		translate([-oorm,-irm,-2*ir]) minkowski() {
			cube([2*oorm,2*irm,2*h]);
			cylinder(r=m, h=1, $fn=8);
			}
		}
	}

module x() {
	difference() {
		union() {
			cylinder(r=ir, h=h, $fn=sides);
			translate([0,-h,0]) cylinder(r=ir, h=h, $fn=sides);
			rotate([45,0,0]) scale([1,1,2]) bar();
			}
		union() {
			//translate([-1.5*oor,-2*oor,-1.5*oor]) cube([s+2*oor,4*oor,1.5*oor]);
			//translate([-1.5*oor,-2*h,h]) cube([s+2*oor,2*oor+2*h,h/2+g]);
			}
		}
	}

module v() {
	difference() {
		union() {
			cylinder(r=ir, h=h, $fn=sides);
			rotate([45,0,0]) bar();
//				if (shape==round) {
//					translate([0,0,-2*ir]) scale([1,ooratio,1]) cylinder(r=oor,h=h, $fn=16);
//					}
//				else {
//					translate([-oorm,-irm,-ir]) minkowski() {
//						cube([2*oorm,2*irm,h]);
//						cylinder(r=m, h=1, $fn=8);
//						}
//					}
			}
		union() {
			//translate([-1.5*oor,-oor,-1.5*oor]) cube([s+2*oor,2*oor,1.5*oor]);
			translate([-1.5*oor,-oor-h,h/2]) cube([s+2*oor,2*oor+h,h/2+g]);
			translate([0,-s,0]) cylinder(r=or,h=h, $fn=32);
			}
		}
	}

module vblock() {
	v();
	translate([0,0,h]) rotate([0,180,0]) v();
	}

module xblock() {
	x();
	translate([0,0,h]) rotate([0,180,0]) x();
	}

module cblock() {
	difference() {
		union() {
			v();
			translate([0,0,h]) rotate([0,180,0]) v();
			}
		translate([0,-s-ir+g,0]) cube([oor,2*(ir)-g,h]);
		}
	}

module vrow() {
	for ( i = [0 : s : rl] ) {
		translate([0,-i,0]) vblock();
		}
	}

module oswoop() {
translate([0,rl+2*s,0]) vrow();
translate([0,s,0]) vblock();
rotate([0,0,45]) {
	vblock();
	translate([0,-s,0]) rotate([0,0,45]) {
		vblock();
		translate([0,-s,0]) rotate([0,0,45]) {
			vblock();
			translate([0,-s,0]) rotate([0,0,45]) {
				vblock();
				translate([0,-s,0]) vrow();
				translate ([0,-rl-2*s,0]) rotate([0,0,-45]) {
					vblock();
					translate([0,-s,0]) rotate([0,0,-45]) {
						vblock();
						translate([0,-s,0]) rotate([0,0,-45]) {
							vblock();
							}
						}
					}
				}
			}
		}
	}
}

module swoop() {
translate([0,rl+2*s,0]) vrow();
translate([0,s,0]) vblock();
rotate([0,0,60]) {
	vblock();
	translate([0,-s,0]) rotate([0,0,60]) {
		vblock();
		translate([0,-s,0]) rotate([0,0,60]) {
			vblock();
			rotate([0,0,angle]) translate([0,-s,0]) vrow();
			translate ([9.5,-rl-2*s+.4,0]) rotate([0,0,-60]) {
				vblock();
				translate([0,-s,0]) rotate([0,0,-60]) {
					vblock();
					}
				}
			}
		}
	}
}



bucklex=3*1;
buckley=5*s+oor+6;
bucklez=h;

module buckle() {
	translate([bucklex/2,buckley/2,bucklez/2]) {
		color("white") rotate([90,0,0]) rotate([0,90,0]) scale([fontScaling,1,1]) 
			write(buckleText,h=fontSize,t=3, space=fontSpacing, center=true, font=Font);
		echo(buckleText);
		}
	difference() {
		union() {
			cube([bucklex,buckley,bucklez]);
			translate([-oor-3,0,h/3]) cube([oor+3,oor+3,h/3]);
			translate([-oor-3,5*s+3,h/3]) cube([oor+3,oor+3,h/3]);
			}
		union() {
			translate([-or,oor+3,0]) cylinder(h=h,r=or);
			translate([-or,5*s+3,0]) cylinder(h=h,r=or);
			rotate([45,0,0]) translate([-10,-s+or,-15]) cube([20,20,30]);
			translate([0,6*s-3,0]) rotate([-45,0,0]) translate([-10,-s+or,-15]) cube([20,20,30]);
			if (bsphere) translate([bucklex,buckley/2,bucklez/2]) scale([.2,2,1]) sphere(h/2*.9, $fn=32);
			translate([0,0,h]) scale([1,1,-1]) union() {
				rotate([45,0,0]) translate([-10,-s+or,-15]) cube([20,20,30]);
				translate([0,6*s-3,0]) rotate([-45,0,0]) translate([-10,-s+or,-15]) cube([20,20,30]);
				}
			}
		}
	}

module snake() {
	for ( j = [0:rw:numrows*rw]) {
		translate([j,0,0]) swoop();
		}
	translate([(1+numrows)*rw,rl+2*s-0.4,0]) vrow();
	translate([(1+numrows)*rw,s,0]) {
		if (endShape==1) cblock();
		if (endShape==2) xblock();
		}
	}

// And print the belt

printShape=6;

translate([-90,20,0]) rotate([0,0,-90])
difference() {
	union() {
		if ((printShape==2) || (printShape==6)) {
			snake();
			if (printShape==6) 
				translate([45+rw*numrows,0,0]) translate([0,0,3]) rotate([0,90,0]) buckle();
			}
		if (printShape==1) {
			vblock();
			//translate([0,-s,0]) rotate([0,0,60]) xblock();	
			translate([0,-s,0]) vblock();	
			translate([0,s,0]) cblock();	
			translate([0,-2*s,0]) rotate([0,0,60]) cblock();
			}
		if (printShape==3) xblock();
		if (printShape==4) {
			vblock();
			translate([0,-s,0]) vblock();
			translate([0,7*s,0]) xblock();
			translate([0,8*s,0]) vblock();
			translate([or,-oor-3,0]) buckle();
			}
		if (printShape==5) {
			translate([0,0,3]) rotate([0,90,0]) buckle();
			}
		}
	translate([-200,-200,-h]) cube([400,400,h]); // clip top of belt
	if (half) translate([-200,-200,h/2]) cube([400,400,h]);	// chop in half to check alignments
	translate([-200,-200,h]) cube([400,400,h]); // clip bottom of belt
	}

label=str(links," links ",length," mm = ",floor(length/.245)/100," inches.");
echo(label);
if (sl) 
	%translate([0,-50-rw*numrows,0]) 
		write(label,h=10,t=1, space=1, center=true, font="write/Letters.dxf");

build_plate(build_plate_selector,build_plate_manual_x,build_plate_manual_y);
