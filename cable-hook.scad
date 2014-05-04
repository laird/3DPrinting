// cable hook for running ethernet

cableD = 10;
thick=5;
nailD = 2.5;
thin=2;
tall=15;

difference() {
	cube([thin,tall,thick]);
	translate([thin/2,tall-thick/2,thick/2])
		rotate([0,90,0]) 
		cylinder(d=nailD, h=thin+2, $fn=8, center=true);
	}
translate([-cableD/2,0,0]) difference() {
	cylinder(d=cableD+thin*2, h=thick, $fn=32);
	translate([0,0,-1]) cylinder(d=cableD, h=thick+2, $fn=32);
	translate([0,0,-1]) cube([cableD/2,tall,thick+2]);
	}