functions{

  vector calc_recruits(vector rec_pars, real h, vector ssb, int n, int bh){

    vector[n] rhat;

    real beta;

    real alpha;

     if (bh == 1) {
      rhat = (0.8 * rec_pars[1] * h * ssb) ./ (0.2 * rec_pars[1] * (1 - h) +(h - 0.2) * ssb);

     } else {

      beta = log(5 * h) / (0.8 * rec_pars[2]);

      alpha = log(rec_pars[1] / rec_pars[2]) + 0.8 * beta * rec_pars[2];

      rhat = ssb .* exp(alpha - beta * ssb); //.* exp(alpha - beta .* ssb);

      }

  return rhat;


} // close function

}


data{

int<lower = 0> n; // number of observations

int<lower = 0> n_sr_params; // number of observations

// int<lower = 0> wtf; // number of observations

vector[n] ssb; // vector of observed ssb

vector[n] r; // vector of recruits

real max_r;  // max observed recruitment

real max_h; // max steepness

int<lower = 0, upper = 1> bh;

real<lower = 0> rec_par_mean[n_sr_params];

real<lower = 0> rec_par_cv[n_sr_params];

// real<lower = 0> fuck[wtf];



}
transformed data{

vector[n] log_r; // log recruitment

log_r = log(r);

}

parameters{

real<lower = 0.2, upper = max_h> h; //steepness

real<lower = 0> sigma;

vector<lower = 0 >[n_sr_params] rec_pars;

}
transformed parameters{

vector[n] rhat;

vector[n] log_rhat;

rhat = calc_recruits(rec_pars, h, ssb, n, bh);

// rhat = (0.8 * rec_pars[1] * h * ssb) ./ (0.2 * rec_pars[1] * (1 - h) +(h - 0.2) * ssb);

log_rhat = log(rhat);

}


model{
log_r ~ normal(log_rhat - 0.5 * sigma^2, sigma);

sigma ~ cauchy(0,2.5);

for (i in 1:n_sr_params){

rec_pars[i] ~ normal(rec_par_mean[i],rec_par_cv[i] * rec_par_mean[i]);

}

}

generated quantities{

  vector[n] pp_rhat;

  vector[n] log_likelihood;

  for (i in 1:n) {

   pp_rhat[i] = exp(normal_rng(log_rhat[i] - 0.5 * sigma^2, sigma));

  }

   for (i in 1:n) {

   log_likelihood[i] = normal_lpdf(log_r[i] | log_rhat[i] - 0.5 * sigma^2, sigma);

   }

}
