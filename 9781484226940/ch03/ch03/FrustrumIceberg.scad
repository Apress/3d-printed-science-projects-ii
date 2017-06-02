// File FrustrumIceberg.scad
// An OpenSCAD model of an iceberg
// Rich "Whosawhatsis" Cameron, January 2017
height = 30; // height overall, in mm
radius = 40; // maximum radius
featuresize = 20; // maximum variation from of radius 
noise = 10; // frequency of variations in radius
smoothness = 2; // how much to smooth the variations 
seed = 0; // seed for random number generator
linedepth = .2; // should be about half of your nozzle diameter

CRRadius = pow(1.1, 1/3); //cube root of 1.1
CR2 = pow (2, 1/3); // cube root of 2
// calculate the location of the water line
percentDistance = (CR2 - CRRadius) / (CR2 -1); 
topScale = 1/CR2; // scale of top of frustrum relative to base

$fs = .5;
$fa = 2;

// extrude the wavy outline with the top scalled and 
// subtract the water line at the height calculated above
difference() {
   union() {
      linear_extrude(height, scale = topScale, convexity = 5)
         outline();
      if(linedepth < 0) intersection() {
         translate([0, 0, height * percentDistance])
            cube(
               [radius * 10, radius * 10, .5],
               center = true
            );
         linear_extrude(height, scale = topScale, convexity = 5)
            offset(-linedepth) outline();
      }
   }
   if(linedepth > 0) intersection() {
      translate([0, 0, height * percentDistance])
         cube([radius * 10, radius * 10, .5], center = true);
      linear_extrude(height, scale = topScale, convexity = 5)
         difference() {
            offset(2) outline();
            offset(-linedepth) outline();
         }
   }
}

module outline() offset(-smoothness) offset(smoothness * 2)
   offset(-smoothness) polygon([for(
      theta = [0:noise:359],
      r = rands(radius, radius - featuresize, 1, seed + theta)
   ) rect(r, theta)]);

function rect(r, theta) = r * [sin(theta), cos(theta)];

// End of model