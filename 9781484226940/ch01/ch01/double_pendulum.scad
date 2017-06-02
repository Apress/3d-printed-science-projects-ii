// File double_pendulum.scad
// A 3D printable double pendulum model
// Rich "Whosawhatsis" Cameron, December 2016

lengths = [100, 70]; // mm, length of each pendulum
width = 10; // mm, width of each piece
pivot = 5; // mm, diameter of the pivot center
gap = .3; // mm, spacing between pivot center and hole
thick = 6; // mm, thickness of each piece
base = 30; // mm, length of the base that rests on the edge of a table

$fs = .2;
$fa = 2;

// create the base piece
translate([len(lengths) * (width + 2), - (thick + 5) / 2, 0]) {
   linear_extrude(thick) square([width, base], center = true);
   // create sideways pivot with flat side for printing
   intersection() { 
      translate([0, base / 2 - thick, pivot / 2 / sqrt(2)]) {
         rotate([-90, 0, 0]) rotate_extrude() {
            difference() {
               square([pivot / 2, thick * 2 + 5]);
               translate([
                  pivot / 2 + 1 - sqrt(2) / 2,
                  thick * 2 + 3,
                  0
               ]) circle(1);
            }
         }
      }
      linear_extrude(pivot) difference() { // flat side
         square([width, base + thick * 2 + 10], center = true);
      }
   } // end sideways pivot
} // end base piece

// create the pendulums
for(j = [0:len(lengths) - 1], l = lengths[j]) {
   translate([j * (width + 2), 0, 0]) {
      linear_extrude(thick) difference() { // create pivot body
         hull() for(i = [.5, -.5])
            translate([0, i * l, 0]) circle(width / 2);
         translate([0, -.5 * l, 0]) circle(pivot / 2 + gap);
      } // end pivot body
      // create pivot
      translate([0, .5 * l, 0]) rotate_extrude() difference() {
         square([pivot / 2, thick * 2 + 5]);
         translate([pivot / 2 + 1 - sqrt(2) / 2, thick * 2 + 3, 0])
         circle(1);
      } 
   } // end pivot
} // end pendulums

//create the snap rings to hold the pendulums in place
for(j = [0:len(lengths)]) translate([
   -width / 2 - (pivot / 2 + 1 - sqrt(2) / 2) - 4,
   (j - (len(lengths)) / 2) * ((pivot / 2 + 1 - sqrt(2) / 2) * 2 + 5),
   0
]) {
   difference() { // create bendable partial ring
      rotate_extrude() intersection() {
         hull() for(i = [0, 1]) translate([
            pivot / 2 + 1 - sqrt(2) / 2 + i,
            sqrt(2) / 2,
            0])
         circle(1);
         square([pivot / 2 + 1 - sqrt(2) / 2 + 2, sqrt(2)]);
      }
      for(i = [1, -1]) rotate(-45 + 15 * i) translate([0, 0, -1])
         cube(max(pivot, 4));
      translate([0, 0, -1]) cylinder(r = pivot / 2 + 1, h = 4);
   } // end partial ring
   // create contact points at 120 degree intervals
   for(a = [-180:120:179]) rotate(a) {
      translate([pivot / 2 + 1 - sqrt(2) / 2 +.5, 0, 0]) {
         rotate_extrude() intersection() {
            translate([.5, sqrt(2) / 2, 0]) circle(1);
            square([pivot / 2 + 1 - sqrt(2) / 2 + 2, sqrt(2)]);
         }
      }
   } // end contact points
} // end snap rings and end of model