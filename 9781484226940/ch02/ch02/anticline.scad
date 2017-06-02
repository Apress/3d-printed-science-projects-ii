// File anticline.scad
// An OpenSCAD model of synclines and anticlines
// The program defines a function for the middle layer and then 
// Defines layer thicknesses and offsets from this middle. 
// Rich "Whosawhatsis" Cameron, November 2016
// Units: lengths in mm, angles in degrees, per OpenSCAD conventions

size = 100; //The dimension of the model in x and y, in mm 

include_layers = "all"; //options: "all", "odd", "even",
                                        //or an array of specific layer numbers (e.g. [2, 5, 8])

// Function that defines shape of center curve
function f(x) = cos(x * 1.5 + 30) * size / 5;

// offset of layer boundaries, relative to center curve
layers = [-20, -10, -6, 2, 10, 14, 22]; 
// Thickness of each layer = difference between subsequent offsets

layer_angle = [5, 15, 0];
// Vector of angles [x, y, z] rotating the curve relative to axes

surface_angle = [10, 0, 0];
// Vecto of angles about [x, y, z] to create sloping surface (top) 
// Use to expose lower layers

// First create list of which layers to render
// (odd, even, all, or specific ones)
for(i = [0:len(layers) - 1]) if(
      ((include_layers == "odd") && (i % 2))
   ||
      ((include_layers == "even") && !(i % 2))
   ||
      (include_layers == "all")
   ||
      len(search(i, include_layers))
) translate([0, i*5, 0]) intersection() {

// Now create the layers and rotate them appropriately
// And intersect them with two bounding boxes defined below
// To cut off a clean flat bottom surface

   translate([-size / 2, 0, -size / 2]) cube([size, size, size]);
   rotate(surface_angle)
      cube([size * 2, size * .5, size * 2], center = true);
   rotate(layer_angle) linear_extrude(
      height = size * 2,
      center = true,
      convexity = 10
   ) {
      difference() {
         offset(layers[i]) layer();
         if(i) offset(layers[i - 1] + .2) layer();
      }
   }
}

//Function to make polygons out of curves
module layer() polygon(concat([
   for(i = [-size:size]) [i, f(i)]],
   [[size, -size],
   [-size, -size]
]));
//End model