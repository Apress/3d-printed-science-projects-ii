//A model of the probability distributions of throwing
//different combinations of dice 
//File diceProbability.scad

base = .6; //added base piece for stability
size = [3, 10, 100]; //dimensions of the model
// if the following line is uncommented, shows 
// one 12 sided die vs 2, 6 sided ones, etc
//dice = [[1, 12], [2, 6], [3, 4], [4, 3], [6, 2]];

// if the following line is uncommented, shows results for
// six-sided dice- first one (uniform), then two (triangle), 
dice = [[1, 6], [2, 6], [3, 6], [4, 6], [5, 6]];

//accumulation function
function sum(a, i = 0) = (i >= len(a)) ? 0 : 
   a[i] + sum(a, i + 1);

function count(a, n, i = 0) = (i >= len(a)) ? 0 : 
   ((a[i] == n) ? 1 : 0) + count(a, n, i + 1);

module distribution(n = 2, d = 6) {
   combinations = [for(i = [0:pow(d, n) - 1]) 
      [for(j= [0:n - 1]) (floor(i / pow(d, j)) % d) + 1]];
   totals = [for(i = combinations) sum(i)];
   distribution = [for(i = [0:d * n]) count(totals, i)];
   echo(distribution);
   for(i = [0:d * n]) translate([i, 0, 0]) 
      cube([1.0001, 1.0001, 
      distribution[i] / (pow(d, n)) + base / size[2]]);
}

// scale the output 
scale(size) for(i = [0: len(dice)]) translate([0, i, 0]) distribution(dice[i][0], dice[i][1]);
// end model