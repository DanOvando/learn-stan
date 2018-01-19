data{

  int<lower = 0> n_years; // the number of years

  vector[n_years] years; // years

  vector[n_years] index; // cpue index

  vector[n_years] harvest; // vector of catch, since apparantly catch is a reserved word


}

transformed data {

  vector[n_years] log_index;

  log_index = log(index);
}


parameters{

  real<lower = -5> log_r; // intrinsic growth rate

  real <lower = -1> log_k; //carrying capacity

  real<lower=1, upper=5000> iq;

  real<lower = 0> sigma_observation; // observation error


}

transformed parameters{

  real r;

  real k;

  real q;

  vector[n_years] population; // vector of population deviations

  vector[n_years] index_hat; // vector of estimated index

  vector[n_years] log_index_hat; // vector of estimated index

  r = exp(log_r);

  k = exp(log_k);

  q = 1/iq;

  population[1] = k;

  for (t in 2:n_years){

    temp = population[t - 1] + r * population[t - 1] * (1 - population[t - 1]/k) - harvest[t - 1];

    population[t] = temp;

  } // close loop

  index_hat = q * population; //* k;

  log_index_hat = log(index_hat);
}

model{


  // observation model

  // log_index ~ normal(log_index_hat, sigma_observation);
  //
  // log_k ~ uniform(log(2000),log(8000));
  //
  // log_r ~ normal(log(.2), 0.25);
  //
  // sigma_observation ~ cauchy(0,2.5);

}

generated quantities{

  vector[n_years] pp_log_index_hat;


  for (i in 1:n_years){

    pp_log_index_hat[i] = normal_rng(log_index_hat[i], sigma_observation);

  }

}


