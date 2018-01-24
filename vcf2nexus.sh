#!/usr/bin/env bash

###############################################
## Script for converting VCF to NEXUS format ##
###############################################
## Usage: [path_to_script]/vcf2nexus filename.ext MAFfilter
## MAFfilter: minor allele frequency filter 

## Convert variant calls to binary genotype format using vcftools (Minor Allele Frequency filter --maf)
vcftools --vcf $1 --012 --maf $2

## Define variables
TAB=$'\t'
infilename=$(basename $1)
fileroot="${infilename%.*}"
ntaxa=$(cat out.012.indv | wc -l)
nloci=$(cat out.012.pos | wc -l)

## Build NEXUS file
sed 's/-1/?/g' out.012 > genotypes.out
cut -f 2- genotypes.out > genotypes2.out
cat genotypes2.out | sed "s/${TAB}//g" > genotypes3.out
paste out.012.indv genotypes3.out > ind_gen.out
echo 'Matrix' | cat - ind_gen.out > ind_gen2.out
echo 'Format datatype=standard symbols="012" missing=? gap=-;' | cat - ind_gen2.out > ind_gen3.out
echo 'Dimensions ntax='${ntaxa// /}' nchar='${nloci// /}';' | cat - ind_gen3.out > ind_gen4.out
echo 'Begin data;' | cat - ind_gen4.out > ind_gen5.out
echo '#NEXUS' | cat - ind_gen5.out > $fileroot"_maf"$2".nex"
echo ';' >> $fileroot"_maf"$2".nex"
echo 'End;' >> $fileroot"_maf"$2".nex"

## Cleanup
rm -rf out.log out.012 out.012.indv out.012.pos genotypes.out genotypes2.out genotypes3.out ind_gen.out ind_gen2.out ind_gen3.out ind_gen4.out ind_gen5.out
