// Model of logic gates and connectors
// File gates.scad
// Rich "Whosawhatsis" Cameron, March 2017
// Create logic gates with all permutations of inputs and outputs
// A "1" or "TRUE" is a crossbar
// A "0" or "FALSE" is circle
// And connectors, input, and output pieces

size = 30; //Scaling in mm - roughly bounding box of gate symbols

thick = 1; //Line thickness; connector lines are twice this
height = 3; //Max height above platform of gates, mm
fontsize = size / 5;
fontweight = thick;

clearance = .4; // Parameter governing clearance of parts 
                // that fit into each other

// Remove the "!" from the piece you do NOT want to print
// (gates or wires)

// To make a set of gates, 
// Replace "none" with one of the names of gates 
// listed later in the model. 
// All possible permutations of inputs and outputs
// for that gate are printed. The optional second parameter
// "rows" determines how many rows these will be split
// into on the printer platform.

!gates(none);

// Or, for wires, replace the first parameter of "wires"
// with one of the types of wires named later in the model
// to print a set of those wires. 
// The second parameter is the number of connection points.
// Negative numbers have connections on two sides
!wires(side, -5);

//gates
none = 0;
or = 1;
xor = 2;
and = 3;
not = 4;
nor = 5;
xnor = 6;
nand = 7;

//wires
side = 0; //connectors branching sideways
forward = 1; // data input, with a 1 or 0
back = 2; //feedback wires
riser = 3; //offsets two layers


$fs = .2;
$fa = 2;

// gates makes multiple instances of objects define by gate
// second parameter is how many are in a row
module gates(type, row = 2) {
   if(type == not) for(i = [0:1]) translate([
      (size + 2) * (i % row),
      (size + 15) * floor(i / row),
      0
   ]) gate(type, [i]);
   else if(type == none) wire(forward);
   else for(i = [0:3]) translate([
      (size + 2) * (i % row),
      (size + 14) * floor(i / row),
      0
   ]) gate(type, [floor(i / 2), i % 2]);
}


// Module gate makes the gates
module gate(type, in = [0, 0]) for(h = [0, height - 1]) {
   linear_extrude(height = h + 1, convexity = 5) {
      if(type % 4 == or) {
         _or(in, h ? thick : 0);
         _out(
            xor(in[0] || in[1],
            type >= not),
            h ? thick : 0,
            (type >= not) ? true : false
         );
         translate([0, -size * .15, 0]) 
            offset(fontweight/2 - fontsize * .075) text(
               (type >= not) ? "NOR" : "OR", size = fontsize,
               halign = "center",
               valign = "center",
               font = ":style=Bold"
             );
      }
      else if(type % 4 == xor) {
         _xor(in, h ? thick : 0);
         _out(
            xor(xor(in[0], in[1]), type >= not),
            h ? thick : 0,
            (type >= not) ? true : false
         );
         translate([0, -size * .08, 0])
             offset(fontweight/2 - fontsize * .075) text(
                (type >= not) ? "XNOR" : "XOR",
                size = fontsize,
                halign = "center",
                valign = "center",
                font = ":style=Bold"
             );
      }
      else if(type % 4 == and) {
         _and(in, h ? thick : 0);
         _out(
            xor(in[0] && in[1], type >= not),
            h ? thick : 0,
            (type >= not) ? true : false
         );
         translate([0, -size * .15, 0])
            offset(fontweight/2 - fontsize * .075) text(
               (type >= not) ? "NAND" : "AND",
               size = fontsize,
               halign = "center",
               valign = "center",
               font = ":style=Bold"
            );
      }
      else if(type % 4 == none) {
         if(type == not) {
            _none(in, h ? thick : 0);
            _out(
               xor(in[0], type >= not),
               h ? thick : 0,
               (type >= not) ? true : false
            );
            translate([0, -size * .25, 0])
               offset(fontweight/2 - fontsize * .075) text(
                  (type >= not) ? "NOT" : "",
                  size = fontsize,
                  halign = "center",
                  valign = "center",
                  font = ":style=Bold"
               );
         } else _forwardwire([in[0]], h ? thick : 0);
      }
   }
}

