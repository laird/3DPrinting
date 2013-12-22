// Customizable Replicator Bed Adjustment Clip

// How long a clip do you need, in mm? (50 fits Replicator)
len = 50;
// How much do you want the clip to lower the Replicator print bed?
height=6.25;
// How thick should the clip "wings" be?
t=1;
// How much should the "wings" stick up?
tail=10;
// How thick is the board it clips around, plus a little clearance?
around=7;	

width=around+2*t;

translate([-len/2,-width/2,0]) 
difference() {
	cube([len,width,height+tail]);
	translate([0,t,height]) cube([len,around,tail]);
	}