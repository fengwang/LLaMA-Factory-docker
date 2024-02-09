# Fine-tune LLaMA modles in a docker

## Checkout and build the docker image

Build the image from source

```bash
git clone --recursive-submodules https://github.com/fengwang/LLaMA-Factory-docker.git
cd LLaMA-Factory-docker
docker build --file ./Dockerfile . -t llama-factory
```

Or fetch it from dockerhub

```bash
docker pull ljxha471758/llama-factory:latest
```

## Example usage

### Fine-tune chatglm3 on custom dataset






