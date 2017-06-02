// Model of a gravitational wave caused by inspiraling black holes
// Rich Cameron, March 2017
// File gravityWave.scad
// Parts based on math function generator from
// 3D Printed Science Projects (Apress, 2016)

a = 1/200; // amplitude scaling factor (for printing practicalities)
f = 800; // frequency scaling factor 
offset = 0; // Time offset (t=0 is when the black holes merge)
            // offset and trd should be positive numbers
trd = 30; //ringdown time 

// r(x,y) is the radius of the model in units of time
 


// The next section is function modeling 
// the waveform in each regime. Change this 
// if you want a different curve fit. 

function f(x, y) = a * (
   (r(x, y) < offset) ?
      0
   : (r(x, y) < (offset + trd)) ?
      pow(r(x, y) - offset, 2)
   :
      pow(trd, 2) * trd / (r(x, y) - offset)
) * cos(theta(x, y) * 2 + f * (
   (r(x, y) < (offset + trd)) ?
      (r(x, y) - offset) / trd - 1
   :
      ln((r(x, y) - offset) / trd)
));

// The rest of the code takes the points f(x,y) and plots them
// for x and y from 0 to xmax-1 and 0 to ymax -1. Each increment
// is 1 mm. The plot is double-sided by default. 
// If you change the model, you should not have to change 
// anything below. You will need to scale your model appropriately
// to keep the wave amplitude manageable for a printed-sideways
// 3D print.

thick = 4; // set to 0 for flat bottom
xmax = 199;
ymax = 199;
blocky = false; // if true, xmax and ymax must be less than 100.

toppoints = (xmax + 1) * (ymax + 1);
center = [xmax/2, ymax / 2];

function r(x, y, center = [xmax/2, ymax/2]) =
   sqrt(pow(center[0] - x, 2) + pow(center[1] - y, 2));
function theta(x, y, center = [xmax/2, ymax/2]) =
   atan2((center[1] - y), (center[0] - x));

// Now generate the surface points.
points = concat(
   [for(y = [0:ymax], x = [0:xmax]) [x, y, f(x, y)]], // top face
   (thick ? //bottom face
      [for(y = [0:ymax], x = [0:xmax]) [x, y, f(x, y) - thick]] : 
      [for(y = [0:ymax], x = [0:xmax]) [x, y, 0]]
   )
);

zbounds = [min([for(i = points) i[2]]), max([for(i = points) i[2]])];
	
function quad(a, b, c, d, r = false) = r ?
   [[a, b, c], [c, d, a]]
:
   [[c, b, a], [a, d, c]]; //create triangles from quad

faces = concat(
   [for(
      bottom = [0, toppoints],
      i = [for(x = [0:xmax - 1],
      y = [0:ymax - 1]
   ) //build top and bottom
      quad(
         x + (xmax + 1) * (y + 1) + bottom,
         x + (xmax + 1) * y + bottom,
         x + 1 + (xmax + 1) * y + bottom,
         x + 1 + (xmax + 1) * (y + 1) + bottom,
         bottom
      )], v = i) v],
   // build left and right
   [for(i = [for(x = [0, xmax], y = [0:ymax - 1]) 
      quad(
         x + (xmax + 1) * y + toppoints,
         x + (xmax + 1) * y,
         x + (xmax + 1) * (y + 1),
         x + (xmax + 1) * (y + 1) + toppoints,
         x
      )], v = i) v],
   // build front and back
   [for(i = [for(x = [0:xmax - 1], y = [0, ymax]) 
      quad(
         x + (xmax + 1) * y + toppoints,
         x + 1 + (xmax + 1) * y+ toppoints,
         x + 1 + (xmax + 1) * y,
         x + (xmax + 1) * y,
         y
      )], v = i) v]
);

if(blocky) for(i = [0:toppoints - 1]) translate(points[toppoints + i])
   cube([1.001, 1.001, points[i][2] - points[toppoints + i][2]]);
else rotate([90, 0, 0]) difference() {
   polyhedron(points, faces, convexity = 5);
   //cube(200, center = true);
}

// echo(zbounds);
// echo(points);
// end model