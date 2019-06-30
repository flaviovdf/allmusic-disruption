filter_context = function(node_id, network){
    node_index = network %>%
        activate(nodes) %>%
        as_tibble() %>%
        summarise(index = which(node_id == label)[[1]]) %>%
        pull(index)

    i = network %>%
        activate(nodes) %>%
        mutate(
            cited_by_f = node_is_adjacent(
                to = node_index,
                mode = "out",
                include_to = F
            ),
            cites_f = node_is_adjacent(
                to = node_index,
                mode = "in",
                include_to = F
            ),
            has_subs = 0 != length(which(TRUE == cited_by_f)),
            cites_prior = if_else(
                !has_subs,
                FALSE,
                node_is_adjacent(
                    to = which(TRUE == cited_by_f),
                    mode = "in",
                    include_to = F
                ) &
                    !label == node_id
            ),
            subs_no_cites_prior = cites_prior & !cites_f
        ) %>%
        mutate(
            f = node_id == label,
            i = cites_f & !cites_prior & !subs_no_cites_prior,
            j = cites_f & cites_prior & !subs_no_cites_prior,
            k = subs_no_cites_prior,
            prec = cited_by_f
        )  %>%
        filter(i | j | k | f | prec) %>%
        select(-cited_by_f, -cites_f, -subs_no_cites_prior, -cites_prior, -has_subs)

    i
}

ijk = function(g){
    g %>%
        activate(nodes) %>%
        as_tibble() %>%
        select(-label) %>%
        summarise_all(sum)
}

create_focal_network = function(allmusic_id, network, node_info){
    filter_context(allmusic_id, network) %>%
        activate(nodes) %>%
        mutate(
            type = case_when(i ~ "i",
                             j ~ "j",
                             k ~ "k",
                             prec ~ "p",
                             f ~ "f",
                             TRUE ~ NA_character_),
            order = case_when(f ~ "focal",
                              i | j | k ~ "subsequent",
                              prec ~ "predecessor")
        )
}



test_network_filter = function(){
    test_e1 = tribble(
        ~source, ~target,
        1, "f",
        2, "f",
        3, "f",
        "f", 4,
        "f", 5
    )

    g_d_d = tbl_graph(nodes = tibble(label = unique(c(
        test_e1$source, test_e1$target))),
        edges = test_e1,
        directed = T)


    test_e2 = tribble(
        ~source, ~target,
        1, "f",
        2, "f",
        3, "f",
        1, 4,
        1, 5,
        2, 4,
        3, 5,
        "f", 4,
        "f", 5
    )

    g_d_c = tbl_graph(nodes = tibble(label = unique(c(
        test_e2$source, test_e2$target))),
        edges = test_e2,
        directed = T)

    test_e3 = tribble(
        ~source, ~target,
        3, "f",
        1, 4,
        1, 5,
        2, 4,
        3, 5,
        "f", 4,
        "f", 5
    )

    g_d_n = tbl_graph(nodes = tibble(label = unique(c(
        test_e3$source, test_e3$target))),
        edges = test_e3,
        directed = T)


    filter_context("f", g_d_d) %>% ijk
    filter_context("f", g_d_c) %>% ijk
    filter_context("f", g_d_n) %>% ijk
}
