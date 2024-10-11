#!/bin/bash

set -eux

VCF=$1
BASENAME=$(basename ${VCF})
SAMPLE="${BASENAME%%.*}"

mkdir -p vcfs
mkdir -p tsvs

cat <(bcftools view -h $VCF | sed '20i##INFO=<ID=AD,Number=.,Type=String,Description="Allelic depths (counting only informative reads out of the total reads) for the ref and alt alleles in the order listed">' ) \
    <(paste \
        <(paste -d ";" \
            <(bcftools view -H ${VCF} | cut -f 1-8) \
            <(bcftools view -H ${VCF} | cut -f 10 | cut -d : -f 2 | sed 's/^/AD=/g' | sed 's#,#\/#g')) \
        <(bcftools view -H ${VCF} | cut -f 9,10)) \
| bgzip > /root/varwolf/vcfs/${SAMPLE}.ADinINFO.vcf.gz && tabix /root/varwolf/vcfs/${SAMPLE}.ADinINFO.vcf.gz

vep \
	--fork 12 \
	--cache \
    --dir_cache /root/varwolf/db/vep_files/ \
	--offline \
	--refseq \
	--use_given_ref \
	--fasta /root/varwolf/db/refs/Homo_sapiens_assembly38.fasta \
	--assembly GRCh38 \
	-i ${VCF} \
	-o tsvs/${SAMPLE}_annotated.tsv \
	--tab \
	--force_overwrite \
	--pick_allele_gene \
	--sift b \
	--polyphen b \
	--hgvs \
	--symbol \
	--numbers \
	--biotype \
	--af_gnomadg \
	--pubmed \
	--check_existing \
	--distance 500 \
	--custom file=/root/varwolf/vcfs/${SAMPLE}.ADinINFO.vcf.gz,short_name=VCF,format=vcf,type=exact,fields=AD \
	--custom file=/root/varwolf/db/vep_files/G2P.bed.gz,short_name=G2P,format=bed,type=overlap \
	--custom file=/root/varwolf/db/vep_files/clingen.bed.gz,short_name=ClinGen,format=bed,type=overlap \
	--custom file=/root/varwolf/db/vep_files/OMIM.bed.gz,short_name=OMIM,format=bed,type=overlap \
	--custom file=/root/varwolf/db/vep_files/Orphanet.bed.gz,short_name=Orphanet,format=bed,type=overlap \
	--custom file=/root/varwolf/db/vep_files/clinvar_20240528.vcf.gz,short_name=ClinVar,format=vcf,type=exact,fields=CLNDN%CLNSIG%CLNREVSTAT \
	--plugin AlphaMissense,file=/root/varwolf/db/vep_files/AlphaMissense_hg38_fixed.tsv.gz \
	--plugin SpliceAI,snv=/root/varwolf/db/vep_files/spliceai_filtered_edited.snv.hg38.vcf.gz,indel=/root/varwolf/db/vep_files/spliceai_filtered_edited.snv.hg38.vcf.gz \
	--fields "Uploaded_variation,Existing_variation,VCF_FILTER,VCF_AD,HGVSc,HGVSp,SYMBOL,OMIM,Orphanet,ClinGen,G2P,EXON,INTRON,Consequence,IMPACT,BIOTYPE,SIFT,PolyPhen,am_class,SpliceAI_pred,gnomADg_AF,gnomADg_AFR_AF,gnomADg_AMI_AF,gnomADg_AMR_AF,gnomADg_ASJ_AF,gnomADg_EAS_AF,gnomADg_FIN_AF,gnomADg_MID_AF,gnomADg_NFE_AF,gnomADg_OTH_AF,gnomADg_SAS_AF,ClinVar_CLNDN,ClinVar_CLNSIG,ClinVar_CLNREVSTAT,PUBMED"

rm /root/varwolf/vcfs/${SAMPLE}.ADinINFO.vcf.gz*