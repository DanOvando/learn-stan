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

  real<lower = 0> sigma_process; // process error

  real<lower = 0> sigma_observation; // observation error

  real<lower=-2, upper=2>  log_pop_devs[n_years]; //  process deviations


}

transformed parameters{

real r;

real k;

real q;

vector[n_years] population; // vector of population deviations

  vector[n_years] biomass; // vector of estimated biomass

  vector[n_years] index_hat; // vector of estimated index

  vector[n_years] log_index_hat; // vector of estimated index

  real temp;

  real counter;

  counter = 0;

r = exp(log_r);

k = exp(log_k);

q = 1/iq;


population[1] = k*exp(log_pop_devs[1]);

// population[1] = k;

  for (t in 2:n_years){

    temp = (population[t - 1] + r * population[t - 1] * (1 - population[t - 1]/k) - harvest[t - 1])* exp(log_pop_devs[t]);

    if (temp < 0.001) {
    counter = counter + 1;
      population[t] = 1/(2-temp/0.001);

    } else {

      population[t] = temp;
    }

// print(counter)

  } // close loop

  // print(counter)

  index_hat = q * population; //* k;

  log_index_hat = log(index_hat);

  biomass = population; //* k;

}

model{



  log_pop_devs ~ normal(0, sigma_process);

  // observation model

  log_index ~ normal(log_index_hat, sigma_observation);

  log_k ~ uniform(log(1000),log(4000));

  log_r ~ normal(log(.3), 1);

  // log_q ~ uniform(log(.000001), log(1));

  sigma_process ~ cauchy(0,2.5);

  sigma_observation ~ cauchy(0,5);

 iq ~ gamma(0.001, 0.001);

}

generated quantities{

vector[n_years] pp_log_index_hat;


 for (i in 1:n_years){

    pp_log_index_hat[i] = normal_rng(log_index_hat[i], sigma_observation);

 }

}
