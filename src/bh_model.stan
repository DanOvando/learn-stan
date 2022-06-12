data{

int<lower = 0> n; // number of observations

vector[n] spawners; // vector of observed ssb

vector[n] recruits; // vector of recruits

}
transformed data{

vector[n] log_recruits; // log recruitment

log_recruits = log(recruits);
}

parameters{

real<lower = 0.2, upper = 1> h; //steepness

real log_r0; // unfished recruitment

real log_s0; // unfished spawners

real<lower = 0> sigma; // observation error


}
transformed parameters{

vector[n] recruits_hat;

vector[n] log_recruits_hat;

real r0; 

real s0;

r0 = exp(log_r0);

s0 = exp(log_s0);

recruits_hat = (0.8 * r0 * h * spawners) ./ (0.2 * s0 * (1 - h) +(h - 0.2) * spawners); // calcualte recruits


log_recruits_hat = log(recruits_hat);

}


model{

log_recruits ~ normal(log_recruits_hat - 0.5 * sigma^2, sigma); // bias correction

sigma ~ cauchy(0,2.5);

log_s0 ~ normal(15,2);

log_r0 ~ normal(8,2);

h ~ beta(6,2);
}

generated quantities{

  vector[n] pp_rhat;

  for (i in 1:n) {
   pp_rhat[i] = exp(normal_rng(log_recruits_hat[i] - 0.5 * sigma^2, sigma)); // generate posterior predictive distribution of recruits
  }

}

