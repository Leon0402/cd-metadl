#!/bin/bash
DATASETS_DIR=""
MODEL_DIR=""
CONFIG_PATH=""
OUTPUT_DIR=""
LOG_FILE=""
RUN_CROSS_DOMAIN=false
RUN_WITHIN_DOMAIN=false
DATSET_NAMES=""

# Parse named arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        --datasets_dir) DATASETS_DIR="$2"; shift 2;;
        --model_dir) MODEL_DIR="$2"; shift 2;;
        --config_path) CONFIG_PATH="$2"; shift 2;;
        --output_dir) OUTPUT_DIR="$2"; shift 2;;
        --log_file) LOG_FILE="$2"; shift 2;;
        --run_cross_domain) RUN_CROSS_DOMAIN=true; shift;;
        --run_within_domain) RUN_WITHIN_DOMAIN=true; shift;;
        --dataset_names) DATASET_NAMES="$2"; shift 2;;
        *) echo "Unknown parameter passed: $1"; exit 1;;
    esac
done

# Check if arguments were provided
if [ -z "$DATASETS_DIR" ]; then
    echo "No datasets directory provided. Use --datasets_dir to specify the directory."
    exit 1
fi

if [ -z "$MODEL_DIR" ]; then
    echo "No model directory provided. Use --model_dir to specify the directory."
    exit 1
fi

if [ -z "$CONFIG_PATH" ]; then
    echo "No config path provided. Use --config_path to specify the directory."
    exit 1
fi

if [ -z "$OUTPUT_DIR" ]; then
    echo "No output dir provided. Use --output_dir to specify the directory."
    exit 1
fi

if [ -z "$LOG_FILE" ]; then
    echo "No log filename provided. Use --log_file to specify the name."
    exit 1
fi

if [ -z "$DATSET_NAMES" ]; then
    echo "No datasets defined. Use --dataset_names to specify the dataset names for within domain."
    exit 1
fi


touch $LOG_FILE


# echo "Running model $MODEL_DIR in domain-independent mode" 
# echo "Running model $MODEL_DIR in domain-independent mode" >> $LOG_FILE

# start=$SECONDS
# python -m cdmetadl.train \
#     --config_path="$CONFIG_PATH" \
#     --model_dir="$MODEL_DIR" \
#     --output_dir="./output/full/training" \
#     --domain_type="domain-independent" \
#     --data_dir="$DATASETS_DIR" \
#     --verbose
# duration=$(( SECONDS - start ))
# echo Task took $duration seconds >> $LOG_FILE

# Cross-domain training
if [ "$RUN_CROSS_DOMAIN" = true ]; then
    echo "Running model $MODEL_DIR in cross-domain mode" 
    echo "Running model $MODEL_DIR in cross-domain mode" >> $LOG_FILE

    start=$SECONDS
    python -m cdmetadl.train \
        --config_path="$CONFIG_PATH" \
        --model_dir="$MODEL_DIR" \
        --output_dir="$OUTPUT_DIR" \
        --domain_type="cross-domain" \
        --data_dir="$DATASETS_DIR" \
        --verbose
    duration=$(( SECONDS - start ))
    echo Task took $duration seconds >> $LOG_FILE
fi

# Within-domain training
if [ "$RUN_WITHIN_DOMAIN" = true ]; then
    echo "Running model $MODEL_DIR in within-domain mode"
    echo "Running model $MODEL_DIR in within-domain mode" >> $LOG_FILE

    for DATASET_NAME in "DOG" "INS_2" "PLT_NET" "MED_LF" "PNU" "RSICB" "APL" "TEX_DTD" "ACT_40" "MD_5_BIS"
    do
        echo "Running model with dataset: $DATASET_NAME" 
        echo "Running model with dataset: $DATASET_NAME" >> $LOG_FILE
        start=$SECONDS

        python -m cdmetadl.train \
            --config_path="$CONFIG_PATH" \
            --model_dir="$MODEL_DIR" \
            --output_dir="$OUTPUT_DIR" \
            --datasets="$DATASET_NAME" \
            --domain_type="within-domain" \
            --data_dir="$DATASETS_DIR" \
            --verbose 
        duration=$(( SECONDS - start ))
        echo Task took $duration seconds >> $LOG_FILE
    done
fi