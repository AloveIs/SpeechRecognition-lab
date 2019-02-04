#!/bin/bash
# recognize_digit_loop.cmd
# Recognizes the speech files in $3/test_data/files.scp according to:
# - the grammar defined in $1
# - the dictionary defined in digits.dic
# - the HMM models defined in $2/hmm7/macros $1/hmm7/hmmdefs and monophones1.lst
# It saves the results in recognized.mlf and evaluation in evaluation.txt
# It also displays recognition accuracy and confusion matrix in the terminal
#
# Requires HTK
#
# (C) 2016-2018 Giampiero Salvi <giampi@kth.se>

grammar=$1
training_speaker=$2
testing_speaker=$3
resultdir=results/model_${training_speaker}_test_${testing_speaker}_grammar_$(basename ${grammar} .lat)
mkdir -p $resultdir

HVite -T 1 -C config/features.cfg -H $training_speaker/hmm7/macros -H $training_speaker/hmm7/hmmdefs -S $testing_speaker/test_data/files.scp -l '*' -i $resultdir/recognized.mlf -w $grammar -p 0.0 -s 5.0 digits.dic monophones1.lst
HResults -p -I $testing_speaker/testprompts.mlf words.lst $resultdir/recognized.mlf | tee $resultdir/evaluation.txt
