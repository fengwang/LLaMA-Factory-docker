# Fine-tune LLaMA models in a docker

## Checkout and build the docker image

Build the image using [LLaMA-Factory source code](https://github.com/hiyouga/LLaMA-Factory)

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

#### Download chatglm3-6b model

```bash
mkdir -p models
git clone https://huggingface.co/THUDM/chatglm3-6b ./models/chatglm3-6b
```

#### Prepare dataset

Here we use [alpaca-gpt4 dataset](https://huggingface.co/datasets/vicgalle/alpaca-gpt4)

```bash
mkdir -p datasets
wget https://github.com/fengwang/LLaMA-Factory/raw/main/data/dataset_info.json -O datasets/dataset_info.json
wget https://github.com/fengwang/LLaMA-Factory/raw/main/data/alpaca_gpt4_data_en.json -O datasets/alpaca_gpt4_data_en.json
```


#### Fine-tune model

Single GPU mode
```bash
docker run --rm -it --gpus all  -v $(pwd)/models:/models -v $(pwd)/output:/output -v $(pwd)/datasets:/data llama-factory  python3.10 /app/src/train_bash.py  --stage sft   --do_train --model_name_or_path /models/chatglm3-6b --dataset alpaca_gpt4_en --dataset_dir /data   --template chatglm3   --finetuning_type lora  --lora_target query_key_value  --output_dir /output --overwrite_cache  --per_device_train_batch_size 4 --gradient_accumulation_steps 4  --lr_scheduler_type cosine --logging_steps 10   --save_steps 1000  --learning_rate 5e-5  --num_train_epochs 3.0 --plot_loss  --fp16
```

Multiple GPU mode (8 GPU example)
```bash
docker run --rm -it --gpus all  -v $(pwd)/models:/models -v $(pwd)/output-chatglm3-6b:/output -v $(pwd)/dataset:/data -v $(pwd)/example:/config llama-factory deepspeed --num_gpus 8 --master_port=9901  /app/src/train_bash.py  --deepspeed '/config/ds_config.json'  --stage sft   --do_train --model_name_or_path /models/chatglm3-6b --dataset alpaca_gpt4_en --dataset_dir /data   --template chatglm3   --finetuning_type lora   --lora_target query_key_value  --output_dir /output --overwrite_cache  --per_device_train_batch_size 8 --gradient_accumulation_steps 1  --lr_scheduler_type cosine --logging_steps 10   --save_steps 100  --learning_rate 5e-5  --num_train_epochs 3.0 --plot_loss  --fp16   --warmup_steps 0  --lora_rank 64  --lora_dropout 0.1  --lora_target all
```
**remember to change the `--num_gpus` parameter and adjust the deepspeed [config file](./examples/ds_config.json) accordingly.**



#### Merge lora weights

TOVERIFY
```bash
docker run --rm -it --gpus all  -v $(pwd)/models:/models -v $(pwd)/output:/output -v $(pwd)/merged_model:/new_model -v $(pwd)/datasets:/data llama-factory  python3.10 /app/src/export_model.py  --model_name_or_path /models/chatglm3-6b --adapter_name_or_path /output --template chatglm3 --finetuning_type lora --export_dir /new_model --export_size 2  --export_legacy_format False
```


#### Test new model
TODO
```bash
```


