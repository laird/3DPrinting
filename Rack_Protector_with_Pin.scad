// Dishwasher rack protector
// Ed Nisley KE4ZNU - Dec 2011

Layout = "Build";                    // Show Build Support

Support = true;                     // true to add support inside rod half-cylinder

PrintPin = true;

include <visibone_colors.scad>

//-------
//- Extrusion parameters must match reality!
//  Print with +0 shells
//  Infill = 1.0, line, perpendicular to Bar axis on first bridge layer
//  Multiply = at least four copies to prevent excessive slowdown

ThreadThick = 0.25;
ThreadWidth = 2.0 * ThreadThick;

HoleFinagle = 0.4;
HoleFudge = 1.00;

function HoleAdjust(Diameter) = HoleFudge*Diameter + HoleFinagle;

Protrusion = 0.1;           // make holes end cleanly

function IntegerMultiple(Size,Unit) = Unit * ceil(Size / Unit);
function IntegerMultipleMin(Size,Unit) = Unit * floor(Size / Unit);

//-------
// Dimensions

PinDia = 4.0 + 0.5;                 // upright pin diameter + clearance
PinRadius = PinDia/2;
PinHeight = 150;						  // upright pin height (to replace broken pins)
PinBottom = 5;							  // How much of the old pin remains in place?

PinSpace = 35.0;                    // pin spacing along bar

PinOC = 3.4;                        // bar center to pin center

PinTubeLength = 15.0;               // length of upright tube along pin

BarDia = 4.7 + 0.2;                 // horizontal bar diameter + clearance
BarRadius = BarDia/2;

BarTubeLength = PinSpace - 5.0;     // length of horizontal half tube along bar

TubeWall = 4*ThreadWidth;           // wall thickness -- allow for fill motion

TubeSides = 4 * 4;                  // default side count for tubes (in quadrants)
$fn = TubeSides;

SupportClear = 0.85;                // support structure clearance fraction

//-------

module PolyCyl(Dia,Height,ForceSides=0) {           // based on nophead's polyholes
  Sides = (ForceSides != 0) ? ForceSides : (ceil(Dia) + 2);
  FixDia = Dia / cos(180/Sides);
  cylinder(r=HoleAdjust(FixDia)/2,h=Height,$fn=Sides);
}

module ShowPegGrid(Space = 10.0,Size = 1.0) {

  Range = floor(50 / Space);
  for (x=[-Range:Range])
    for (y=[-Range:Range])
      translate([x*Space,y*Space,Size/2])
        %cube(Size,center=true);
}

//--------
// Support under bar tube shells

module SupportStructure() {

  color("cyan")
  difference() {
    union() {
      for (Index=[-4:4])
        translate([Index*(BarTubeLength/8.5),0,0])
          rotate([0,90,0])
            rotate(180/TubeSides)
              cylinder(r=SupportClear*BarRadius,h=2*ThreadWidth,center=true);

      rotate([0,90,0])
        rotate(180/TubeSides)
          cylinder(r=SupportClear*BarRadius,h=10*ThreadWidth,center=true);

      translate([0,0,ThreadThick])
        cube([(BarTubeLength + 4*ThreadWidth),BarRadius,2*ThreadThick],center=true);
    }

    translate([0,0,-(BarRadius + Protrusion)/2])
      cube([(BarTubeLength + 2*Protrusion),
          BarDia,
          (BarRadius + Protrusion)],center=true);
  }
}

// print pin

module Pin() {
	if (PrintPin) {
		translate([0,PinOC,PinBottom + PinHeight/2+BarRadius]) 
			cylinder(r=PinRadius+HoleFinagle, h=PinHeight+PinBottom, center=true);
		translate([0,PinOC,PinHeight+BarRadius]) 
			sphere(r=PinRadius+HoleFinagle);
		}
	}

//-------
// Put it together

module Protector() {

  difference() {
    union() {
      translate([0,PinOC,0])
        rotate(180/TubeSides)
          cylinder(r=(PinDia + 2*TubeWall)/2,h=PinTubeLength);
      translate([-BarTubeLength/2,0,0])
        rotate([0,90,0])
          rotate(180/TubeSides)
            cylinder(r=(BarDia + 2*TubeWall)/2,h=BarTubeLength);
    }

    translate([0,PinOC,-Protrusion])
      rotate(180/TubeSides)
        PolyCyl(PinDia,(PinTubeLength + 2*Protrusion),TubeSides);

    translate([-BarTubeLength/2,0,0])
      rotate([0,90,0])
        rotate(180/TubeSides)
          translate([0,0,-Protrusion])
            cylinder(r=BarRadius,h=(BarTubeLength + 2*Protrusion));

    translate([0,0,-(BarRadius + TubeWall + Protrusion)/2])
      cube([(BarTubeLength + 2*Protrusion),
          BarTubeLength,
          (BarRadius + TubeWall + Protrusion)],center=true);
  }
  Pin(); // print pin
}

//-------
// Build it!

ShowPegGrid();

if (Layout == "Support")
  SupportStructure();

if (Layout == "Show") {
  Protector();
  translate([0,-10,0])
    SupportStructure();
}

if (Layout == "Build")
  rotate(90) {
    if (Support)
      SupportStructure();
    Protector();
  }