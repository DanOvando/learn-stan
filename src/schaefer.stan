data{

int<lower = 0> n_years; // the number of years

vector[n_years] years; // years

vector[n_years] index; // abundance index (usually CPUE)

vector[n_years] harvest; // vector of harvestm not using catch since cates since apparantly catch is a reserved word

}

transformed data {

  vector[n_years] log_index;

  log_index = log(index);
}


parameters{

  real<lower = -2, upper = 0> log_r; // intrinsic growth rate

  real log_k; //carrying capacity

  real <lower = 1e-9, upper = 1> q;

  real<lower = 0> sigma_observation; // observation error

}

transformed parameters{

real r;

real k;

vector[n_years] biomass; // vector of biomass

vector[n_years] index_hat; // vector of estimated index

vector[n_years] log_index_hat; // vector of log estimated index

r = exp(log_r);

k = exp(log_k);


biomass[1] = k;

  for (t in 2:n_years){

    biomass[t] = fmax(1e-6,(biomass[t - 1] + r * biomass[t - 1] * (1 - biomass[t - 1]/k) - harvest[t - 1])); // note use of fmax here to precent population from going negative. Not the best solution, just an illustration of how to do it. 

  } // close loop

  index_hat = q * biomass; // generate abundance index

  log_index_hat = log(index_hat); // log transform
  
}

model{

  log_index ~ normal(log_index_hat, sigma_observation);

  log_r ~ normal(log(.2), 0.25);
  
  log_k ~ normal(8,2);

  sigma_observation ~ cauchy(0,2.5);


}

generated quantities{

vector[n_years] pp_log_index;

vector[n_years] pp_index;


 for (i in 1:n_years){

    pp_log_index[i] = normal_rng(log_index_hat[i], sigma_observation);

 }
 
pp_index = exp(pp_log_index); 

}


