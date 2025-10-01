python tools/datasets/preprocess_data.py \
            --input /projects/a5k/public/data/alignment-classifier-documents-unlabeled/data.jsonl \
            --output-prefix /projects/a5k/public/data/alignment-classifier-documents-unlabeled/alignment-classifier-documents-unlabeled \
            --vocab /projects/a5k/public/data/neox_tokenizer/tokenizer.json \
            --dataset-impl mmap \
            --tokenizer-type HFTokenizer \
            --append-eod \
            --num-docs 57912 \
            --workers 25