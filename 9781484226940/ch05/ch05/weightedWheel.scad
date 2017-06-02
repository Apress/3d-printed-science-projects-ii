// A model of a weighted wheel
// To demonstrate conservation of angular momentum
// file weightedWheel.scad
// Rich Cameron, March 2017

d = 100; // diameter of disk, in mm
h = 20; //height of disk, in mm
t = 1; // minimum wall thicknesses
coin = 20; // diameter of coin in use, mm

$fs = .2;
$fa = 2;

difference() {
   cylinder(r = d / 2, h = h);
   for(i = [0:6]) rotate(120 * i + 60 * ceil(i / 3))
      translate([ceil(i / 3) * (d - coin - t * 2) / 4, 0, t])
         cylinder(r = coin / 2, h = h);
} // end model