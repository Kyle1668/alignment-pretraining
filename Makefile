# Configuration
LM_EVAL_TASKS_PATH ?= /Users/kyle/repos/research/alignment_pretraining/lm_eval_tasks
TASKS ?= anthropic_propensity_human_written
WANDB_PROJECT ?= Pretraining-Alignment-Evals-HF
WANDB_ENTITY ?= kyledevinobrien1

# Run evaluation directly on host
eval_hf:
ifndef MODEL
	$(error MODEL is required. Usage: make eval_hf MODEL=<model_name>)
endif
	lm_eval --model hf \
		--model_args pretrained=$(MODEL),dtype=bfloat16,parallelize=True,attn_implementation=flash_attention_2 \
		--wandb_args project=$(WANDB_PROJECT),entity=$(WANDB_ENTITY),name=$(MODEL) \
		--tasks $(TASKS) \
		--batch_size 64 \
		--include_path ./lm_eval_tasks/

eval_hf_mac:
ifndef MODEL
	$(error MODEL is required. Usage: make eval_hf MODEL=<model_name>)
endif
	lm_eval --model hf \
		--model_args pretrained=$(MODEL),dtype=bfloat16,parallelize=True \
		--wandb_args project=$(WANDB_PROJECT),entity=$(WANDB_ENTITY),name=$(MODEL) \
		--tasks $(TASKS) \
		--batch_size 8 \
		--include_path ./lm_eval_tasks/ \
		--device mps