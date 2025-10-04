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

convert_and_upload:
ifndef EXPERIMENT_NAME
	$(error EXPERIMENT_NAME is required. Usage: make convert_and_upload EXPERIMENT_NAME=<name> CHECKPOINT_NUMBER=<number>)
endif
ifndef CHECKPOINT_NUMBER
	$(error CHECKPOINT_NUMBER is required. Usage: make convert_and_upload EXPERIMENT_NAME=<name> CHECKPOINT_NUMBER=<number>)
endif
	module purge && \
	module load PrgEnv-cray && \
	module load cuda/12.6 && \
	module load brics/nccl/2.21.5-1 && \
	source /home/a5k/kyleobrien.a5k/miniconda3/bin/activate && \
	conda activate neox && \
	cd /home/a5k/kyleobrien.a5k/filtering_for_danger && \
	python ./scripts/upload/convert_and_upload.py \
		--experiment_name "$(EXPERIMENT_NAME)" \
		--neox_checkpoint "$(CHECKPOINT_NUMBER)" \
		--hf_org Kyle1668 \
		--neox_checkpoints_path /projects/a5k/public/checkpoints/pretraining_alignment/ \
		--local_hf_checkpoints_path /projects/a5k/public/checkpoints/hf_checkpoints \
		--conversion_script_path /home/a5k/kyleobrien.a5k/gpt-neox/tools/ckpts/convert_neox_to_hf.py \
		--task_include_path /home/a5k/kyleobrien.a5k/alignment-pretraining/lm_eval_tasks \
		--eval_tasks anthropic_propensity_human_written,redwood_propensity_evals,mmlu,piqa,lambada,hellaswag \
		--wandb_entity kyledevinobrien1 \
		--wandb_project Pretraining-Alignment-Evals-HF \
		--skip-if-exists \
		--force-eval-if-exists

convert_and_upload_pt_alignment_continue_baseline_v1:
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=36
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=72
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=108
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=144
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=180
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=216
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=252
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=288
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=324
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1 CHECKPOINT_NUMBER=360

convert_and_upload_pt_alignment_continue_baseline_v1_5:
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=65
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=130
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=195
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=260
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=325
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=390
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=455
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=520
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=585
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5 CHECKPOINT_NUMBER=650

convert_and_upload_pt_alignment_continue_baseline_v1_5_replay_only:
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=65
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=130
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=195
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=260
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=325
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=390
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=455
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=520
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=585
	make convert_and_upload EXPERIMENT_NAME=pt_alignment_continue_baseline_v1_5_replay_only CHECKPOINT_NUMBER=650

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
