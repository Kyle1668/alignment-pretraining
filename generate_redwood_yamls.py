#!/usr/bin/env python3
"""Generate LM Eval task YAML files for Redwood dataset."""

import json
from pathlib import Path

# Define the splits and their answer formats
SPLITS = {
    "alek_preservation": {"format": "numeric", "choices": ["1", "2"]},
    "anshul_power": {"format": "numeric", "choices": ["1", "2"]},
    "believes_it_knows_better_than_humans_about_how_to_help_humans": {"format": "yes_no", "choices": [" Yes", " No"]},
    "evhub_myopia": {"format": "numeric", "choices": ["1", "2"]},
    "evhub_power": {"format": "numeric", "choices": ["1", "2"]},
    "evhub_survival": {"format": "numeric", "choices": ["1", "2"]},
    "pure_evil": {"format": "numeric", "choices": ["1", "2"]},
}

def generate_task_yaml(split_name: str, choices: list) -> str:
    """Generate YAML content for a single task."""
    task_name = f"redwood_propensity_evals_{split_name}"

    # Format choices for YAML (with proper quoting)
    choices_str = "[" + ", ".join([f'"{c}"' for c in choices]) + "]"

    yaml_content = f"""task: {task_name}
dataset_path: Kyle1668/redwood-propensity-evals
test_split: {split_name}
output_type: multiple_choice
num_fewshot: 0
doc_to_text: "{{{{question.strip()}}}}\\nAnswer:"
doc_to_choice: {choices_str}
doc_to_target: answer_matching_behavior
metric_list:
  - metric: acc
    aggregation: mean
    higher_is_better: true
metadata:
  version: 1
"""
    return yaml_content

def generate_group_yaml(split_names: list) -> str:
    """Generate group YAML that aggregates all tasks."""
    task_list = "\n".join([f"  - redwood_propensity_evals_{name}" for name in split_names])

    yaml_content = f"""group: redwood_propensity_evals
task:
{task_list}
aggregate_metric_list:
  - metric: acc
    weight_by_size: True
metadata:
  version: 1
"""
    return yaml_content

def main():
    output_dir = Path("/Users/kyle/repos/research/alignment_pretraining/lm_eval_tasks/redwood_propensity_evals")
    output_dir.mkdir(parents=True, exist_ok=True)

    print("Generating LM Eval task YAML files...")

    # Generate individual task files
    for split_name, config in SPLITS.items():
        yaml_content = generate_task_yaml(split_name, config["choices"])
        output_file = output_dir / f"{split_name}.yaml"

        with open(output_file, 'w') as f:
            f.write(yaml_content)

        print(f"  Created {output_file.name}")

    # Generate group file
    group_yaml = generate_group_yaml(list(SPLITS.keys()))
    group_file = output_dir / "_redwood_propensity_evals.yaml"

    with open(group_file, 'w') as f:
        f.write(group_yaml)

    print(f"  Created {group_file.name}")
    print(f"\n✓ Generated {len(SPLITS) + 1} YAML files in {output_dir}")

if __name__ == "__main__":
    main()