#!/usr/bin/env bash

######################################################
#### Convert .arp simulation data to NEXUS format ####
######################################################

## Usage: [path_to_script]/arp2nexus.sh filename.ext

## Define variables
TAB=$'\t'
infilename=$(basename $1)
fileroot="${infilename%.*}"
ntaxa=$(grep -i '_' $1 | wc -l)
nloci=$(grep -i 'polymorphic sites' 4pop_merge_test_1_1.arp | sed 's/^.*: //')

## Build NEXUS file
grep -i '_' $1 | sed -e 's/\t1//g' | sed -e 's/^/>/g' | sed -e 's/\t/\n/g' >> $fileroot'.fasta'


