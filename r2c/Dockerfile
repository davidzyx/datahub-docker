FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

MAINTAINER Yuxin Zou <yuz530@ucsd.edu>

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

ENV PATH /opt/conda/bin:$PATH
ENV CONDA_DIR /opt/conda
RUN mkdir -m 1755 /opt/conda

RUN ( echo 'Acquire::http::Timeout "20";'; echo 'Acquire::ftp::Timeout "20";' ) > /etc/apt/apt.conf.d/short-timeout.conf

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


# r2c specific
RUN wget https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh
RUN conda update -n base -c defaults conda
RUN conda create --name r2c python=3.6
RUN source activate r2c

RUN conda install numpy pyyaml setuptools cmake cffi tqdm pyyaml scipy ipython mkl mkl-include cython typing h5py pandas nltk spacy numpydoc scikit-learn jpeg

RUN conda install pytorch cudatoolkit=9.0 -c pytorch
RUN pip install git+git://github.com/pytorch/vision.git@24577864e92b72f7066e1ed16e978e873e19d13d

RUN pip install -r allennlp-requirements.txt
RUN pip install --no-deps allennlp==0.8.0
RUN python -m spacy download en_core_web_sm


RUN # this one is optional but it should help make things faster
RUN pip uninstall pillow && CC="cc -mavx2" pip install -U --force-reinstall pillow-simd


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
