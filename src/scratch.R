hake <- read.table(here::here("data","schaefer.dat"), header=TRUE)

hake <- hake %>%
  set_names(tolower) %>%
  mutate(year = 1:nrow(.))

hake %>%
  gather('variable','index', -year) %>%
  ggplot(aes(year, index, color = variable)) +
  geom_point() +
  facet_wrap(~variable, scales = 'free_y')

warmups <- 4000

total_iterations <- 2*warmups

n_chains <- 4

hake_data <- list(n_years = nrow(hake),
                  years = hake$year,
                  harvest = hake$catch,
                  index = hake$index)


uprox <- hake_data$harvest

initials <-
  list(
    log_r = -1.010073 ,
    log_k = 7.973823,
    q = 1e-4,
    sigma_observation = 0.2,
    sigma_harvest = 0.2,
    mean_u =  mean(hake_data$harvest / exp(7.973823)),
    u_dev = (hake_data$harvest - mean(hake_data$harvest)) / sd(hake_data$harvest))


hake_fit <- stan(
  file = here::here("scripts","non-centered-schaefer.stan"),
  data = hake_data,
  chains = n_chains,
  warmup = warmups,
  iter = total_iterations,
  cores = n_chains,
  refresh = 250,
  seed = 42,
  init =  map(1:n_chains, ~map(initials, ~jitter(.x, 1)), initials = initials),
  control = list(max_treedepth = 15,
                 adapt_delta = 0.95))


hake_mcmc <- hake_fit %>%
  rstan::extract(permuted = F)

hake_names <- dimnames(hake_mcmc)$parameters

hake_mcmc <- plyr::alply(hake_mcmc, .margins = 3, .dims = T) %>%
  map_df(as_data_frame, .id = 'variable') %>%
  gather(chain, estimate, -variable) %>%
  mutate(chain = str_replace_all(chain,'\\D',"") %>% as.factor()) %>%
  group_by(variable, chain) %>%
  mutate(transition = 1:length(estimate)) %>%
  ungroup()


 hake_mcmc %>%
  ungroup() %>%
  filter(variable == 'q') %>%
  ggplot(aes(transition, estimate, color = chain)) +
  geom_line(show.legend = F) +
  facet_wrap(~chain, scales = 'free_y')


 hake_mcmc %>%
   ungroup() %>%
   filter(str_detect(variable, 'sigma') ) %>%
   ggplot(aes(transition, estimate, color = chain)) +
   geom_line(show.legend = F) +
   facet_wrap(variable~chain, scales = 'free_y')

hake_mcmc %>%
  ungroup() %>%
  filter(str_detect(variable, 'log_pop_dev')) %>%
  mutate(pop_year = str_replace_all(variable, "\\D","") %>% as.numeric()) %>%
  ggplot(aes(pop_year, estimate, color = transition %>% as.factor())) +
  geom_line(show.legend = F) +
  facet_wrap(~chain, scales = 'free_y')

hake_summary <- summary(hake_fit)$summary %>%
  as.data.frame() %>%
  mutate(variable = rownames(.)) %>%
  as_data_frame()

hake_summary %>%
  ggplot(aes(Rhat)) +
  geom_histogram() +
  geom_vline(aes(xintercept = 1.1), color = 'red')


hake_fit_index <- hake_summary %>%
  filter(str_detect(variable,'index')) %>%
  mutate(year = str_replace_all(variable,'\\D','') %>% as.numeric()) %>%
  mutate(variable = str_replace_all(variable,"(\\d)|(\\[)|(\\])","")) %>%
  select(mean, variable, year) %>%
  spread(variable, mean) %>%
  mutate(true_index = hake$index)


biomass <- hake_summary %>%
  filter(str_detect(variable,'population')) %>%
  mutate(year = str_replace_all(variable,'\\D','') %>% as.numeric()) %>% mutate(year = hake$year)


harvest <- hake_summary %>%
  filter(str_detect(variable,'harvest_hat')) %>%
  mutate(year = str_replace_all(variable,'\\D','') %>% as.numeric()) %>% mutate(year = hake$year)


b_and_c <- biomass %>%
  ggplot() +
  geom_line(aes(year, mean), linetype = 2, color = 'red') +
  geom_ribbon(aes(year, ymin = `2.5%`, ymax = `97.5%`), alpha = 0.25, fill = 'red') +
  geom_point(data = hake, aes(year, catch)) +
  geom_line(data = harvest, aes(year, mean), linetype = 2, color = 'red') +
  geom_ribbon(data = harvest,aes(year, ymin = `2.5%`, ymax = `97.5%`), alpha = 0.25, fill = 'red')


fit_plot <- hake_fit_index %>%
  select(year, true_index,index_hat) %>%
  ggplot() +
  geom_line(aes(year, index_hat)) +
  geom_point(aes(year, true_index))

d <- b_and_c + fit_plot + plot_layout(ncol = 2, nrow = 1)

d

