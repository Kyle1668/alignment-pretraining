#!/usr/bin/env python3
"""Transform Redwood dataset to HuggingFace-compatible JSONL format."""

import json
import os
from pathlib import Path

def transform_redwood_to_jsonl(input_dir: str, output_dir: str):
    """
    Transform Redwood JSON files to JSONL format compatible with Anthropic structure.

    Args:
        input_dir: Directory containing Redwood JSON files
        output_dir: Directory to save JSONL files
    """
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    # Process each JSON file
    for json_file in sorted(input_path.glob("*.json")):
        print(f"Processing {json_file.name}...")

        # Load JSON array
        with open(json_file, 'r') as f:
            data = json.load(f)

        # Create output filename (convert .json to .jsonl)
        output_file = output_path / json_file.name.replace('.json', '.jsonl')

        # Transform and write as JSONL
        with open(output_file, 'w') as f:
            for item in data:
                # Get answer_matching_behavior
                answer_matching = item["answer_matching_behavior"]

                # Infer answer_not_matching_behavior if not present
                if "answer_not_matching_behavior" in item:
                    answer_not_matching = item["answer_not_matching_behavior"]
                else:
                    # For binary choices (1/2), infer the opposite
                    if answer_matching == "1":
                        answer_not_matching = "2"
                    elif answer_matching == "2":
                        answer_not_matching = "1"
                    else:
                        # Fallback - shouldn't happen but handle gracefully
                        answer_not_matching = answer_matching

                # Transform to match Anthropic format
                transformed = {
                    "question": item["q"],
                    "answer_matching_behavior": answer_matching,
                    "answer_not_matching_behavior": answer_not_matching
                }
                # Write as single line JSON
                f.write(json.dumps(transformed) + '\n')

        print(f"  Wrote {len(data)} records to {output_file.name}")

if __name__ == "__main__":
    input_dir = "/Users/kyle/repos/research/alignment_pretraining/data/redwood_dataset"
    output_dir = "/Users/kyle/repos/research/alignment_pretraining/data/redwood_dataset_formatted"

    transform_redwood_to_jsonl(input_dir, output_dir)
    print("\nTransformation complete!")