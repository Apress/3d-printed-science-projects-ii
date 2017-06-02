// Graphing version of gravitational wave model. 
// Rich Cameron, March 2017
// File gravityGraph.scad

a = 1/100; // Amplitude modifier
f = 2000; // Frequency modifier
offset = 0; // Time offset
trd = 150; // Ringdown time- time from peak amplitude to zero
res = .2; // Data point spacing


for(i = [0:res:1000]) hull() for(i = [i, i + res]) {
   translate([i, a * (
      (i < offset) ?
         0
      : (i < (offset + trd)) ?
         pow(i - offset, 2)
      :
         pow(trd, 2) * trd / (i - offset)
   ) * cos(f * (
      (i < (offset + trd)) ?
         (i - offset) / trd - 1
      :
         ln((i - offset) / trd)
   )), 0]) circle(1, $fn = 4);
}

for(i = [0:res:1000]) hull() for(i = [i, i + res]) {
   translate([i, 100 * ((
      (i < (offset + trd)) ?
         (i - offset) / trd - 1
      :
         ln((i - offset) / trd)
   ) + 1), 0]) circle(1, $fn = 4);
} // End graphing model.