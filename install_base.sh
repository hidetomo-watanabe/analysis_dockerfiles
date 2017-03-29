#!/bin/bash

cd /home/hidetomo
sh Anaconda3.sh
source ~/.bashrc
conda update -y conda
conda update -y anaconda
conda update -y --all
conda install -y pymongo
conda install -y graphviz
pip install graphviz
