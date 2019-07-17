# Quantifying Disruptive Influence in the AllMusic Guide

## Léame-Mucho

Code and datasets for the all-music disruption paper published @ ISMIR 2019.
For most cases, what you want is as follows:

1. Install the requirements
1. Run `jupyter notebook`
1. Open the `./eda-notebooks/Disruption.ipynb`
1. Play

## Requirements

Install the following packages with `pip`. An anaconda release should have everything.

1. ipywidgets -- https://ipywidgets.readthedocs.io/en/stable/
1. matplotlib
1. numpy
1. pandas
1. plac (for the scripts only)

## Data

The `data` folder contains all of our datasets. In particular, you are likely
interested on the `data/artists.json.gz`. This is our full All-Music crawl.
It may be loaded using any json reader.

**Iteration order warning:** The json has both lists and maps. Given that
Python 3.6 maintains insertion order on maps, the information on the file will
be loaded in the order listed (during crawl) on the the All-Music website. This
is relevant for some features such as genres. The first one is usually the most
relevant. If you load the json without maintaining order, you will not have
this notion of most important genres.

The json data file should be self-explanatory.

## Interactive Notebook and Paper Code

We have two folders one with Python code and another with R code. One author
likes Python, the other likes R. That's just how things are. The `code` and
`r-code` folders is mostly auxiliary code (more on this on the next section).
You will likely want to check out the notebooks on the `./eda-notebooks`
folder.

One particular Python notebook of interest is the `Disruption.ipynb`. It is
an interactive notebook that is able to compute disruption for various subsets
of the graph. It is able to filter based on decades, genres, styles and degree.
The notebook has information on how to reproduce the results.

One particular R markdown of interest is the `explore-artist-disruption.Rmd`.
It may be used to explore summarized views of disruption. This is the base
for many of the plots we provide in the paper. As is, the notebook has
some interesting analysis that did not fit in the final manuscript.

## Auxiliary Code and Scripts

If you just want some scripts and functions to load the data or
compute disruption in other settings, check the `code` folder. There is
one file related to the all music data, and one script that computes
disruption.

The scripts require the plac library.
