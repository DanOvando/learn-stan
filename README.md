# A Practical Introduction to Stan

The goal of this document is to get users comfortable writing, diagnosing, and using Stan models. I assume that if you're reading this you know you want to do Bayesian modeling and you're interested in learning how to do it in Stan. If you're not quite there yet, some of the terminology in here may be confusing, and I strongly recommend ["Bayesian Models A Statistical Primer for Ecologists"](https://press.princeton.edu/titles/10523.html) as a great starting place for learning about Bayesian analysis. This workshop also assumes you work in or are at least comfortable with R. 

There are lots of more detailed and technical resources for learning Stan out there, and any user interested in using Stan in their research should be sure to read further to really understand what Stan is doing and why (the [official documentation](http://mc-stan.org/users/documentation/) is very good, and [Monnahan et al. 2016](http://onlinelibrary.wiley.com/doi/10.1111/2041-210X.12681/abstract) provides a great introduction to Stan for those with an Ecological bent). 

However, many of the available resources can be daunting to people unfamiliar with the Stan, or omit key steps in the "ok, but how do I actually do this" side of things. This workshop is intended to help users go from raw data to model fitting with real data and real use cases. I am in no way an expert on Stan, and this document is not intended to be a technically perfect explanation or example of the use of Stan, but rather a step-by-step example of how I at least have dealt with many of the kinds of problems that practical users encounter in using Stan (i.e. explanations are intended to be clear, not necessarily precise). Hopefully you can use this as a foundation then for building more rigorous analyses of your in in R and Stan. (Constructive) Comments and suggestions appreciated!

## Pre-Workshop Instructions

To begin with, please fork or clone this repository to the machine you will be using, since it contains scripts and data that we will ba making use of. 

**WARNING: DON'T UPGRADE TO CATALINA ON MACS!** Apparently there's a major issue running Stan on the latest macOS. 

Please make sure that

  - If you don't have it, please install the `tidyverse` suite of packages using `install.packages("tidyverse")`. If you don't like using the `tidyverse` that's fine, but it will help you work along with the examples here
  
  - Also tnstall 
    - `tidybayes`
    - `bayesplot`
    - `rstanarm`
    - `gapminder`

Second, please go to Stan's instructions on installing Stan for use with R, which you can find [here](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started)

Installing Stan can be a bit complicated on some machines, especially if you haven't run programs that require a C++ compiler before (if that sentance doesn't make sense to you, this means you), so **PLEASE DON'T WAIT UNTIL THE MORNING OF THE WORKSHOP TO TRY AND INSTALL STAN**. Try to install it a few days beforehand, and if you can't get it to work let me know and I'll try to help. 

To check that it works, once you've succesfully done all the other steps please open R and run the code below. If it works, you're good to go!

```
library(rstan)
stanmodelcode <- "
data {
  int<lower=0> N;
  real y[N];
} 

parameters {
  real mu;
} 

model {
  target += normal_lpdf(mu | 0, 10);
  target += normal_lpdf(y  | mu, 1);
} 
"

y <- rnorm(20) 
dat <- list(N = 20, y = y); 
fit <- stan(model_code = stanmodelcode, model_name = "example", 
            data = dat, iter = 2012, chains = 3, sample_file = 'norm.csv',
            verbose = TRUE) 
print(fit)
traceplot(fit)

# extract samples 
e <- extract(fit, permuted = TRUE) # return a list of arrays 
mu <- e$mu 

m <- extract(fit, permuted = FALSE, inc_warmup = FALSE) # return an array 
print(dimnames(m))

# using as.array directly on stanfit objects 
m2 <- as.array(fit)

```

Share and enjoy!
