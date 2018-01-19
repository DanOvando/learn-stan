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

  real<lower = -2, upper = 0> log_r; // intrinsic growth rate

  real  log_k; //carrying capacity

  real<lower = 0, upper = 1e-3> q;

  // real<lower=5000, upper=100000> iq;

  real<lower = 0> sigma_process; // process error

  real<lower = 0> sigma_observation; // observation error

  real<lower=-1, upper=1>  log_pop_devs[n_years]; //  process deviations

  vector<lower=0, upper=0.8>[n_years]  u; //  fishing mortality

  // vector<lower=1.1, upper=500>[n_years]  iu; //  inverse fishing mortality

  real<lower = 0> sigma_harvest; // observation error


}

transformed parameters{

real r;

real k;

// real q;

// vector[n_years] u; //  process deviations

vector[n_years] population; // vector of population deviations

  vector[n_years] harvest_hat; // vector of estimated harvest

  vector[n_years] index_hat; // vector of estimated index

  vector[n_years] log_index_hat; // vector of estimated index

  real temp;

  real counter;

  counter = 0;

// u = 1 ./ iu;

r = exp(log_r);

k = exp(log_k);

// q = 1/iq;


population[1] = k*exp(log_pop_devs[1]);

harvest_hat[1] = population[1] * u[1];

// population[1] = k;

  for (t in 2:n_years){

    temp = (population[t - 1] + r * population[t - 1] * (1 - population[t - 1]/k) - harvest_hat[t - 1])* exp(log_pop_devs[t]);

    population[t] = temp;

    harvest_hat[t] = population[t] * u[t];


// print(counter)

  } // close loop

  // print(counter)

  index_hat = q * population; //* k;

  log_index_hat = log(index_hat);
}

model{

  log_pop_devs ~ normal(0, sigma_process);

  // observation model

  log_index ~ normal(log_index_hat, sigma_observation);

  harvest ~ normal(harvest_hat, sigma_harvest);

  log_k ~ uniform(log(2000),log(8000));

  log_r ~ normal(log(.3), 0.25);

  sigma_process ~ normal(0, 2);

  sigma_observation ~ normal(0,2);

  sigma_harvest ~ normal(0,2);

}

generated quantities{

vector[n_years] pp_log_index_hat;


 for (i in 1:n_years){

    pp_log_index_hat[i] = normal_rng(log_index_hat[i], sigma_observation);

 }

}
