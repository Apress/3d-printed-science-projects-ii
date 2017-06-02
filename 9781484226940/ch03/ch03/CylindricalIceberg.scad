// File CylindricalIceberg.scad
// An OpenSCAD model of an iceberg
// Rich "Whosawhatsis" Cameron, January 2017
height = 30; // height overall, in mm
radius = 40; // maximum radius
featuresize = 20; // maximum variation from of radius 
noise = 10; // frequency of variations in radius
smoothness = 2; // how much to smooth the variations 
seed = 0; // seed for random number generator
linedepth = .2; // should be about half of your nozzle diameter

percentDistance = .9; // location of the water line

$fs = .5;
$fa = 2;

// extrude the wavy outline and subtract the water line
difference() {
   union() {
      linear_extrude(height, convexity = 5) outline();
      if(linedepth < 0)
         translate([0, 0, height * percentDistance])
            linear_extrude(.5, center = true, convexity = 5)
               offset(-linedepth) outline();
   }
   if(linedepth > 0)
      translate([0, 0, height * percentDistance])
         linear_extrude(.5, center = true, convexity = 5)
            difference() {
               offset (2) outline();
               offset(-linedepth) outline();
            }
}

module outline() offset(-smoothness) offset(smoothness * 2)
   offset(-smoothness) polygon([for(
      theta = [0:noise:359],
      r = rands(radius, radius - featuresize, 1, seed + theta)
   ) rect(r, theta)]);

function rect(r, theta) = r * [sin(theta), cos(theta)];

// End of model