module wires(type, value = 1) {
   if(type == side) wire(type, [(value < 1) ? 1 : 0, abs(value)]);
   else wire(type);
}

module wire(type, w = [0, 1]) {
   if(type == side) {
      linear_extrude(height = height, convexity = 5) for(i = [0, 1])
         translate(
            i * [-size * 2 / 3 * (w[1]) - thick,
            -thick * 4,
            0
         ]) rotate(i * 180) _crosswire([i], thick, w = w);
   } else if(type == forward) {
      linear_extrude(height = height, convexity = 5) for(i = [0, 1])
         translate(i * [-size / 3 - thick * 7, 0, 0]) rotate(i * 180)
            _forwardwire([i], thick);
   } else if(type == back) {
      linear_extrude(height = height, convexity = 5) for(i = [0, 1])
         translate(i * [-thick * 4, 10 + thick + 5, 0])
            _backwire([i], thick);
   } else if(type == riser) {
      for(i = [0, 1]) translate(i * [0, 0, 0]) rotate(i * 180)
         _wireriser([i], thick, height);
   }
}

// OpenSCAD doesn't have a built-in xor operator, so we need a
// function.
function xor(a, b) = (a || b) && !(a && b); 

module _or(in = [0, 0], width = 0, l = 10) difference() {
   union() {
      if(l) _in(in, width, l = l);
      difference() {
         intersection_for(i = [-1, 1])
            translate([i * size / 2, -size * .366, 0]) circle(size);
         translate([0, -size - size * .366, 0]) circle(size);
      }
   }
   if(width) offset(-width) _or(l = 0);
}

module _xor(in = [0, 0], width = 0, l = 10) difference() {
   union() {
      if(l) _in(in, width, l = l);
      _or(l = 0);
   }
   if(width) union() {
      offset(-width) difference() {
         _or(l = 0);
         translate([0, -size - size * .366, 0])
            circle(size + width * 3);
      }
      translate([0, -size - size * .366, 0]) difference() {
         circle(size + width * 3);
         circle(size + width);
      }
   }
}

module _and(in = [0, 0], width = 0, l = 10) difference() {
   union() {
      if(l) _in(in, width, l = l);
      hull() {
         circle(size / 2);
         translate([-size / 2, -size / 2, 0])
            square([size, size / 4]);
      }
   }
   if(width) offset(-width) _and(l = 0);
}

// generic gate symbol (used for NOT)
module _none(in = [0], width = 0, l = 10) difference() {
   union() {
      if(l) _in(in, width, l = l);
      hull() {
         translate([0, size * .45, 0]) circle(size * .05);
         translate([-size * .45, -size * .45, 0]) circle(size * .05);
         translate([size * .45, -size * .45, 0]) circle(size * .05);
      }
   }
   if(width) offset(-width) _none(l = 0);
}

// Create connectors 

module _forwardwire(in = [0], width = 0, l = 10) {
   for(i = [0:len(in) - 1]) translate([
      (len(in) > 1) ? size * 2 / 6 / (len(in) - 1) * i - size / 6 : 0,
      0,
      0
   ]) {
      _in(in, width, l = l);
      _out(in[0], width, l = l);
      square([width * 2, size], center = true);
   }
}

module _backwire(in = [0], width = 0, l = 10) {
   for(i = [0:len(in) - 1]) translate([
      (len(in) > 1) ? size * 2 / 6 / (len(in) - 1) * i - size / 6 : 0,
      0,
      0
   ]) {
      for(i = [0, 1]) rotate(180 * i) {
         translate([
            -size / 2,
            -size - l * 3,
            0
         ]) _out(in[0], width, l = l);
         translate([-width, size / 2 + l * 3, 0])
            square([size / 2 + width * 2, width * 2]);
      }
      square([width * 2, size + l * 6], center = true);
   }
}

