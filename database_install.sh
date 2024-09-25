#!/bin/bash

set -eu

read -p "This scirpt will download around 40Gb of data, make sure you are using the flag -v /path/to/local/directory/:/root/db/ with docker run to have the files saved locally for use next time. Continue (y/n)?" CHOICE
case "$CHOICE" in 
  y|Y ) echo "Downloading...";;
  n|N ) exit;;
  * ) echo "invalid"; exit;;
esac

# Get GATK resource bundle files

mkdir -p /root/db/refs/ && cd /root/db/refs/

wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dict
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.alt
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.amb
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.ann
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.bwt
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.pac
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.64.sa
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta.fai
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.known_indels.vcf.gz
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.known_indels.vcf.gz.tbi
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz.tbi
bgzip Homo_sapiens_assembly38.dbsnp138.vcf
tabix Homo_sapiens_assembly38.dbsnp138.vcf.gz

# Download vep cache and custom files

mkdir -p /root/db/vep_files/ && cd /root/db/vep_files/

perl /root/ensembl-vep/INSTALL.pl \
    -a c \
    -s Homo_sapiens_refseq \
    -y GRCh38 \
    -c /root/db/vep_files/

apt install pipx
pipx install gdown
gdown --id 1L_YQ7lXKMLd5n_jHsSQAEobZdQ-ZvU6Y
tar -xvf custom_files.tar.gz
rm custom_files.tar.gz

cd /root/