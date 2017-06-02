// File barchan.scad
// An OpenSCAD model of barchan sand dunes
// The program defines a parabola for the envelope 
// Based on the parameters at the top of the file. 
// Rich "Whosawhatsis" Cameron, November 2016
// Units: lengths in mm, angles in degrees, per OpenSCAD conventions

height = 10; // max height in z, mm
windward = 15; // angle to the horizontal of the nose of the dune
repose = 30; // angle of repose, degrees
width = 100; // width at widest point (ends of crescent), mm
length = 100; // length from nose to center of crescent ends, mm

// First create cross sections of the dune in the vertical plane
// parallel to the wind direction
// These cross sections are offset by a parabola
// The back of the cross section, defined by angle of repose
// for now, is symmetrical to the front
// Later on we will subtract (difference) a cutoff at the angle of
// repose

difference() {
   for(i = [-width/2:width/2 - 1])
      hull() for(i = [i, i + 1])
         translate([i, pow(i/width * 2, 2) * length, 0])
            rotate([90, 0, 90]) 
               linear_extrude(height = .001, scale = .001)
                  polygon([
                     for(i = [-1:.1:1])
                        height * [i / tan(windward), 1 - i * i]
                  ]);

   // The next section creates the surface that we will subtract
   // from the windward side to create the angle of repose
   // on the leeward side
   hull() for(i = [-width:width]) {
      translate([
         i,
         height / tan(repose) + (length - height / tan(repose) -
            height / tan(windward)) / pow(width / 2, 2) * pow(i, 2),
         0
      ]) { 
         rotate([
            90,
            0,
            90 + atan(2 * i * (length - height / tan(repose) -
               height / tan(windward)) / pow(width / 2, 2))
// The previous line calculates the normal to the lee face parabola.
         ]) {
            linear_extrude(height = .001, scale = 1) {
               rotate(90 - repose) translate([0, -1, 0]) square((height + 2) / sin(repose));
            }  // end linear_extrude
         }  // end rotate
      }  // end translate
   }  // end hull
} // end difference
// (subtracting the leeward face cutout from the rest of the model)