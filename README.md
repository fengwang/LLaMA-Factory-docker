# Fine-tune LLaMA modles in a docker

## Checkout and build the docker image

```bash
git clone --recursive-submodules https://github.com/fengwang/LLaMA-Factory-docker.git
cd LLaMA-Factory-docker
docker build --file ./Dockerfile . -t llama-factory
```

## License

BSD

