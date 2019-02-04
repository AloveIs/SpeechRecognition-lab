#!/bin/sh
#
# train.cmd
# Runs a number of steps for training monophone HMMs with Gaussian emission probabilities
#
# (C) 2016-2018 Giampiero Salvi <giampi@kth.se>

printf "EX\nIS sil sil\nDE sp\n" > mkphones0.led
printf "EX\nIS sil sil\n" > mkphones1.led
printf "AT 2 4 0.2 {sil.transP}\nAT 4 2 0.2 {sil.transP}\nAT 1 3 0.3 {sp.transP}\nTI silst {sil.state[3],sp.state[2]}\n" > sil.hed

echo "##########################################################"
echo "# Converting prompts into Master Lable File transcriptions"
echo "##########################################################"
echo "tools/prompts2mlf.pl $1/trainprompts.mlf $1/trainprompts"
tools/prompts2mlf.pl $1/trainprompts.mlf $1/trainprompts
echo "tools/prompts2mlf.pl $1/testprompts.mlf $1/testprompts"
tools/prompts2mlf.pl $1/testprompts.mlf $1/testprompts

echo "##########################################################"
echo "# Converting word level to phone level transcriptions"
echo "##########################################################"
HLEd -A -l '*' -d digits.dic -i $1/phones0.mlf mkphones0.led $1/trainprompts.mlf
#tools/build_speech_mfcc_file_list $1
#HCopy -T 1 -C config/features.cfg -S $1/codetr.scp

echo "##########################################################"
echo "# Generating flat-start models"
echo "##########################################################"
HCompV -A -C config/features.cfg -f 0.01 -m -S $1/train_data/files.scp -M $1/hmm0 config/proto.mmf
echo "tools/proto2phones $1"
tools/proto2phones $1
echo "tools/split_model_macro $1"
tools/split_model_macro $1
echo "grep -v sp monophones1.lst > monophones0.lst"
grep -v sp monophones1.lst > monophones0.lst

echo "##########################################################"
echo "# Re-estimating model parameters"
echo "##########################################################"
HERest -A -C config/features.cfg -m 1 -I $1/phones0.mlf -t 250.0 150.0 1000.0 -S $1/train_data/files.scp -H $1/hmm0/macros -H $1/hmm0/hmmdefs -M $1/hmm1 monophones0.lst
HERest -A -C config/features.cfg -m 1 -I $1/phones0.mlf -t 250.0 150.0 1000.0 -S $1/train_data/files.scp -H $1/hmm1/macros -H $1/hmm1/hmmdefs -M $1/hmm2 monophones0.lst
HERest -A -C config/features.cfg -m 1 -I $1/phones0.mlf -t 250.0 150.0 1000.0 -S $1/train_data/files.scp -H $1/hmm2/macros -H $1/hmm2/hmmdefs -M $1/hmm3 monophones0.lst

echo "##########################################################"
echo "# Adding model for short pauses"
echo "##########################################################"
echo "cp $1/hmm3/hmmdefs $1/hmm4"
cp $1/hmm3/hmmdefs $1/hmm4
echo "cp $1/hmm3/macros $1/hmm4"
cp $1/hmm3/macros $1/hmm4
echo "tools/makesp.pl $1/hmm3/hmmdefs >> $1/hmm4/hmmdefs"
tools/makesp.pl $1/hmm3/hmmdefs >> $1/hmm4/hmmdefs
HHEd -A -H $1/hmm4/macros -H $1/hmm4/hmmdefs -M $1/hmm5 sil.hed monophones1.lst
HLEd -A -l '*' -d digits.dic -i $1/phones1.mlf mkphones1.led $1/trainprompts.mlf

echo "##########################################################"
echo "# Re-estimating model parameters"
echo "##########################################################"
HERest -A -C config/features.cfg -m 1 -I $1/phones1.mlf -t 250.0 150.0 1000.0 -S $1/train_data/files.scp -H $1/hmm5/macros -H $1/hmm5/hmmdefs -M $1/hmm6 monophones1.lst
HERest -A -C config/features.cfg -m 1 -I $1/phones1.mlf -t 250.0 150.0 1000.0 -S $1/train_data/files.scp -H $1/hmm6/macros -H $1/hmm6/hmmdefs -M $1/hmm7 monophones1.lst

##########################################################
# Running and evaluating recognizer on training data
##########################################################
#HVite -C config/features.cfg -H $1/hmm7/macros -H $1/hmm7/hmmdefs -S $1/test_data/files.scp -l '*' -i $1/hmm7/recout.mlf -w sw4dig.lat -p 0.0 -s 5.0 digits.dic monophones1.lst
#HResults -p -I $1/testprompts.mlf words.lst $1/hmm7/recout.mlf
