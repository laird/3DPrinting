toeSize = 18;
bigToeSize = 23;
length = 35;
t = 0.7;
pad=1;
angle = 0;
$fn=64;

module toe(size) {
	difference() {
		cylinder(r=size/2+t, h=length);
		translate([0,0,pad]) cylinder(r=size/2, h=length);
		}
	}

module toeDis() {
	 rotate([0,-angle,0]) toe(toeSize);
	 translate([toeSize+t,0,0])  rotate([0,-angle,0]) toe(toeSize);
	 translate([1.5*toeSize+1.35*bigToeSize/2+2*t,0,0]) rotate([0,-angle,0]) scale([1.35,1,1]) toe(bigToeSize);
	cubeX = toeSize*2+1.25*bigToeSize+4*t;
	cubeY = bigToeSize+2*t;
	//translate([-toeSize/2-t,-bigToeSize/2-t,0])	cube([cubeX,cubeY,1]);
	}

difference() {
	toeDis();
	//translate([-100,-100,-100+2.6]) cube([200,200,100]);
	translate([-20,0,length+7]) rotate([0,90-angle,0]) cylinder(h=70,r=bigToeSize/2);
	}