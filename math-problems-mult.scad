// Codes by Andy Ide
// www.3dfuture.com.au
// January 2012
// Many many thnaks to HarlanDMii for his excelletn Write Module
// His site is http://www.thingiverse.com/thing:16193


// You need Write.scad for this script to run.
// Get it from http://www.thingiverse.com/thing:16193
use<write.scad>

c=0; // 0=both, 1=black, 2=white

xspace = 40;
yspace = 20;
gap=1;
l=1;
b=1;
g=0.01;

// Thickness of the border
border=2; 
ch = 2; // height of card
chh = ch/2;

// Space between the Letters and the border
spacing=1; 

// How big the letters are
textheight=15;

// The space between the letters.
letterspace = .95;

module annotate(x, y) {
	translate([l,b,chh+g]) write(str(x,"x",y), t=chh-g, h=textheight, space=letterspace);
	translate([20,0,chh]) translate([l,b,0]) rotate([0,180,0]) 
		write(str(x*y),t=chh+g,h=textheight,space=letterspace);	
	}

module card(x, y) {
	assign (xp = x*xspace, yp=y*yspace) {
		if ((c==0) || (c==2)) {
			color("white") {
				translate([xp,yp,0]) difference() {
					cube([xspace-gap,yspace-gap,ch]);
					annotate(x,y);
					}
				}
			}
		if ((c==0) || (c==1)) {
			color("black") {
				translate([xp,yp,0]) annotate(x,y);
				}
			}
		}
	}

translate([-90,-50,0]) scale(0.5) 
translate([-xspace,-yspace,0]) 
for (a = [1:9]) {
	for (b = [1:9]) {
		card(a,b);
		}
	}