data {
  int<lower=0> N; // number of years
  real catches[N];
  real logcpue[N];
}
parameters {
 // bounded parameters provide uniform priors
  real<lower=-1> logK;
  real<lower=-5> logr;
  real<lower=1, upper=10> iq;
  real<lower=5> isigma2;
  real<lower=5> itau2;
  real<lower=-2, upper=2> u[N];
}

transformed parameters {
  real sigma2;
  real tau2;
  real q;
  real K;
  real r;
  sigma2 = 1/isigma2;
  tau2 = 1/itau2;
  q = 1/iq;
  K = exp(logK);
  r = exp(logr);
}

model {
 real B[N];
 real ypred[N];
 real temp;
 // priors
 logr~normal(-1.38, 0.51);
 iq~gamma(0.001, 0.001);
 isigma2~gamma(3.785518, 0.010223);
 itau2~gamma(1.708603, 0.008613854);
 // project dynamics
 B[1] = K;
 ypred[1] = log(B[1]) +log(q);


for(i in 2:N){
   temp = (B[i-1]+r*B[i-1]*(1-B[i-1]/K)-catches[i-1])*exp(u[i]);
   if(temp<.001){
  //increment_log_prob(-1*(temp-1)^2);
   B[i] = 1/(2-temp/.001);
   } else {
      B[i] = temp;
   }
   ypred[i] = log(B[i]) +log(q);
 }
 // hyper prior
 u~normal(0, sqrt(sigma2));
 // The likelihood
 // print(B[N])
 logcpue~normal(ypred, sqrt(tau2));
}
