// quick example written up in class
data {
  
  int n; // number of data points
  
  vector[n] catches;
  
  vector[n] cpue;

}


parameters {
  
  real<lower = 0> r;
  
  real log_k;
  
  real<lower = 0, upper = 1> q;
  
  real<lower = 0> sigma_obs; 
  
  
 
}

transformed parameters{
  
  vector[n] cpue_hat;
  
  vector<lower = 0>[n] biomass;
  
  real k;
  
  k = exp(log_k);
  
  biomass[1] = k;
  
 for (i in 2:n){
   
   biomass[i] = fmax(1e-3,biomass[i - 1] * ( 1 + r * (1 - biomass[i- 1] / k)) - catches[i-1]);
   
 }
 
 cpue_hat = q * biomass;
  
}


model {
  
  log(cpue) ~ normal(log(cpue_hat),sigma_obs);
  
  r ~ uniform(0,10);
  
  q ~ normal(.1,.25);
  
  log_k ~ normal(10,2);
  
  sigma_obs ~ cauchy(0,2.5);
  
}

generated quantities{
  
  vector[n] pp_cpue_hat;
  
  for (i in 1:n){
    
    pp_cpue_hat[i] = normal_rng(cpue_hat[i], sigma_obs);
  
  }
  
  
}

