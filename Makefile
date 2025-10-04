# Configuration
LM_EVAL_TASKS_PATH ?= /Users/kyle/repos/research/alignment_pretraining/lm_eval_tasks
TASKS ?= anthropic_propensity_human_written_refined,mmlu,piqa,lambada,hellaswag
WANDB_PROJECT ?= Pretraining-Alignment-Evals-HF
WANDB_ENTITY ?= kyledevinobrien1
COMMA := ,

eval_hf:
ifndef MODEL
	$(error MODEL is required. Usage: make eval_hf MODEL=<model_name>)
endif
	module purge && \
	module load PrgEnv-cray && \
	module load cuda/12.6 && \
	module load brics/nccl/2.21.5-1 && \
	source /home/a5k/kyleobrien.a5k/miniconda3/bin/activate && \
	conda activate neox && \
	lm_eval --model hf \
		--model_args pretrained=$(MODEL),dtype=bfloat16,parallelize=True,attn_implementation=flash_attention_2$(if $(REVISION),$(COMMA)revision=$(REVISION)) \
		--wandb_args project=$(WANDB_PROJECT),entity=$(WANDB_ENTITY),name=$(MODEL) \
		--tasks $(TASKS) \
		--batch_size 64 \
		--write_out \
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
		--write_out \
		--include_path ./lm_eval_tasks/ \
		--device mps

eval_redwood_mac:
ifndef MODEL
	$(error MODEL is required. Usage: make eval_redwood_mac MODEL=<model_name>)
endif
	$(MAKE) eval_hf_mac MODEL=$(MODEL) TASKS=redwood_propensity_evals

eval_redwood:
ifndef MODEL
	$(error MODEL is required. Usage: make eval_redwood MODEL=<model_name>)
endif
	$(MAKE) eval_hf MODEL=$(MODEL) TASKS=redwood_propensity_evals

# Batch upload all checkpoints for an experiment using the SLURM pipeline
# Usage: make convert_and_upload_all EXPERIMENT_NAME=<name> [CHECKPOINTS_BASE_DIR=<path>]
convert_and_upload_all:
ifndef EXPERIMENT_NAME
	$(error EXPERIMENT_NAME is required. Usage: make convert_and_upload_all EXPERIMENT_NAME=<name>)
endif
	cd /home/a5k/kyleobrien.a5k/filtering_for_danger/scripts/upload && \
	./submit_all_checkpoints_for_experiment.sh $(EXPERIMENT_NAME) Kyle1668 \
		--checkpoints-base-dir $(or $(CHECKPOINTS_BASE_DIR),/projects/a5k/public/checkpoints/pretraining_alignment/) \
		--eval \
		--eval-tasks "$(TASKS)" \
		--task-include-path /home/a5k/kyleobrien.a5k/alignment-pretraining/lm_eval_tasks \
		--wandb-entity $(WANDB_ENTITY) \
		--wandb-project $(WANDB_PROJECT)

# Convenience targets for specific experiments
convert_and_upload_pt_alignment_continue_baseline_v1:
	$(MAKE) convert_and_upload_all EXPERIMENT_NAME=pt_alignment_continue_baseline_v1

convert_and_upload_pt_alignment_continue_baseline_v1_5:
	$(MAKE) convert_and_upload_all EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5

convert_and_upload_pt_alignment_continue_baseline_v1_5_replay_only:
	$(MAKE) convert_and_upload_all EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only

convert_and_upload_pt_alignment_continue_baseline_v1_6:
	$(MAKE) convert_and_upload_all EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_6

convert_and_upload_pt_alignment_continue_baseline_v1_6_replay_only:
	$(MAKE) convert_and_upload_all EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_6_replay_only

tokenize_dataset:
ifndef EXPERIMENT_NAME
	$(error EXPERIMENT_NAME is required. Usage: make tokenize_dataset EXPERIMENT_NAME=<name> NUM_DOCS=<number>)
endif
ifndef NUM_DOCS
	$(error NUM_DOCS is required. Usage: make tokenize_dataset EXPERIMENT_NAME=<name> NUM_DOCS=<number>)
endif
	module purge && \
	module load PrgEnv-cray && \
	module load cuda/12.6 && \
	module load brics/nccl/2.21.5-1 && \
	source /home/a5k/kyleobrien.a5k/miniconda3/bin/activate && \
	conda activate neox && \
	cd /home/a5k/kyleobrien.a5k/gpt-neox && \
	python tools/datasets/preprocess_data.py \
            --input /projects/a5k/public/data/$(EXPERIMENT_NAME)/data.jsonl \
            --output-prefix /projects/a5k/public/data/$(EXPERIMENT_NAME)/$(EXPERIMENT_NAME) \
            --vocab /projects/a5k/public/data/neox_tokenizer/tokenizer.json \
            --dataset-impl mmap \
            --tokenizer-type HFTokenizer \
            --append-eod \
            --num-docs $(NUM_DOCS) \
            --workers 100
