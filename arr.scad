use <write/Write.scad>;
$fn=32;

wide=10;
tall=4;
thick=1;

scale(5) {
difference() {
union() {
translate([0,0,-thick/4]) cube([wide,tall,thick/2], center=true);
translate([.1,0,0]) scale([.95,1,1]) write("WOW", center=true);

//translate([0,2.4,0]) rotate([0,90,0]) rotate([0,0,360/8])
//cylinder(r=.6, h=10,$fn=4, center=true);
//translate([0,-2.4,0]) rotate([0,90,0]) rotate([0,0,360/8])
//cylinder(r=.6, h=10,$fn=4, center=true);
//translate([4.43,0,0]) rotate([90,0,0]) rotate([0,0,360/8])
//cylinder(r=.6, h=5,$fn=4, center=true);
//translate([-4.43,0,0]) rotate([90,0,0]) rotate([0,0,360/8])
//cylinder(r=.6, h=5,$fn=4, center=true);

translate([5,0,0]) cylinder(r=1,h=1,center=true);
translate([-5,0,0]) cylinder(r=1,h=1,center=true);

translate([0,2.4,0])
cube([wide,thick,1], center=true);
translate([0,-2.4,0])
cube([wide,thick,1], center=true);

translate([4.5,0,0]) 
cube([1,tall,1], center=true);
translate([-4.5,0,0]) 
cube([1,tall,1], center=true);

}
translate([0,0,-1]) cube([20,20,1], center=true);
translate([5,0,0]) cylinder(r=.5,h=1,center=true);
translate([-5,0,0]) cylinder(r=.5,h=1,center=true);
}
}