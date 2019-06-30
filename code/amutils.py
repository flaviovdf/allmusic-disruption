# -*- coding: utf8

import gzip
import json
import networkx as nx


def extract_id(txt):
    pos = txt.rfind('mn')
    return txt[pos:pos+12]


def build_reverse_index(json_data):
    decades = {}
    genres = {}
    styles = {}
    for key, value in json_data.items():
        for genre_id, genre_name in value['genres'].items():
            if genre_name not in genres:
                genres[genre_name] = set()
            genres[genre_name].add(key)
            break

        for style_id, style_name in value['styles'].items():
            if style_name not in styles:
                styles[style_name] = set()
            styles[style_name].add(key)
            break

        if value['decades']:
            decade = value['decades'][0]
            if decade not in decades:
                decades[decade] = set()
            decades[decade].add(key)
    return decades, genres, styles


def build_graph(json_data, nodes_to_consider=None, restrictive=False):
    G = nx.DiGraph()
    if nodes_to_consider is None:
        nodes_to_consider = set(json_data.keys())
    for artist in nodes_to_consider:
        data = json_data[artist]
        by_set = set(map(extract_id, data['influencer']))
        for by in by_set:
            if restrictive and by not in nodes_to_consider:
                continue
            G.add_edge(artist, by)
    return G


def load_am_json_data():
    fpath = '../data/artists.json.gz'
    with gzip.open(fpath) as gzip_file:
        json_data = json.load(gzip_file)
        return json_data
