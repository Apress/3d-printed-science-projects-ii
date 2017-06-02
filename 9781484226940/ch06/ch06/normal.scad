// Probability distribution function of two variables
// File normal.scad
// Based on OpenSCAD model to print out an arbitrary surface 
// defined as z = f(x,y)
// First used in "3D Printed Science Projects" 
//(2016, first volume)
// Either prints the surface as two sided and variable 
// thick = thickness
// Or if thick = 0, prints a top surface with a flat bottom

overall_scale = 100;
SDx = 36.0; //Standard deviation, x variable
SDy = 36.0; // Standard deviation, y variable
meanX= 100.0; //Mean of the x variable
meanY = 100.0; // Mean of the y variable
corrCoeff = 0; // -1 < corrCoeff < 1
scale = 10*200*200; //scaling factor
add_base = 4; // additional base thickness, mm
denom = 1 - pow (corrCoeff, 2);


// Constant in front of exponential part of equation
const = scale/ (2. * PI * SDx * SDy * sqrt (denom) );
 
// probability density function
function f(x, y) = 
   add_base * 199 / overall_scale + const * 
   exp ( -(1 / (2 * denom) ) * 
  ( pow( (x - meanX) / SDx, 2) + 
    pow( (y-meanY) / SDy, 2) - 
    2 * corrCoeff * (x - meanX) * (y - meanY) / (SDx * SDy) )    
   ); 

thick = 0; //set to 0 for flat bottom
          // else is thickness of print
xmax = 199;
ymax = 199;

toppoints = (xmax + 1) * (ymax + 1);


center = [xmax / 2, ymax / 2];

points = concat(
    [for(y = [0:ymax], x = [0:xmax]) [x, y, f(x, y)]], 
// top face
   (thick ? //bottom face
      [for(y = [0:ymax], x = [0:xmax]) 
      [x, y, f(x, y) - thick * 199 / overall_scale]]
   : 
      [for(y = [0:ymax], x = [0:xmax]) [x, y, 0]]
   )
);

zbounds = [min([for(i = points) i[2]]), 
           max([for(i = points) i[2]])];
	
function quad(a, b, c, d, r = false) = r ?
   [[a, b, c], [c, d, a]]
:
   [[c, b, a], [a, d, c]]
; //create triangles from quad

faces = concat(
   [for(bottom = [0, toppoints], i = [for(x = [0:xmax - 1], 
   y = [0:ymax - 1]) //build top and bottom
      quad(
         x + (xmax + 1) * (y + 1) + bottom,
         x + (xmax + 1) * y + bottom,
         x + 1 + (xmax + 1) * y + bottom,
         x + 1 + (xmax + 1) * (y + 1) + bottom,
         bottom
      )], v = i) v],
   [for(i = [for(x = [0, xmax], y = [0:ymax - 1]) 
   //build left and right
      quad(
         x + (xmax + 1) * y + toppoints,
         x + (xmax + 1) * y,
         x + (xmax + 1) * (y + 1),
         x + (xmax + 1) * (y + 1) + toppoints,
         x
      )], v = i) v],
   [for(i = [for(x = [0:xmax - 1], y = [0, ymax])
      //build front and back
      quad(
         x + (xmax + 1) * y + toppoints,
         x + 1 + (xmax + 1) * y+ toppoints,
         x + 1 + (xmax + 1) * y,
         x + (xmax + 1) * y,
         y
      )], v = i) v]
);

scale(overall_scale / 199) rotate([90, 0, 0]) polyhedron(points, faces);
// End model