#!/bin/bash
batchs='16 32 64'
export CUDA_VISIBLE_DEVICES=0
md="ssd-vgg16"
if [ -d results_infer ]; then
    mv results_infer results_infer_$(date +%Y%m%d%H%M%S)
fi
mkdir results_infer
# in sampleSSD.cpp, we iterate 100 times on the same batch
num_batches=100 

# fp16
for batch in $batchs
    do
        echo "----------------------------------------------------------------"
        echo "Running ssd+vgg16+Tensor RT(fp16) with batch size of $batch"
        echo "----------------------------------------------------------------"
        start=`date +%s%N`
        command=" ./bin/sample_ssd   \
                    --batchSize=$batch \
                    --fp16 \
                    |& tee ./results_infer/result_${md}_${batch}_fp16.txt"
        echo $command
        eval $command
        end=`date +%s%N`
        total_time=$(((end-start)/1000000))
        total_images=$(($batch*$num_batches))
        system_performance=$((1000*$total_images/$total_time))
        echo "Total images is: $total_images" >> ./results_infer/result_${md}_${batch}_fp16.txt
        echo "Total running time in miliseconds is: $total_time" >> ./results_infer/result_${md}_${batch}_fp16.txt
        echo "System performance in images/second is: $system_performance" >> ./results_infer/result_${md}_${batch}_fp16.txt
done
python process_results.py --infer_trt_precision=fp16
