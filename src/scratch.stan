data{

int n; // the number of observations

int p;

vector[n] y; //

vector[n] x;

real z[n];

int ind[p];

//array[p] int ind;

}
parameters{

  real beta;

  real<lower = 0> sigma;


}
model {

real test[10];
//
int cc;
//
int CC;
//
 CC = 10;

print(y[ind]);

for (i in 1:10){


}

cc= 1;

while (cc <= CC) {

  cc = cc + 1;

  // print(cc)

}

if (cc == CC){

// print("hooray")
}

// vector[5] h;
//
// vector[10] k;
//
// vector[2] vX;
//
// int g[5];
//
// g = {1,2,3,4,7};
//
// h = x[g] .* y[g];

  y ~ normal(x * beta, sigma);

}


