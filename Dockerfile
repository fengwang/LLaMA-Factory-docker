# 1) install python3 and pip
FROM ubuntu:jammy
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get clean && apt update -y && apt-get -y upgrade && apt-get install  -y python3 curl build-essential python3.10-dev
RUN apt-get install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | python3.10 -

# 2) install cuda and cudnn
RUN apt-key del 7fa2af80
ADD https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb .
RUN dpkg -i cuda-keyring_1.1-1_all.deb
RUN apt update -y && apt install -y cuda-toolkit-12-1 libcudnn9-cuda-12 libcudnn9-dev-cuda-12
##RUN apt-get install -y linux-headers-$(uname -r)

# 3) pre-install dependencies
RUN python3.10 -m pip install torch torchvision torchaudio deepspeed xformers

# 4) install requirements
WORKDIR /tmp
COPY submodules/LLaMA-Factory/requirements.txt /tmp/requirements.txt
RUN sed -i 's/torch/#torch/g' /tmp/requirements.txt
RUN python3.10 -m pip install -r /tmp/requirements.txt

# 5) copy workdir to /app
WORKDIR /app
COPY submodules/LLaMA-Factory/src /app/src
COPY submodules/LLaMA-Factory/data /app/data
COPY submodules/LLaMA-Factory/tests /app/tests
COPY submodules/LLaMA-Factory/evaluation /app/evaluation

# 6) clean to shrink image size
RUN python3.10 -m pip cache purge
RUN rm -rf /var/cache/apt/*
RUN rm -rf /usr/lib/nsight-compute /usr/lib/nsight-systems
RUN rm -rf /usr/lib/x86_64-linux-gnu/nsight*
RUN rm -rf /usr/share/man

