FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

MAINTAINER Yuxin Zou <yuz530@ucsd.edu>

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

#############################################
# From https://github.com/conda/conda-docker/blob/master/miniconda2/debian/Dockerfile
# Install miniconda first

ENV PATH /opt/conda/bin:$PATH
ENV CONDA_DIR /opt/conda
RUN mkdir -m 1755 /opt/conda

RUN ( echo 'Acquire::http::Timeout "20";'; echo 'Acquire::ftp::Timeout "20";' ) > /etc/apt/apt.conf.d/short-timeout.conf

RUN apt-get -qq update && apt-get -qq -y install curl bzip2 \
    && curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp $CONDA_DIR \
    && rm -rf /tmp/miniconda.sh \
    && conda install -y python=3.6 \
    && conda update conda \
    && apt-get -qq -y remove curl bzip2 \
    && apt-get -qq -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log \
    && conda clean --all --yes

#############################################
# TF dependencies per the TF standard Dockerfile

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip --no-cache-dir install \
	jupyter \
	ipython==6.5.0 \
	jupyter_console==5.2.0

RUN pip --no-cache-dir install \
        Pillow \
        h5py \
        ipykernel \
        matplotlib \
        numpy \
        pandas \
        scipy \
        sklearn \
        && \
    python -m ipykernel.kernelspec

RUN apt-get -qq update && apt-get -qq -y install \
       less nano vim \
       openssh-client \
       dnsutils iputils-ping \
       wget

RUN apt-get -qq update && apt-get -qq -y install \
       cuda-core-9-0 \
       cuda-command-line-tools-9-0

RUN apt-get -qq update && apt-get -qq -y install \
	git screen tmux openssh-sftp-server cmake

# Fix screen binary permissions for non-setuid execution (so NSS_WRAPPER can funciton)
RUN chmod g-s /usr/bin/screen
RUN chmod 1777 /var/run/screen

RUN pip install git+https://github.com/agt-ucsd/nbresuse.git
RUN jupyter serverextension enable --sys-prefix --py nbresuse
RUN jupyter nbextension install --sys-prefix --py nbresuse
RUN jupyter nbextension enable --sys-prefix --py nbresuse

########################################################
# Custom tools below (e.g. TF, pytorch)
########################################################

########################################################
# Install TensorFlow GPU version from their CI repository
RUN pip install tensorflow-gpu==1.12.0
RUN apt-get -qq -y install protobuf-compiler python-pil python-lxml

RUN pip install keras
RUN conda install pytorch torchvision cudatoolkit=9.0 -c pytorch
# from the layers branch, which has ROI pooling
RUN pip install git+git://github.com/pytorch/vision.git@24577864e92b72f7066e1ed16e978e873e19d13d

RUN conda install --yes nltk seaborn pandas

RUN pip install spacy
RUN python -m spacy download en
RUN python -m spacy download de
RUN python -m spacy download fr

COPY allennlp-requirements.txt /
# RUN pip install -r allennlp-requirements.txt
RUN pip install allennlp

########################################################
# Final setup steps below
# clean conda cache last to free up space in the image
RUN conda clean --all --yes

# Install entrypoint
COPY run_jupyter.sh /
RUN chmod 755 run_jupyter.sh

RUN pip install jupyterhub

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
ENV DEBIAN_FRONTEND teletype

RUN export PYTHONPATH=~/r2c

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

# Fear not, root execution won't be possible within our instructional cluster
CMD ["/run_jupyter.sh", "--allow-root"]
