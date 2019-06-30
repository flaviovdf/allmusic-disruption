# -*- coding: utf8

import networkx as nx
import numpy as np
import pandas as pd
import plac


def compute_disruption(G, min_in=1, min_out=0):

    id_to_node = dict((i, n) for i, n in enumerate(G.nodes))
    in_count = dict(G.in_degree(G.nodes))
    out_count = dict(G.out_degree(G.nodes))

    F = nx.to_scipy_sparse_matrix(G, format='csr')
    T = nx.to_scipy_sparse_matrix(G, format='csc')
    D = np.zeros(shape=(F.shape[0], 6))

    for node_id in range(F.shape[0]):
        if in_count[id_to_node[node_id]] >= min_in and \
                out_count[id_to_node[node_id]] >= min_out:
            ni = 0
            nj = 0
            nk = 0

            outgoing = F[node_id].nonzero()[1]
            incoming = T[:, node_id].nonzero()[0]
            outgoing_set = set(outgoing)

            for other_id in incoming:
                second_level = F[other_id].nonzero()[1]
                if len(outgoing_set.intersection(second_level)) == 0:
                    ni += 1
                else:
                    nj += 1

            # who mentions my influences
            who_mentions_my_influences = np.unique(T[:, outgoing].nonzero()[0])
            for other_id in who_mentions_my_influences:
                # do they mention me?! if no, add nk
                if F[other_id, node_id] == 0 and other_id != node_id:
                    nk += 1

            D[node_id, 0] = ni
            D[node_id, 1] = nj
            D[node_id, 2] = nk
            D[node_id, 3] = (ni - nj) / (ni + nj + nk)
            D[node_id, 4] = in_count[id_to_node[node_id]]
            D[node_id, 5] = out_count[id_to_node[node_id]]
        else:
            D[node_id, 0] = np.nan
            D[node_id, 1] = np.nan
            D[node_id, 2] = np.nan
            D[node_id, 3] = np.nan
            D[node_id, 4] = in_count[id_to_node[node_id]]
            D[node_id, 5] = out_count[id_to_node[node_id]]

    return pd.DataFrame(D, index=G.nodes,
                        columns=['ni', 'nj', 'nk', 'disruption', 'in', 'out'])


def main(input_graph: ('Input file, list of edges', 'positional', None, str),
         output_file: ('Output file, a csv', 'positional', None, str),
         directed: ('Indicates if the graph is connected', 'flag', 'd')):

    if directed:
        G = nx.DiGraph()
    else:
        G = nx.Graph()

    with open(input_graph) as graph_file:
        for line in graph_file:
            src, dst = line.strip().split()
            G.add_edge(src, dst)

    df = compute_disruption(G)
    df.to_csv(output_file)


if __name__ == '__main__':
    plac.call(main)
