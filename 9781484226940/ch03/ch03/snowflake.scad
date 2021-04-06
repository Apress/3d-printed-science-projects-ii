// File snowflake.scad
// An OpenSCAD model of an iceberg
// Rich "Whosawhatsis" Cameron, January 2017
// Units: lengths in mm, angles in degrees
// per OpenSCAD conventions

min = 2; // minimum size of a hexagon
// should be large enough to print without breaking
max = 12; // maximum size of a hexagon
distribution = 5; //exponent in power law
smooth = .5; // smooth off edges
// simulates snowflake, melting/sublimating a bit
seed = 10; // seed for random number generator
// same seed gives same result
iterations = 20; // how many times to add more hexagons 
layer = 1; // how much smaller to make each layer than the last
minwidth = 0.5; // stops iterating branches if they get too
// thin to print, which would result in disconnected sections

$fs = .5;
$fa = 2;

// First create an array of random numbers skewed by power law
// Random number is raised to the power "distribution" 
// and scaled by max-min
array = [
   for(v = rands(0, max - min, iterations, seed))
      min + pow(v, distribution) /
         pow(max - min, distribution - 1)
];

// Create six arms
for(i = [0:3]) linear_extrude(1 + i * .5)
   offset(smooth) offset(-smooth * 2) offset(smooth)
      for(a = [0:60:359]) rotate(a) grow(shrink = i * layer);

// recursive function that grows each arm or branch
module grow(n = 1, branch = true, shrink = 0) {
   // create one hexagon
   circle(array[n] - shrink, $fn = 6);
   // then decide whether to continue with recursion
   if(n < len(array) - 1 && (array[n] - shrink) > minwidth) {
      translate([
         abs(array[n] - array[n + 1]) + 1 - shrink,
         0,
         0
      ])
         grow(n + 1, branch, shrink);
      // branch if size has decreased sufficiently
      if((array[n] - 2) > array[n + 1] && n > 5 && branch)
         for(a = [60, -60]) rotate(a)
            translate([abs(array[n] - array[n + 1]) + 1, 0, 0])
               grow(n + 1, false, shrink + 1);
   }
}
// End model