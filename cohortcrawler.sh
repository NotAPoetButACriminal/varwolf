#!/bin/bash
#
#SBATCH -J cohortcrawler
#SBATCH --output /lustre/imgge/PharmGenHub/logs/%x_%A.out
#SBATCH --nodes 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 128G
#SBATCH --time 3-00:00:00

module load gatk

set -eux

SAMPLES=$(cat $1)
COHORT=$2
WDIR="/lustre/imgge/PharmGenHub"
REF=$WDIR/refs/hg38.fasta
DBSNP="/lustre/imgge/db/hg38.dbsnp155.vcf.gz"

if [ -d ${WDIR}/gdbs/${COHORT} ]
then
  GDBflag="--genomicsdb-update-workspace-path" 
else
  GDBflag="--genomicsdb-workspace-path"
  mkdir ${WDIR}/gdbs/${COHORT}
fi

INPUTGVCFS=$(
  for i in $SAMPLES
  do
    echo -n "-V ${WDIR}/gvcfs/${i}.g.vcf.gz "
  done
)

for CHR in {1..22} X Y M
do
  gatk GenomicsDBImport \
    $GDBflag ${WDIR}/gdbs/${COHORT}/${COHORT}_chr${CHR}_gdb \
    -R $REF \
    $INPUTGVCFS \
    -L chr${CHR} &
done

wait

for CHR in {1..22} X Y M
do
 VCFSHARDS+=$(echo -n "-I ${WDIR}/vcfs/${COHORT}_chr${CHR}.vcf.gz ")
  gatk GenotypeGVCFs \
    -R $REF \
    -V gendb://${WDIR}/gdbs/${COHORT}/${COHORT}_chr${CHR}_gdb \
    -O ${WDIR}/vcfs/${COHORT}_chr${CHR}.vcf.gz \
	  -L chr${CHR} &
done

wait

gatk MergeVcfs \
  $VCFSHARDS \
  -O ${WDIR}/vcfs/${COHORT}_raw.vcf.gz

gatk VariantRecalibrator \
  -R $REF \
  -V ${WDIR}/vcfs/${COHORT}_raw.vcf.gz \
  --resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${WDIR}/refs/resources_broad_hg38_v0_hapmap_3.3.hg38.vcf.gz \
  --resource:omni,known=false,training=true,truth=false,prior=12.0 ${WDIR}/refs/resources_broad_hg38_v0_1000G_omni2.5.hg38.vcf.gz \
  --resource:1000G,known=false,training=true,truth=false,prior=10.0 ${WDIR}/refs/resources_broad_hg38_v0_1000G_phase1.snps.high_confidence.hg38.vcf.gz \
  --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${DBSNP} \
  -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
  -mode SNP \
  -O ${WDIR}/vcfs/${COHORT}_snp.recal \
  --tranches-file ${WDIR}/vcfs/${COHORT}_snp.tranches

gatk VariantRecalibrator \
  -R $REF \
  -V ${WDIR}/vcfs/${COHORT}_raw.vcf.gz \
  --resource:mills,known=false,training=true,truth=true,prior=12.0 ${WDIR}/refs/resources_broad_hg38_v0_Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
  --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${DBSNP} \
  -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
  -mode INDEL \
  -O ${WDIR}/vcfs/${COHORT}_indel.recal \
  --tranches-file ${WDIR}/vcfs/${COHORT}_indel.tranches

gatk ApplyVQSR \
  -R $REF \
  -V ${WDIR}/vcfs/${COHORT}_raw.vcf.gz \
  -O ${WDIR}/vcfs/${COHORT}_snp.vcf.gz \
  --truth-sensitivity-filter-level 99.9 \
  --tranches-file ${WDIR}/vcfs/${COHORT}_snp.tranches \
  --recal-file ${WDIR}/vcfs/${COHORT}_snp.recal \
  -mode SNP

gatk ApplyVQSR \
  -R $REF \
  -V ${WDIR}/vcfs/${COHORT}_snp.vcf.gz \
  -O ${WDIR}/vcfs/${COHORT}.vcf.gz \
  --truth-sensitivity-filter-level 99.9 \
  --tranches-file ${WDIR}/vcfs/${COHORT}_indel.tranches \
  --recal-file ${WDIR}/vcfs/${COHORT}_indel.recal \
  -mode INDEL

rm ${WDIR}/vcfs/*${COHORT}*_*
