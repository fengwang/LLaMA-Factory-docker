# 1) install python3
FROM ubuntu:jammy
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get clean && apt update -y && apt-get -y upgrade && apt-get install  -y python3
RUN apt-get install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa

# 2) install pip
RUN apt install -y curl
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | python3.10 -

# 3) install cuda and cudnn
RUN apt install -y nvidia-cuda-toolkit
RUN  apt-key del 7fa2af80
ADD  https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb .
RUN  dpkg -i cuda-keyring_1.0-1_all.deb
RUN apt update -y && apt install -y libcudnn8 libcudnn8-dev

# 3) install pytorch
RUN python3.10 -m pip install torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 --extra-index-url "https://download.pytorch.org/whl/cu118"

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
RUN rm -rf /usr/lib/nsight-compute /usr/lib/nsight-systems # fix out of space error when importing image
RUN rm -rf /usr/lib/x86_64-linux-gnu/nsight*

# 7) entry
#ENTRYPOINT ["tail", "-f", "/dev/null"]

