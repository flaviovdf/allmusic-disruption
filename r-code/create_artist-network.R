library(tidyverse)
library(tidygraph)

allmusic_json = jsonlite::fromJSON(here::here("artists.json"))
create_edge_df = function(node, json){
    infs = json[[node]]$influencer
    
    if(length(infs) == 0){
        NULL
    }else{
        inf_ids = str_split(infs, "-") %>% 
            map_chr(~ .[[length(.)]])
        tibble(target = inf_ids, source = node)
    }
}

edges = names(allmusic_json) %>% 
    map_df(create_edge_df, json = allmusic_json)


create_node_df = function(node, json, edges){
    if(!node %in% edges){
        return(NULL)
    }
    
    decade_column = unlist(json[[node]]$decades)
    if(is.null(decade_column) | length(decade_column) == 0){
        decade_column = NULL
    } else {
        decade_column = min(decade_column, na.rm = T) %>% as.integer()
    }
    
    genres = json[[node]]$genres
    if(is.null(genres) | length(genres) == 0){
        genres = NA_character_
    } else {
        genres = genres[[1]] 
    }
    
    tibble(
        label = node,
        name = json[[node]]$name,
        earliest_decade = if_else(is.null(decade_column), NA_integer_, decade_column), 
        genre = genres
    )
}


nodes = names(allmusic_json) %>% 
    map_df(create_node_df, 
           json = allmusic_json, 
           edges = unique(c(edges$source, edges$target)))

edges = edges %>% 
    select(source, target)

influences <- tbl_graph(nodes = nodes %>% select(label), edges = edges, directed = TRUE) %>% 
    activate(nodes) %>% 
    left_join(nodes, by = "label") # why is this needed? 

t = influences %>% 
    activate(nodes) %>% 
    mutate(indegree = local_size(mindist = 1, mode = "in"), 
           outdegree = local_size(mindist = 1, mode = "out"), 
           name = nodes$name) %>% 
    as_tibble()

t %>% 
    write_csv("data/artist-network-degrees.csv")

save(influences, file = "data/influence_network.RData")
