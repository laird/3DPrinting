/* OpenSCAD code to create a dice game.  Games is slid across hand or other surface to randomized die.  Center dice value is added to one exterior dice to create a target value.  Values of the remaining five die can then be used with any mathematical operators to equate to target value. */

//No rights reserved.  Released into the public domain.

c=0; // 1 = black, 2=white, 0=all

//User editable variables
Hex = 70; // Tip to tip in mm
tall = 15; //Height of game
fillet = 2; //Size of fillet on outer edges of game holder and on dice
dice_side = 16; //size of dice (must be larger than tall)
min_wt = 1; // minimum wall thickness
dice_clearance = 0.7; 
font_height = 10;



//Do not edit below unless you want to experiment and follow good save-as practices. :-)
include <bitmap.scad>

//===============Calculations===============//
dice_sphere_radius= 0.85*dice_side-fillet;
hole_sphere_radius = dice_sphere_radius+dice_clearance;
holder_radius = hole_sphere_radius+2*min_wt;


//===============Start of parts===============//

//Game Body

module game_body() {

	difference(){
		union(){
	
		//Center Mass with radiused edges
			cylinder_with_fillet(Hex/2, tall, fillet, 80);
	
		//Outside Holders with radiused edges
			for(i = [0:5]){
				translate([Hex/2*sin(360*i/6),Hex/2*cos(360*i/6),0])
				cylinder_with_fillet(holder_radius, tall, fillet, 40);
			}
		}
		
		//Outside Holes
			for(i = [0:5]){
				translate([Hex/2*sin(360*i/6),Hex/2*cos(360*i/6),tall/2])
				sphere(r=hole_sphere_radius, center = false);
			}
	
		//Center Hole
			translate([0,0,tall/2])	sphere(r=hole_sphere_radius, center = true); 
	}
}

if ((c==1) || (c==0)) {
	game_body();
	}

//Outside Die

if (c==0) {
	translate([Hex/2*sin(360*0/6),Hex/2*cos(360*0/6),dice_side/2]) 
		dice(dice_side, dice_sphere_radius);
	for(i = [1:5]){
		translate([Hex/2*sin(360*i/6),Hex/2*cos(360*i/6),dice_side/2]) 
			dice(dice_side, dice_sphere_radius);
	}
}

if (c==2) {
	translate([Hex/2*sin(360*0/6),Hex/2*cos(360*0/6),dice_side/2]) 
		dice_nums(dice_side, dice_sphere_radius);
	for(i = [1:5]){
		translate([Hex/2*sin(360*i/6),Hex/2*cos(360*i/6),dice_side/2]) 
			dice(dice_side, dice_sphere_radius);
	}
}

if (c==1) {
	translate([Hex/2*sin(360*0/6),Hex/2*cos(360*0/6),dice_side/2])
		dice(dice_side, dice_sphere_radius);
	for(i = [1:5]){
		translate([Hex/2*sin(360*i/6),Hex/2*cos(360*i/6),dice_side/2])
			dice_nums(dice_side, dice_sphere_radius);
	}
}

//Center Dice

if ((c==0) || (c==1)) {
	translate([0,0,dice_side/2]) center_dice(dice_side, dice_sphere_radius);
}

if (c==2) {
	translate([0,0,dice_side/2]) center_dice_nums(dice_side, dice_sphere_radius);
}

//=================End of parts===============//


//===================Fit Test===============//
/*
difference(){
	cylinder_with_fillet(holder_radius, tall, fillet, 40);
	translate([0,0,tall/2])	sphere(r=hole_sphere_radius, center = true); 
}
translate([0,0,dice_side/2]) center_dice(dice_side, dice_sphere_radius);
*/

//===================Modules================//

//Standard Dice cut with spherical corners (not evenly weighted)
module dice(dice_side, dice_sphere_radius){
	difference(){
		cube(dice_side, center=true);
		difference(){
			sphere(r=1.5*dice_side, center=true);
			sphere(r=dice_sphere_radius, center=true);
			}
		dice_nums(dice_side, dice_sphere_radius); // subtract the numbers from the dice
	}
}

//Numbers for the dice
module dice_nums(dice_side, dice_sphere_radius){
		translate([0,0,-dice_side/2-.1+1])rotate([180,0,0])8bit_char("1",font_height/8, 1);
		translate([0,0,dice_side/2+.1-1])rotate([0,0,180])8bit_char("6",font_height/8, 1);
		translate([0,-dice_side/2-.1+1,0])rotate([90,180,0])8bit_char("2",font_height/8, 1);
		translate([0,dice_side/2+.1-1,0])rotate([270,0,0])8bit_char("5",font_height/8, 1);
		translate([-dice_side/2-.1+1,0,0])rotate([0,270,0])8bit_char("3",font_height/8, 1);
		translate([dice_side/2+.1-1,0,0])rotate([0,90,0])8bit_char("4",font_height/8, 1);
	}

//Dice cut with spherical corners and multiples of 10
module center_dice(dice_side, dice_sphere_radius){
	difference(){
		cube(dice_side, center=true);
		difference(){
			sphere(r=1.5*dice_side, center=true);
			sphere(r=dice_sphere_radius, center=true);
			}
		center_dice_nums(dice_side, dice_sphere_radius); // subtract face numbers
	}
}

// face numbers for above
module center_dice_nums(dice_side, dice_sphere_radius){
	translate([0,0.3*font_height,-dice_side/2-.1+1])rotate([180,0,0])8bit_char("1",font_height/12, 1);
	translate([0,-0.3*font_height,-dice_side/2-.1+1])rotate([180,0,0])8bit_char("0",font_height/12, 1);
	translate([0,0.3*font_height,dice_side/2+.1-1])rotate([0,0,180])8bit_char("6",font_height/12, 1);
	translate([0,-0.3*font_height,dice_side/2+.1-1])rotate([0,0,180])8bit_char("0",font_height/12, 1);
	translate([0,-dice_side/2-.1+1,0.3*font_height])rotate([90,180,0])8bit_char("2",font_height/12, 1);
	translate([0,-dice_side/2-.1+1,-0.3*font_height])rotate([90,180,0])8bit_char("0",font_height/12, 1);
	translate([0,dice_side/2+.1-1,0.3*font_height])rotate([270,0,0])8bit_char("5",font_height/12, 1);
	translate([0,dice_side/2+.1-1,-0.3*font_height])rotate([270,0,0])8bit_char("0",font_height/12, 1);
	translate([-dice_side/2-.1+1,-0.3*font_height,0])rotate([0,270,0])8bit_char("3",font_height/12, 1);
	translate([-dice_side/2-.1+1,0.3*font_height,0])rotate([0,270,0])8bit_char("0",font_height/12, 1);
	translate([dice_side/2+.1-1,-0.3*font_height,0])rotate([0,90,0])8bit_char("4",font_height/12, 1);
	translate([dice_side/2+.1-1,0.3*font_height,0])rotate([0,90,0])8bit_char("0",font_height/12, 1);
}

//Cylinder with rounded edges
module cylinder_with_fillet(cr, h, f, sides){
	difference(){	
		cylinder(r=cr, h=h,$fn=sides);
		translate([0,0,-.1])
		rotate_extrude(convexity = 10, $fn=sides){	
			difference(){
				translate([cr-f+.1,0,0])square(f);
				translate([cr-f+.1,f,0])circle(r=f);
			}
		}		
		translate([0,0,h-f+.1])
		rotate_extrude(convexity = 10, $fn=sides){
			difference(){
				translate([cr-f+.1,0,0])square(f);
				translate([cr-f+.1,0,0])circle(r=f);
			}
		}
	}
}