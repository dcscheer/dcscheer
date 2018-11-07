### tidycensus ###
library(tidycensus)
library(tidyverse)

# input api key
census_api_key("8516f2ef65a97f2d29e3f0dbee1793540df44780", install = T)

# load variables (for 2015 5-year ACS)
v15 <- load_variables(2015, "acs5", cache = TRUE)


# total pop
zc_pop <- get_acs(geography = "zip code tabulation area", 
                  variables = "B01003_001", 
                  geometry = F) %>%
  rename(pop=estimate) %>%
  select(GEOID, pop)
head(zc_pop)

# median household income
zc_hhinc = get_acs(geography = "zip code tabulation area", 
                  variables = "B19013_001", 
                  geometry = F) %>%
  rename(hhinc=estimate) %>%
  select(GEOID, hhinc)
head(zc_hhinc)

# median earnings
zc_earn = get_acs(geography = "zip code tabulation area", 
                   variables = "B08121_001E", 
                   geometry = F) %>%
  rename(med_earn=estimate) %>%
  select(GEOID, med_earn)
head(zc_earn)

# median house price
zc_house = get_acs(geography = "zip code tabulation area", 
                  variables = "B25077_001", 
                  geometry = F) %>%
  rename(med_house=estimate) %>%
  select(GEOID, med_house)
head(zc_house)

# median gross rent
zc_rent = get_acs(geography = "zip code tabulation area", 
                  variables = "B25113_001E", 
                  geometry = F) %>%
  rename(med_rent=estimate) %>%
  select(GEOID, med_rent)
head(zc_rent)

# median age
zc_age = get_acs(geography = "zip code tabulation area", 
                  variables = "B23013_001E", 
                  geometry = F) %>%
  rename(med_age=estimate) %>%
  select(GEOID, med_age)
head(zc_age)

# average travel time to work
zc_hhsize = get_acs(geography = "zip code tabulation area", 
                 variables = "B25010_001E", 
                 geometry = F) %>%
  rename(avg_hhsize=estimate) %>%
  select(GEOID, avg_hhsize)
head(zc_hhsize)

# race / ethnicity
racevars <- c("C02003_003E","C02003_004E","C02003_005E","C02003_006E","B03001_002E")
zc_race <- get_acs(geography = "zip code tabulation area", 
                  variables = racevars,
                  geometry = FALSE,
                  summary_var = "B01003_001") %>%
          arrange(GEOID)

zc_race_zip = zc_race %>%
  mutate(pct = 100 * (estimate / summary_est)) %>%
  select(GEOID, variable, pct) %>%
  spread(key = variable, value = pct) %>%
  rename(white = C02003_003, black = C02003_004, native_american = C02003_005, asian = C02003_006, hispanic = B03001_002)

# education
eduvars = c("B16010_002E","B16010_003E","B16010_004E","B16010_005E","B16010_006E")
zc_edu <- get_acs(geography = "zip code tabulation area", 
                   variables = eduvars,
                   geometry = FALSE,
                   summary_var = "C27001I_002E") %>%
  arrange(GEOID)

zc_edu_zip = zc_edu %>%
  mutate(pct = 100 * (estimate / summary_est)) %>%
  select(GEOID, variable, pct) %>%
  spread(key = variable, value = pct) %>%
  rename(`less than hs` = B16010_002, `high school` = B16010_003, `some college` = B16010_004, `bachelors` = B16010_005, `graduate or professional degree` = B16010_006)

# join data
acs_zc = left_join(zc_pop, zc_hhinc, by="GEOID") %>%
  left_join(., zc_earn) %>%
  left_join(., zc_house, by="GEOID") %>%
  left_join(., zc_rent, by="GEOID") %>%
  left_join(., zc_age, by="GEOID") %>%
  left_join(., zc_hhsize, by="GEOID")

head(acs_zc)

zipll = read_csv("/Users/danielscheer/Documents/Client Notes/AT&T/store location/adjacent zips.csv")
head(zipll)

acs_zc = left_join((acs_zc %>% mutate(GEOID = as.numeric(GEOID))), (zipll %>% select(GEOID, INTPTLAT, INTPTLONG) %>% rename(lat=INTPTLAT, long=INTPTLONG)))
head(acs_zc)

library(skimr)
skim(acs_zc)

write.csv(acs_zc, file="/Users/danielscheer/Documents/Client Notes/AT&T/store location/acs_demo.csv", row.names = F)


