library(tidyverse)
library(rstan)
library(tidybayes)

# a toy model

stan_model <- "

data {
  int<lower=0> n;          // number of observations
  int<lower = 1> n_betas;  // number of betas
  vector[n] y;               // outcomes
  matrix[n,n_betas] x;          // predictors
}
parameters {

  vector[n_betas] betas;

  real sigma;
}

model {

  y ~ normal(x * betas, sigma);

  betas ~ normal(0,10);

  sigma  ~ cauchy(0,2.5);

}

generated quantities {

vector[n] y_pp;

for (i in 1:n){

  y_pp[i] = normal_rng(x[i,1:n_betas] * betas, sigma);


}


}
"

n <- 50

betas <- c(2,10)

sigma <- 10

training_data <- data.frame(x = 1:n, intercept = 1)

y = as.numeric(as.matrix(training_data) %*% betas + rnorm(n,0,sigma))

# plot(training_data$x, y)

# fit the model

stan_fit  <- stan(
  model_code = stan_model,
  data = list(n = n,
              n_betas = length(betas),
              y = y,
              x = training_data),
  chains = 1,
  warmup = 500,
  iter = 1000,
  cores = 1,
  refresh = 0             # no progress shown
)

# plot(stan_fit, pars = "betas")

# go through and get the individual draws for each parameter

tidy_posts <-  tidybayes::gather_draws(stan_fit, betas[variable])

nested_posts <- tidy_posts %>%
  group_by(.draw) %>%
  nest()

# create some new data partly outside of the range of the training data
testing_data <- data.frame(x = 20 + (1:n), intercept = 1)


new_data <- list(n = nrow(testing_data),
                 n_betas = ncol(testing_data),
                 y = rep(1,n),
                 x = testing_data
                 )

pred_foo <- function(params, stan_model, new_data) { # function to get posterior predictives given fixed parameters

  variables <- unique(params$.variable)

  inits <-
    purrr::map(variables, ~ params$.value[params$.variable == .x]) %>%
    purrr::set_names(variables)


  pp_samps <- stan(
    model_code = stan_model,
    data = new_data,
    chains = 1,
    warmup = 0,
    iter = 1,
    cores = 1,
    refresh = 0,
    init = list(inits),
    algorithm = "Fixed_param"
  )

  out <- tidybayes::tidy_draws(pp_samps)


} # close function


# iterate over posterior of parameters to generate predictions (pretending you had "new" schools data)
nested_posts <- nested_posts %>%
  mutate(preds = map(data, pred_foo, stan_model = stan_model, new_data = new_data))


unnested_posts <- nested_posts %>%
  rename(draw = .draw) %>%
  select(-data) %>%
  unnest(cols = preds)

y_pp <- unnested_posts %>%
  tidyr::pivot_longer(
    cols = contains("_pp"),
    names_to = "observation",
    values_to = "prediction",
    names_pattern = "y_pp\\[(.*)\\]",
    names_ptypes = list(observation = integer())
  )

y_pp %>%
  mutate(x = observation + min(testing_data$x) - 1) %>%
  group_by(x) %>%
  summarise(mean_pred = mean(prediction),
            lower = quantile(prediction, 0.05),
            upper = quantile(prediction, 0.95)) %>%
  ungroup() %>%
  ggplot() +
  geom_ribbon(aes(x, ymin = lower, ymax = upper), alpha = 0.5) +
    geom_line(aes(x, mean_pred), color = "red") +
  scale_y_continuous(name = "y") +
  labs(caption = "Red line is mean posterior predictive, grey shaded area 90% credible interval")

