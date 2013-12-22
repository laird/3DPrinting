// dishasher part 2

r=2.5;	// radius of bars
h=37-r-2.25;	// height of triangle
h2=5;	// dent in bottom
h3=12;
h4=23;
h5=32;	// height of top bar bottom
h6=-1.5;	// height at bottom of extension
w=34; wh=w/2; // inside of top of triangle
w2=49; w2h=w2/2;	// top of triangle
w3=20; w3h=w3/2; // width of bottom of triangle
w4=29; w4h=w4/2; // width of gap at top
w5=w2-12; w5h=w5/2; // width at top of gap
tab=10;
g=0.5;


t=2.25; // thickness of base
t2=10.75; // top of bar

$fn=16;

baset = 2*t+4*r;
echo(baset);



p=[[w3h,h6],[w2h,h],[w5h,h],[w4h,h4],
	[-w4h,h4],[-w5h,h],[-w2h,h],[-w3h,h6]];

echo(p);

difference() {
	union() {
		translate([0,-0.4,0]) linear_extrude(height=baset) {
			polygon(points=p, paths=[[0,1,2,3,4,5,6,7,0]]);
			}
		translate([-2*(r+t),0,baset-g]) cube([4*(r+t),h2+t,tab]);
		}
	// vertical slot
	translate([0,0,baset-t-r]) rotate([-90,0,0]) translate([0,0,h6-g]) 
		{
		cylinder(r=r+g, h=h);
		translate([-(r+g),0,0]) cube([2*(r+g),4*r,h]);
		}
	// slot across top
	translate([-w, h5, r+t]) rotate([0,90,0]) {
		cylinder(r=r+g,h=2*w);
		translate([-r,0,0]) cube([2*r,2*r+g,2*w]);
		}
	// horizontal bar
	translate([0,h2-r,t]) cylinder(r=r+g, h=h);
	translate([-(r+g),h6-g,t]) cube([2*(r+g),r-h6,h]);
	}