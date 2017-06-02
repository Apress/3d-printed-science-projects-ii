// Pascal's triangle
// File pascal.scad
// This make one triangle
// Because of minimum cooling time issues, we recommend
// also printing a cooling tower or a second set of this print

numRows = 7; //number of rows minus 1
   // value of 7 gives 8 rows
function oddOffset(row) = row;
boxsize = 6; //multiplier in x and y directions, mm
zsize = 2; //multiplier in z direction,mm

//recursive factorial function
//from OpenSCAD documentation example
function factorial(n) = n == 0 ? 1 : factorial(n - 1) * n;

// n choose k function
function nchoosek(n, k) = factorial (n) /
   (factorial(k) * factorial (n-k) );


for(y = [0:numRows], x = [0:y]) {
   union() 
   translate([boxsize*(x-y/2), boxsize*y,0])
   cube([boxsize,boxsize,zsize*nchoosek(y,x)]);
}
// end model
