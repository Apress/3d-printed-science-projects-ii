// File compound_pendulum.scad
// A rigid pendulum meant to carry multiple sets of coins 
// Rich "Whosawhatsis" Cameron, December 2016

width = 10; // width in mm, parallel to coins
thick = 2; // thickness in mm
length = [50, 100]; // in mm from the pivot.
// array of positions of the center of coin holders, 
// to have more holders, add more values to the length array. 
coins_diameter = 19.1; // in mm
// 19.1 is US pennies plus a small tolerance
coins_depth = 8; // depth of coin holder; this is for 4 US pennies

pivot_spacing = .4; // tolerance, mm around pivot

base_len = 25;
// length of the base that sticks out to attach to the table

stop_angle = 25; // degrees; maximum extent of swing 

$fs = .2;
$fa = 2;

difference() { //fulcrum for pendulum
   union() {
      // create piece that sticks out to place on table
      translate([0, -width / 2, 0])
         cube([width / 2 + thick + base_len, width, thick]);
      // create body of the fulcrum piece
      rotate([0, -90, 180]) linear_extrude(
         width + thick * 2,
         center = true,
         convexity = 5
      ) union() {
         translate([width / 2, 0, 0]) intersection() {
            circle(width / sqrt(2) + 2 + thick);
            union() {
               translate([-width / 2, 0, 0])
                  square([width, max(length)]);
               rotate(45) translate([0, -width / sqrt(2), 0])
                  square([width * 2, width * sqrt(2)]);
            }
         }
         translate([width / 2, 0, 0]) intersection() {
            circle(width / sqrt(2));
            square([width, width * sqrt(2)], center = true);
         }
      } // end of body 
   }
    
   // create cutout for conical pivot
   rotate([0, -90, 0]) translate([width / 2, 0, 0]) for(i = [0, 1])
      mirror([0, 0, i]) cylinder(
         r = width / 2 + 1,
         r2 = 0,
         h = width / 2 + pivot_spacing
      );
   //create cutout for pendulum swing angle 
   rotate([0, -90, 0]) linear_extrude(thick + 2, center = true) {
      translate([width / 2, 0, 0]) circle(width / sqrt(2) + 2);
      hull() for(a = [-stop_angle, 0, stop_angle])
         translate([width / 2, 0, 0]) rotate(a + 90)
            translate([-width / 2, 0, 0])
               square([width, max(length)]);
   } // end of swing cutout 
} // end fulcrum

// create conical pivots
rotate([0, -90, 0]) translate([width / 2, 0, 0]) for(i = [0, 1])
  mirror([0, 0, i]) cylinder(r = width / 2, r2 = 0, h = width / 2);

// create the body of the pendulum
rotate([0, -90, 0]) linear_extrude(thick, center = true) {
   square([width, max(length)]);
   translate([width / 2, 0, 0]) intersection() {
      circle(width / sqrt(2));
      square([width, width * sqrt(2)], center = true);
   }
   for(i = length, d = coins_diameter + thick * 2) {
      translate([width / 2, i, 0]) intersection() {
         circle(d / sqrt(2));
         square([width, d * sqrt(2)], center = true);
      }
   }
}

rotate([0, -90, 0]) { // create coin holders
   for(i = length, d = coins_diameter + thick * 2) {
      translate([width / 2, i, 0]) difference() {
         linear_extrude(thick / 2 + coins_depth + 2) intersection() {
            circle(d / 2);
            square([width, d], center = true);
         } 
         rotate_extrude() difference() {
            translate([0, 0, 0])
               square([d / 2 - thick, thick / 2 + coins_depth + 5]);
            translate([
               d / 2 - thick + .5,
               thick / 2 + coins_depth + 1,
               0
            ]) circle(1);
         }
      }
   }
} // end coin holders