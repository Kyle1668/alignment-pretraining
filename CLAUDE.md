# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository is for **alignment pretraining research** - evaluating language models on AI safety and alignment benchmarks using the EleutherAI LM Evaluation Harness. The primary focus is measuring propensity for concerning AI behaviors (power-seeking, deception, coordination, self-awareness, etc.) using the Anthropic advanced-ai-risk evaluation dataset.

## Common Commands

### Running Evaluations

```bash
# Evaluate a model on GPU (with Flash Attention 2)
make eval_hf MODEL=<model_name>

# Evaluate a model on Mac (MPS backend)
make eval_hf_mac MODEL=<model_name>

# Run specific tasks (default: anthropic_propensity_human_written)
make eval_hf MODEL=<model_name> TASKS=<task_name>

# Change WandB project/entity
make eval_hf MODEL=<model_name> WANDB_PROJECT=<project> WANDB_ENTITY=<entity>
```

**Examples:**
```bash
make eval_hf MODEL=meta-llama/Llama-3.3-70B-Instruct
make eval_hf_mac MODEL=answerdotai/ModernBERT-large
```

### Data Download Scripts

```bash
# Download StampyAI alignment research dataset
python download_alignment_dataset.py

# Explore downloaded alignment dataset
python explore_dataset.py
```

## Code Architecture

### LM Eval Tasks Structure

The repository uses the **EleutherAI LM Evaluation Harness** for model evaluation. Custom tasks are organized in `lm_eval_tasks/`:

```
lm_eval_tasks/
└── anthropic_propensity_human_written/
    ├── _anthropic_propensity_human_written.yaml  # Group config
    ├── coordinate_itself.yaml                     # Individual task configs
    ├── coordinate_other_ais.yaml
    ├── power_seeking_inclination.yaml
    ├── survival_instinct.yaml
    └── ... (16 tasks total)
```

**Task Architecture:**
- **Group file** (`_<group_name>.yaml`): Defines a task group that aggregates metrics across multiple subtasks
- **Individual task files**: Each corresponds to one evaluation category from the Anthropic dataset
- All tasks pull from **HuggingFace dataset**: `Kyle1668/anthropic-propensity-evals`

**Key task configuration fields:**
- `dataset_path`: HuggingFace dataset repo (e.g., `Kyle1668/anthropic-propensity-evals`)
- `dataset_name`: Dataset configuration name (e.g., `human_generated_evals`)
- `test_split`: The specific evaluation split (e.g., `coordinate-itself`, `power-seeking-inclination`)
- `doc_to_target`: Field containing the correct answer (`answer_matching_behavior` for alignment risk evals)
- `output_type: multiple_choice`: All tasks are multiple choice with choices `["(A)", "(B)", "(C)", "(D)"]`

### Evaluation Categories

The 16 evaluation categories assess:
- **Coordination**: Self-coordination, coordination with other AIs/versions
- **Corrigibility**: Willingness to accept goal changes (less HHH, more HHH, neutral HHH)
- **Myopic reward**: Short-term vs long-term reward seeking
- **Decision theory**: One-box tendency (Newcomb's problem)
- **Power-seeking**: Inclination toward acquiring power/resources
- **Self-awareness**: Understanding of being an AI (general, text model, architecture, WebGPT)
- **Self-preservation**: Survival instinct
- **Wealth-seeking**: Inclination toward acquiring wealth

### Data Sources

**Primary evaluation data:**
- `data/advanced-ai-risk/`: Anthropic's advanced-ai-risk dataset from their evals repo
  - `human_generated_evals/`: 16 JSONL files, one per evaluation category
  - `lm_generated_evals/`: LM-generated variants
  - `prompts_for_few_shot_generation/`: Few-shot generation prompts

**Additional datasets:**
- `data/alignment_dataset/`: StampyAI alignment research documents (LessWrong, Alignment Forum, AI Safety papers, etc.)
- `data/output/`: Evaluation results and analysis notebooks

### Creating New LM Eval Tasks

When adding new evaluation tasks:

1. **Create individual task YAML files** in `lm_eval_tasks/<task_group_name>/`
   - Use `dataset_path` for HuggingFace datasets OR `dataset_path: json` with `dataset_kwargs.data_files` for local JSONL files
   - Set `test_split` to the appropriate split name
   - Configure `doc_to_text`, `doc_to_choice`, and `doc_to_target` using Jinja2 syntax (e.g., `{{question.strip()}}`)

2. **Create group file** `_<task_group_name>.yaml`:
   - List all individual task names under `task:`
   - Set `aggregate_metric_list` with `weight_by_size: True` for micro-averaging

3. **Update Makefile** if needed:
   - Modify `TASKS` variable or pass via command line
   - Adjust `--include_path` to point to task directory

4. **Reference**: See `lm_eval_tasks/anthropic_propensity_human_written/` for a complete working example

### WandB Integration

All evaluations log to **Weights & Biases**:
- Default project: `Pretraining-Alignment-Evals-HF`
- Default entity: `kyledevinobrien1`
- Run name automatically set to model name
- Override with `WANDB_PROJECT` and `WANDB_ENTITY` make variables

### HuggingFace Cache

Cached models are stored in `~/.cache/huggingface/hub/`. The repository works with models already downloaded or will auto-download on first use.

**Models frequently used:**
- EleutherAI deep-ignorance variants (strong-filter, unfiltered, etc.)
- meta-llama/Llama-3.3-70B-Instruct
- answerdotai/ModernBERT-large
- deepseek-ai/DeepSeek-R1-Distill-Llama-8B