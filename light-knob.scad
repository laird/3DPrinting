// make a slider

pw = 2; //mm width of prong
ph = 6; //mm height of prong
pd = 12; //mm depth of prong into button
dd = 6.5; // mm depth of'dents' from end of prong
bw = 46; //mm width of button
bh = 15; //mm height of button

// To Do:
// draw knob
// shape 1 is a "cube"
// shape 2 is a cylinder
// shape 3 is a sphere

module knob(shape) {

if (shape == 1) {
// square button
cube([bw, bh, bh], center=true);
}

if (shape == 2) {
// cylinder button
rotate([0,90,0]) cylinder(r=bh/2, h=bw, center=true);
}

if (shape == 3) {
sphere(r=bh/2);
}

// add label to button
}

module prong() {
translate([0,0,0-(bh-pd)/2]) {
difference() {
cube(size=[pw, ph, pd], center=true);
// snaps
translate ([-0.1,0-ph/2,pd/2-dd]) rotate ([0,90,0]) cylinder(h=ph+0.2, r=1, center=true);
translate ([-0.1,ph/2,pd/2-dd]) rotate ([0,90,0]) cylinder(h=ph+0.2, r=1, center=true);}
}
}

module d_knob(shape) {
difference() {
knob(shape);
#prong();
}
}

d_knob(3);
//prong();