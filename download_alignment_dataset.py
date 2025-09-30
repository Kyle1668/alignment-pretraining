import os
import requests
from huggingface_hub import hf_hub_download
from pathlib import Path

# Create directory for dataset
dataset_dir = Path("alignment_dataset")
dataset_dir.mkdir(exist_ok=True)

# List of data files in the repository
data_files = [
    "agentmodels.jsonl",
    "agisf.jsonl",
    "aisafety.info.jsonl",
    "alignmentforum.jsonl",
    "arbital.jsonl",
    "arxiv.jsonl",
    "blogs.jsonl",
    "distill.jsonl",
    "eaforum.jsonl",
    "lesswrong.jsonl",
    "special_docs.jsonl",
    "youtube.jsonl"
]

print("Downloading StampyAI/alignment-research-dataset from Hugging Face...")
print(f"Saving to: {dataset_dir}/\n")

# Download each file
for file_name in data_files:
    print(f"Downloading {file_name}...")
    file_path = hf_hub_download(
        repo_id="StampyAI/alignment-research-dataset",
        filename=file_name,
        repo_type="dataset",
        local_dir=dataset_dir
    )
    print(f"  ✓ Saved to {file_path}")

# Also download README
print("\nDownloading README.md...")
readme_path = hf_hub_download(
    repo_id="StampyAI/alignment-research-dataset",
    filename="README.md",
    repo_type="dataset",
    local_dir=dataset_dir
)
print(f"  ✓ Saved to {readme_path}")

print("\n✅ Dataset downloaded successfully!")
print(f"\nAll files saved to: {dataset_dir.absolute()}")

# Show summary of downloaded files
print("\nDownloaded files:")
for file in sorted(dataset_dir.glob("*.jsonl")):
    size_mb = file.stat().st_size / (1024 * 1024)
    print(f"  • {file.name}: {size_mb:.2f} MB")