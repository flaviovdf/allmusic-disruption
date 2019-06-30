library(tidyverse)

disrupts_posts = read_csv(here::here("notebooks/cache/disrupt-artists-csvs/decade-None-genre-None-style-None-min_in-1-min_out-0-restrictive-False.samples"))

disrupts = disrupts_posts %>% 
    rename(id = X1) %>% 
    gather(key = "s", value = "disruption_s", -name, -id)

disrupts = disrupts %>%
    group_by(id, name) %>%
    summarise(
        disruption_mean = mean(disruption_s),
        confidence = if_else(disruption_mean > 0, 
                             sum(disruption_s > 0), 
                             sum(disruption_s < 0)) /
            n()
    )

rm(disrupts_posts)

disrupts %>% write_csv("data/artist-disruptions_summarized.csv")
