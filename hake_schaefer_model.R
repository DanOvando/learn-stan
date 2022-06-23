library(rstan)
library(tidyverse)
library(here)
library(ggdist)
library(readr)
rstan_options(auto_write = T)
options(mc.cores = parallel::detectCores())

#load in data
hake <- readr::read_csv(here::here("data","namibian_hake_data.csv"))

# clean up data names
hake <- hake %>% 
  set_names(tolower) %>% 
  mutate(year = 1:nrow(.))

# quick exploratory plot
hake %>% 
  pivot_longer(-year,'variable','value') %>% 
  ggplot(aes(year, value, color = variable)) + 
  geom_point() + 
  facet_wrap(~variable, scales = 'free_y')

warmup <- 4000 # number of warmup iterations

iter <- 10000 # total iteraions

chains <- 4 # number of chains

hake_data <- list(n_years = nrow(hake),
                  years = hake$year,
                  harvest = hake$catch,
                  index = hake$cpue)

# fit the basic model
hake_fit <- rstan::stan(file = here("src","schaefer.stan"),
                        data = hake_data,
                        iter = iter,
                        warmup = warmup,
                        chains = chains,
                        cores = chains)

hake_index_fits <-
  tidybayes::spread_draws(hake_fit, index_hat[year], pp_index[year] , biomass[year], ndraws = 200) # use the tidybayes package to pull out the things I want to plot, in particular the estimated abundance index and the posterior predictive abundance index

# plot fit to index
hake_index_fits %>%
  ggplot(aes(year, pp_index)) +
  stat_lineribbon(aes(fill = stat(.width)), .width = ppoints(50), alpha = 0.75) +
  geom_point(data = hake,
             aes(year, cpue),
             size = 4,
             color = "tomato")

# plot posterior predictive fits
hake_index_fits %>%
  ggplot(aes(year, index_hat)) +
  stat_lineribbon(aes(fill = stat(.width)), .width = ppoints(50), alpha = 0.75) +
  geom_point(data = hake,
             aes(year, cpue),
             size = 4,
             color = "tomato")

# now, repeat but with a fancier model, with process error and estimating fishing mortality rate instead of the fmax trick 

hake_data <- list(n_years = nrow(hake),
                  years = hake$year,
                  harvest = hake$catch,
                  index = hake$cpue)


state_space_hake_fit <- stan(
  file = here::here("src","state_space_schaefer.stan"),
  data = hake_data,
  chains = chains,
  warmup = warmup,
  iter = iter,
  cores = chains,
  refresh = 250,
  seed = 42,
  control = list(max_treedepth = 15,
                 adapt_delta = 0.9))



state_space_hake_index_fits <-
  tidybayes::spread_draws(state_space_hake_fit, index_hat[year], pp_index[year] , biomass[year], ndraws = 200)

state_space_hake_index_fits %>%
  ggplot(aes(year,index_hat)) +
  stat_lineribbon(aes(fill = stat(.width)), .width = ppoints(50), alpha = 0.75) +
  geom_point(data = hake, aes(year, cpue), size = 4, color = "tomato")


state_space_hake_index_fits %>%
  ggplot(aes(year, pp_index)) +
  stat_lineribbon(aes(fill = stat(.width)), .width = ppoints(50), alpha = 0.75) +
  geom_point(data = hake, aes(year, cpue), size = 4, color = "tomato")


