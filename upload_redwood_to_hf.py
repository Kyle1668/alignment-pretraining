#!/usr/bin/env python3
"""Upload Redwood dataset to HuggingFace Hub."""

from datasets import Dataset, DatasetDict
from huggingface_hub import HfApi
import json
from pathlib import Path

def load_jsonl(file_path):
    """Load JSONL file into a list of dictionaries."""
    data = []
    with open(file_path, 'r') as f:
        for line in f:
            data.append(json.loads(line))
    return data

def create_hf_dataset(formatted_dir: str):
    """
    Create HuggingFace DatasetDict from formatted JSONL files.

    Args:
        formatted_dir: Directory containing JSONL files

    Returns:
        DatasetDict with each JSONL file as a separate split
    """
    formatted_path = Path(formatted_dir)

    # Create a dataset for each JSONL file
    datasets = {}
    for jsonl_file in sorted(formatted_path.glob("*.jsonl")):
        # Use filename without extension as split name
        split_name = jsonl_file.stem.replace('-', '_')

        print(f"Loading {jsonl_file.name} as split '{split_name}'...")
        data = load_jsonl(jsonl_file)

        # Create dataset from list of dictionaries
        datasets[split_name] = Dataset.from_list(data)
        print(f"  Loaded {len(data)} examples")

    return DatasetDict(datasets)

def main():
    formatted_dir = "/Users/kyle/repos/research/alignment_pretraining/data/redwood_dataset_formatted"
    repo_id = "Kyle1668/redwood-propensity-evals"

    print(f"Creating HuggingFace dataset from {formatted_dir}...")
    dataset_dict = create_hf_dataset(formatted_dir)

    print(f"\nDataset structure:")
    print(dataset_dict)

    print(f"\nUploading to HuggingFace Hub: {repo_id}")
    print("This will create a PRIVATE repository...")

    # Push to hub (private by default)
    dataset_dict.push_to_hub(
        repo_id,
        private=True,
        token=True  # Use token from HF_TOKEN env var or ~/.huggingface/token
    )

    print(f"\n✓ Successfully uploaded to https://huggingface.co/datasets/{repo_id}")

if __name__ == "__main__":
    main()