library(rstanarm)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tidybayes)
library(ggdist)
library(palmerpenguins)

model <- rstanarm::stan_glm(body_mass_g ~ species, data = penguins)

summary(model)


gentoo <- as.data.frame(model) %>% 
  as_tibble()


gentoo %>% 
  ggplot(aes(speciesGentoo)) + 
  geom_density()


model2 <-
  rstanarm::stan_glm(
    body_mass_g ~ species + species:sex,
    data = penguins,
    adapt_delta = 0.95,
    iter = 5000,
    warmup = 2500,
    chains = 4,
    cores = 4
  )

penguins %>% 
  ggplot(aes(body_mass_g, fill = sex)) + 
  geom_density(alpha= 0.75) + 
  facet_wrap(~species)


results <- as.data.frame(model2) %>% 
  as_tibble() %>% 
  mutate(gentoo_male = `(Intercept)` + speciesGentoo + `speciesGentoo:sexmale`,
         adlie_female = `(Intercept)`,
         delta = gentoo_male - adlie_female)

results %>% 
  ggplot(aes(delta)) +
  geom_density()