module _forwardwire(in = [0], width = 0, l = 10) {
   for(i = [0:len(in) - 1]) translate([
      (len(in) > 1) ? size * 2 / 6 / (len(in) - 1) * i - size / 6 : 0,
      0,
      0
   ]) {
      _in(in, width, l = l);
      _out(in[0], width, l = l);
      square([width * 2, size], center = true);
   }
}

module _crosswire(in = [0], width = 0, l = 10, w = [0, 0]) {
   for(side = [0, 1]) mirror([side, 0, 0]) if(w[side]) difference() {
      union() {
         translate([-width, -width, 0])
            square([
               size * 2 / 3 * (w[side] - .5) + width * 2,
               width * 2
            ]);
         for(i = [1:w[side]]) translate([
            size * 2 / 3 * (i - .5),
            0,
            0
         ]) {
            translate([0, l / 4, 0])
               square([width * 2, l / 2], center = true);
            translate([0, l / 2, 0]) offset(width * 2 + clearance)
               _end(in[0], width);
         }
         translate([0, -l / 4, 0])
            square([width * 2, l / 2], center = true);
         translate([0, -l / 2, 0]) offset(width * 2 + clearance)
            _end(in[0], width);
      }
      offset(clearance) {
         for(i = [1:w[side]]) translate([
            size * 2 / 3 * (i - .5),
            0,
            0
         ]) {
            translate([0, l / 2 + width * 2, 0])
               square([width * 2, width * 4], center = true);
            translate([0, l / 2, 0]) _end(in[0], width);
         }
         translate([0, -l / 2 - width * 2, 0])
            square([width * 2, width * 4], center = true);
         translate([0, -l / 2, 0]) _end(in[0], width);
      }
   }
}

module _wireriser(in = [0], width = 0, h = height) {
   translate([0, -10, 0]) difference() {
      union() {
         linear_extrude(h + 2) offset(width * 2)
            _out(in[0], width, l = 0);
         linear_extrude(h * 2 + 2, convexity = 5) intersection() {
            offset(width * 2) _out(in[0], width, l = 0);
            translate([0, -width * 5, 0])
               _out(in[0], width, l = width * 5);
         }
      }
      translate([0, -width * 5, 0])
         linear_extrude(h * 2 + 2, center = true, convexity = 5)
            offset(clearance) _out(in[0], width, l = width * 5);
   }
}

module _in(in = [0], width = 0, l = 10) for(i = [0:len(in) - 1]) {
   translate([size * 2 / 3 * i - size / 3, 0, 0]) {
      if(len(in) > 1) translate([0, -size * .4 - l / 2, 0])
         square([width * 2, l + size * .2], center = true);
      else {
         translate([-width, -size / 2 - l / 2 - width, 0])
            square([size / 3 + width * 2, width * 2]);
         translate([size / 3, -size * .4, 0])
            square([width * 2, l + size * .2], center = true);
         translate([
            0,
            -size * .4 - l / 2 - (l / 2 + size * .2) / 2,
            0
         ]) square([width * 2, l / 2], center = true);
      }
      translate([0, -size / 2 - l, 0]) {
         _end(in[i], width);
      }
   }
}

module _out(out = 0, width = 0, inverting = false, l = 10) {
   difference() {
      union() {
         translate([0, size / 2 + l / 2 - .5, 0])
            square([width * 2, l + .5], center = true);
         translate([0, size / 2 + l, 0]) _end(out, width);
         if(inverting) translate([
            0,
            size * .5 - thick + thick * 2.5,
            0
         ]) circle(thick * 2.5);
      }
      if(width) offset(-width) _out(inverting = inverting, l = 0);
   }
}

module _end(on = true, width = 0) {
   if(on) square([width * 6, width * 2], center = true);
   else circle(width * 2);
} // end model