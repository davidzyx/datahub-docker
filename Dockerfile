FROM ucsdets/instructional:ets-pytorch-py3-cuda9-20190130v1

MAINTAINER Yuxin Zou <yuz530@ucsd.edu>

RUN python -m spacy download en
RUN python -m spacy download de

RUN conda install --yes seaborn

# clean conda cache last to free up space in the image
RUN conda clean --all --yes
