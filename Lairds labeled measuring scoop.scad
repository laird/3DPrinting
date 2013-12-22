//Code by Griffin Nicoll 2012
// Trivially enhanced by Laird Popkin 2012
// Customizable by Laird 2013

include <write/Write.scad> // Fonts supported by Customizer
//include <bitmap.scad> // for labeling the pieces

//Number of cups
 cups = 1;
//Tablespoons
 tbsp = 0;
//Teaspoons
 tsp = 0;
//Millilitres
 mL = 0;
//Label
label="1 cup";

//Text style
Font = "write/Letters.dxf";//["write/Letters.dxf":Basic,"write/orbitron.dxf":Futuristic,"write/BlackRose.dxf":Fancy]

//Text size scaling factor
ts=.7;

// LP: uncomment the line for the cup you want, or add your own unique cup!
// label is printed on the top and bottom of the cup
// label_len is the number of characters in the label

//cups = 1; label="1 cup"; label_len = 5;
//cups = 2; label="2 cups"; label_len = 6;
//tbsp = 2; label="2 tablespoons"; label_len = 13;
//tsp = 1; label="1 teaspoon"; label_len = 10;
//mL = 10; label = "10 mL"; label_len=5;

// Wall thickness
wall = 5; //[1:5]
// Text depth (mm) should be at least one 'slice'
print = 0.4;

//stuff you don't need to edit
sq = 1.2*1; //squeeze
sh = 0.16*1; //shear
pi = 3.14159*1;
volume = cups*236588+tbsp*14787+tsp*4929+1000*mL;//mm^3

// for labeling
x = ts*pow(volume/(570*pi),1/3);
echo (str("x is ",x));
//cube=x/(label_len);
//echo (str("cube is ",cube));
off=label_len*cube*4;
echo (str("off ",off));

difference(){
	minkowski(){
		cylinder(r1=0,r2=wall,h=wall,$fn=6);
		cupBase(volume);
	}
	translate([0,0,wall+0.02])cupBase(volume);
	rotate([180,0,90]) translate([0,-off,-print]) scale([x,x,1]) write(label, center=true, rotate=90);
//8bit_str(label, label_len, cube, wall);
}

translate([0,0,wall]) rotate([0,0,90]) translate([0,-off,wall-print]) scale([x,x,1]) write(label, center=true, rotate=90);

//rotate([0,0,90]) translate([0,-off,wall]) scale([2,2,2]) write(label, center=true, rotate=90);
//8bit_str(label, label_len, cube, wall);

module cupBase(volume){
	x = pow(volume/(570*pi),1/3);
	multmatrix(m=[
		[sq, 0, sh, 0],
		[0, 1/sq, 0, 0],
		[0, 0, 1, 0],
		[0, 0, 0,  1]])
	cylinder(h=10*x,r1=6*x,r2=9*x,$fn=64);
}