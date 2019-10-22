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

  real log_k; //carrying capacity

  real <lower = 0, upper = 0.5> q;

  real<lower = 0> sigma_observation; // observation error

  real<lower = 0, upper = 0.8> mean_u;

  vector[n_years]  u_dev; //  fishing mortality

  real<lower = 0> sigma_u;

  real<lower = 0> sigma_harvest; // observation error


}

transformed parameters{

real r;

real k;

real u[n_years]; //  process deviations

vector[n_years] population; // vector of population deviations

  vector[n_years] harvest_hat; // vector of estimated harvest

  vector[n_years] index_hat; // vector of estimated index

  vector[n_years] log_index_hat; // vector of estimated index

  real temp;

  real counter;

  counter = 0;

for (i in 1:n_years){
u[i] =  mean_u + sigma_u * u_dev[i];
}

// mean_u + sigma_u .*

r = exp(log_r);

k = exp(log_k);

// q = 1/iq;


population[1] = k;

harvest_hat[1] = population[1] * u[1];

// population[1] = k;

  for (t in 2:n_years){

    temp = (population[t - 1] + r * population[t - 1] * (1 - population[t - 1]/k) - harvest_hat[t - 1]);

    population[t] = temp;

    harvest_hat[t] = population[t] * u[t];


    // if (temp < 0.001) {
    // counter = counter + 1;
    //   population[t] = 1/(2-temp/0.001);
    //
    // } else {

    // }

// print(counter)

  } // close loop

  // print(counter)

  index_hat = q * population; //* k;

  log_index_hat = log(index_hat);
}

model{

  // observation model

  // u ~ normal(0, sigma_u);

  log_index ~ normal(log_index_hat, sigma_observation);

  harvest ~ normal(harvest_hat, sigma_harvest);

  log_k ~ uniform(log(2000),log(8000));

  log_r ~ normal(log(.2), 0.25);

  sigma_observation ~ normal(0,1);

  sigma_harvest ~ normal(0,1);

  sigma_u ~ normal(0,1);

  u_dev ~ normal(0,1);



}

generated quantities{

vector[n_years] pp_log_index_hat;


 for (i in 1:n_years){

    pp_log_index_hat[i] = normal_rng(log_index_hat[i], sigma_observation);

 }

}


