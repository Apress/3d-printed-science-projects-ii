// File simple_pendulum.scad
// A pendulum bob designed to carry coins 
// Pendulum is pointed on the bottom for ease of reading
// Rich "Whosawhatsis" Cameron, December 2016

thick = 2; // wall thickness (mm)
// should include tolerance to make coins fit easily (mm)
coins_diameter = 19.5;
// use 19.5 for a US penny; 25 for a US quarter
coins_depth = 8; // total depth of coins (mm); here, 4 pennies

holder = 4; // controls how much the coins are covered by lip on top

$fs = .2;
$fa = 2;

// First section creates the back of the model
// the flat part printed on the platform
linear_extrude(1) difference() {
   offset(thick / 2) {
      hull() for(i = [0, holder]) translate([0, -i, 0])
         circle(coins_diameter / 2);
      rotate(45) square(coins_diameter / 2); // create point on bottom
   }
   translate([0, coins_diameter / sqrt(2), 0])
      circle(coins_diameter / 2);
} //end back

// Next section creates the lip on top that keeps coins in
translate([0, 0, coins_depth + 1]) linear_extrude(1) offset(thick / 2) difference() {
   offset(thick / 2) hull() for(i = [0, holder]) translate([0, -i, 0])
      circle(coins_diameter / 2);
   translate([-coins_diameter/2 - thick / 2, -coins_diameter/2, 0])
      square(coins_diameter + thick);
} // end creation of top

// Next section creates outer wall 
linear_extrude(coins_depth + 2) difference() {
   offset(thick) {
      hull() for(i = [0, holder]) translate([0, -i, 0])
         circle(coins_diameter / 2);
      rotate(45) square(coins_diameter / 2);
   } // end offset
   offset(0) {
      hull() for(i = [0, holder]) translate([0, -i, 0])
         circle(coins_diameter / 2);
      rotate(45) square(coins_diameter / 2);
   } // end offset
} // end outer wall creation 

// Next section creates the point at the bottom
translate([
   0,
   -coins_diameter / 2 - holder - thick,
   coins_depth / 2 + 1
]) rotate([90, 0, 90]) linear_extrude(thick, center = true) {
   difference() {
      union() {
         rotate(45)
            square((coins_depth + 2) / sqrt(2), center = true);
         translate([0, - coins_depth / 2 - 1, 0]) square(coins_depth + 2);
      } // end union
      translate([thick / 2, - coins_depth / 2 - 1, 0]) square(coins_depth + 2);
   } // end difference
} // end fin at the bottom 
