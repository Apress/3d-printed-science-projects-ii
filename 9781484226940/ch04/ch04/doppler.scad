// File doppler.scad
// An OpenSCAD model of a snapshot of the waves 
// around a moving object

// The model is based on the waves models in 
// Volume 1 of 3D Printed Science Projects
// Rich "Whosawhatsis" Cameron, December 2016
// Units: lengths in mm, angles in degrees
// per OpenSCAD conventions
// This program creates a res*xmax mm by res*ymax rectangle 
// As shown here will be 100 mm square.

// Model only valid for subsonic objects(mach < 1) 

mach = .5; // mach number – must be less than 1.0
frequency = 20; // frequency - increase to show more waves
// setting frequency to high for the mach number will
// result in sampling artifacts 
amplitude = .5; // Height of wave peaks on either side of the base plane, mm
thick = 2; // thickness of the slab, mm
xmax = 199; // max dimension in x (before scaling by res)
ymax = 199; //max dimension in x (before scaling by res)
res = .5; // scaling factor

// This function calculates a cosine wave with doppler shift:
function f(x, y) = amplitude * cos(r(x, y) / sin(theta(x, y) + asin(sin(theta(x, y)) * mach)) * sin(theta(x, y)) * frequency);

// These two functions convert x/y values to polar coordinates:
function r(x, y, center = [xmax/2, ymax/2]) = sqrt(pow(center[0] - x, 2) + pow(center[1] - y, 2));
function theta(x, y, center = [xmax/2, ymax/2]) = atan2((center[1] - y), (center[0] - x));

// The rest of the model is the same as the 
// wave model in Volume 1. 
// It creates and interpolates a surface z = f(x,y)
// 3D printer conventions are that z is vertical – 
// The model is rotated at the end
// so that the (x, y) surface is vertical, not horizontal
// This gives better print quality and allows for a wave
// surface on both sides of a print 
// without support


toppoints = (xmax + 1) * (ymax + 1);


center = [xmax/2, ymax / 2];

points = concat(
   // top face
   [for(y = [0:ymax], x = [0:xmax]) [x, y, f(x, y)]],
   (thick ? //bottom face
      [for(y = [0:ymax], x = [0:xmax]) [x, y, f(x, y) - thick]]
   :
      [for(y = [0:ymax], x = [0:xmax]) [x, y, 0]]
   )
);

zbounds = [
   min([for(i = points) i[2]]),
   max([for(i = points) i[2]])
];
   
function quad(a, b, c, d, r = false) = r ?
   [[a, b, c], [c, d, a]]:
   [[c, b, a], [a, d, c]]; //create triangles from quad

faces = concat(
   //build top and bottom
   [for(
      bottom = [0, toppoints],
      i = [for(x = [0:xmax - 1],
      y = [0:ymax - 1]
   )
      quad(
         x + (xmax + 1) * (y + 1) + bottom,
         x + (xmax + 1) * y + bottom,
         x + 1 + (xmax + 1) * y + bottom,
         x + 1 + (xmax + 1) * (y + 1) + bottom,
         bottom
      )], v = i) v],
   //build left and right
   [for(i = [for(x = [0, xmax], y = [0:ymax - 1])
      quad(
         x + (xmax + 1) * y + toppoints,
         x + (xmax + 1) * y,
         x + (xmax + 1) * (y + 1),
         x + (xmax + 1) * (y + 1) + toppoints,
         x
      )], v = i) v],
   //build front and back
   [for(i = [for(x = [0:xmax - 1], y = [0, ymax])
      quad(
         x + (xmax + 1) * y + toppoints,
         x + 1 + (xmax + 1) * y+ toppoints,
         x + 1 + (xmax + 1) * y,
         x + (xmax + 1) * y,
         y
      )], v = i) v]
);

// prevent an incorrect model from being generated
if(1 > mach && mach > -1) {
   // Scale and rotate the print
   rotate([90, 0, 0]) scale([res, res, 1]) {
      polyhedron(points, faces);
   }
} else echo("mach number must be less than 1");
// end model