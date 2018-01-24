#!/usr/bin/env bash

######################################################
#### Convert .arp simulation data to NEXUS format ####
######################################################

## Usage: [path_to_script]/arp2nexus.sh filename.ext

## .arp format: 0=ancestral allele, 1=alternate alle
## .nex format: 0=homozygous common alle, 1=heterozygous, 2=homozygous minor allele

## Define variables
TAB=$'\t'
infilename=$(basename $1)
fileroot="${infilename%.*}"
ntaxa=$(grep -i '_' $1 | wc -l)
nloci=$(grep -m 1 -i '_' $1 | sed -e 's/\t1//g' | sed -e 's/.*\t //g' | wc -c)

## Get sample names
grep -i '_' $1 | sed -e 's/\t1//g' | sed -e 's/ *\t.*//g' > samplenames.nextmp
## Write first line of genotypes to file
grep -i '_' $1 | sed -e 's/\t1//g' | sed -e 's/.*\t //g' > genotypes_1.nextmp
## Write second line of genotypes to file
awk '/_/{getline; print}' $1 | sed -e 's/.* //g'  > genotypes_2.nextmp

## Compare genotype_1 to genotype_2 for each line/individual
for indv in $(seq 1 $ntaxa); do
	# Create temp file for all nexus genotypes
	touch nexus_genotypes_all.nextmp
	# Get genotypes of individual
	gtype1=$(sed "${indv}q;d" genotypes_1.nextmp)
	gtype2=$(sed "${indv}q;d" genotypes_2.nextmp)
	# Compare alleles of each SNP
	for locus in $(seq 0 `expr $nloci - 1`); do
		if [ "${gtype1:$locus:1}" == "0" ] && [ "${gtype2:$locus:1}" == "0" ]; then
			SNPcode=0
		elif [ "${gtype1:$locus:1}" == "1" ] && [ "${gtype2:$locus:1}" == "0" ]; then
			SNPcode=1
		elif [ "${gtype1:$locus:1}" == "0" ] && [ "${gtype2:$locus:1}" == "1" ]; then
			SNPcode=1
		elif [ "${gtype1:$locus:1}" == "1" ] && [ "${gtype2:$locus:1}" == "1" ]; then
			SNPcode=2
		fi
		# Write SNP to file
		echo -n $SNPcode >> "nexus_genotype_indv_"$indv".nextmp"
	done
	# Combine genotypes into single file
	(cat "nexus_genotype_indv_"$indv".nextmp"; echo) >> nexus_genotypes_all.nextmp
done

## Build NEXUS file
echo '#NEXUS' > $fileroot".nex"
echo 'Begin data;' >> $fileroot".nex"
echo 'Dimensions ntax='$ntaxa' nchar='$nloci';' >> $fileroot".nex"
echo 'Format datatype=standard symbols="012" missing=? gap=-;' >> $fileroot".nex"
echo 'Matrix' >> $fileroot".nex"
paste samplenames.nextmp nexus_genotypes_all.nextmp >> $fileroot".nex"
echo ';' >> $fileroot".nex"
echo 'End;' >> $fileroot".nex"

## Cleanup
rm *.nextmp
