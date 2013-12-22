// dishwasher thingie

height=90;
radius=2.5;
gap = 35;
narrow = 32;
wide = 42;

angle=22.5;
echo(cos(angle));

cr = cos(angle)*radius;	// 'inside radius' of octagon

$fn=8;	// make them octogons so easily printable

px=[0,gap,2*gap,3*gap,3*gap+narrow,3*gap+narrow+wide,4*gap+narrow+wide];

for (x=px) {
	translate([x,0,0]) {
		rotate([0,0,22.5]) cylinder(h=height,r=radius);
		translate([-cr,-cr,0]) 
			cube([2*cr,2*cr,2*cr]);
		translate([0,cr,height]) rotate([90,0,0]) cylinder(r=radius,h=2*cr);
		}
	}

rotate([0,90,0]) translate([0,0,-radius]) rotate([0,0,22.5]) cylinder(h=4*gap+narrow+wide+2*radius, r=radius);