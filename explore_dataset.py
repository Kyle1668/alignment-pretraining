import json
from pathlib import Path
import random

dataset_dir = Path("alignment_dataset")

print("StampyAI Alignment Research Dataset Overview")
print("=" * 50)

# Read and display info about each file
for jsonl_file in sorted(dataset_dir.glob("*.jsonl")):
    print(f"\n📁 {jsonl_file.name}")
    print("-" * 40)

    # Count entries and show sample
    with open(jsonl_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        num_entries = len(lines)
        print(f"  Total entries: {num_entries:,}")

        if num_entries > 0:
            # Show first entry structure
            first_entry = json.loads(lines[0])
            print(f"  Fields: {list(first_entry.keys())}")

            # Show a sample entry
            print(f"\n  Sample entry (first):")
            for key, value in first_entry.items():
                if isinstance(value, str):
                    preview = value[:100] + "..." if len(value) > 100 else value
                    preview = preview.replace('\n', ' ')
                else:
                    preview = str(value)[:100]
                print(f"    • {key}: {preview}")

print("\n" + "=" * 50)
print("Dataset successfully downloaded and explored!")
print(f"Total files: {len(list(dataset_dir.glob('*.jsonl')))}")
print(f"Location: {dataset_dir.absolute()}")