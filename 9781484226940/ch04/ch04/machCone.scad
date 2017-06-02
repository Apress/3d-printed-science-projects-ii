// File machCone.scad
// An OpenSCAD model of a snapshot 
// of the propagating disturbance 
// From a point source moving at mach number, “mach”

// The model prints a disk that is a cross-section of 
// the sphere representing a propagating disturbance
// from the traveling point source
// and a surface that is the envelope of 
// the boundary of these propagating spheres
// Assumes point source at constant velocity

// Rich "Whosawhatsis" Cameron, December 2016
// Units: lengths in mm, angles in degrees, 
// per OpenSCAD conventions

mach = 0.5; // mach number

size = 50; // diameter of the oldest propagation circle, in mm 
a = 30; // angle from the vertical at which 
// the point source is traveling
step = 3; // size of the circular cross-section steps 

$fs = 2; // decrease this for smoother curves. 
// This will slow down rendering.
$fa = 2;

// First section creates the outer boundary created by
// smoothing spheres of propagating
// disturbance as the point source moves 
difference() {
   intersection() {
      hull() for(i = [1, size / 2]) {
        translate([sin(a), 0, cos(a)] * (size / 2 - i) * mach)
          sphere(r = i);
      }
      translate([-size, 0, 0]) cube(size * 10);
   }
   if(mach <= 1) for(i = [5:step:size / 2]) {
      translate([sin(a), 0, cos(a)] * (size / 2 - i) * mach) {
         rotate([90, 0, 0]) {
            linear_extrude(2, center = true) difference() {
               circle(i);
               circle(i - .2);
            }
         }
      }
   }
} // end difference

// Next create the stair steps representing the diameter of
// propagation circles 
intersection() {
   for(i = [0:step:size / 2 + step]) {
      translate([sin(a), 0, cos(a)] * (size / 2 - i) * mach) {
         cylinder(
            r = i,
            h = step * mach * cos(a) + .01,
            center = true
         );
      }
   }
   translate([-size, -size * 10, 0]) cube(size * 10);
}

// end model