#!/use/bin/perl
#
package DisGen::general::Resource;

our %env_vars = (
    PATH => "\$PATH",
    PERL5LIB => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/perl-5.24.0/lib"
);

our %_wftool_ = (
    perl => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/perl-5.24.0/bin/perl",
	SOAPnuke => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/bin/SOAPnuke",
#    bwa => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/bwa-0.7.10/bwa",
    bwa => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/bwa-0.7.17/bwa",
    filtBAM => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/script/filterBAM.pl",
    java => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/jre1.8.0_131/bin/java",
#    gatk => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar",
    gatk => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/gatk-4.0.0.0/gatk-package-4.0.0.0-local.jar",
    picardtoolsdir => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/picard-tools-1.117",
    samtools => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/samtools-0.1.19/samtools",
    bamByChr => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/script/bamByChr.pl",
    VEP => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/ensembl-tools-release-77/scripts/variant_effect_predictor/variant_effect_predictor.pl",
    bcftools => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/samtools-0.1.19/bcftools/bcftools",
    bgzip => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/bin/bgzip",
    tabix => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/bin/tabix",


);

our %_wfdata_ = (
    dbpp => '/hwfssz1/ST_MCHRI/DISEASE/USER/heyuan/Project/Freq/sql',
    dbcase => '/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdclinic/v3.0.0/data/dbcase',
#    bwa7ucsc19ref => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/bundle_2.8_hg19/bwa-0.7.10-r789/ucsc.hg19.fasta",
    bwa7hg19ref => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/data/gatk_bundle/hg19/0.7.17-r1188/reference.fasta",
    bwa7hg38ref => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/data/gatk_bundle/hg38/0.7.17-r1188/reference.fasta",
#    bundle_28_hg19 =>"/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/bundle_2.8_hg19",
    gatk_bundle_hg19 =>"/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/data/gatk_bundle/hg19",
    gatk_bundle_hg38 =>"/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/data/gatk_bundle/hg38",
#    ucsc19ref => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/bundle_2.8_hg19/ucsc.hg19.fasta",
    hg19ref => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/data/gatk_bundle/hg19/ucsc.hg19.fasta",
    hg38ref => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/data/gatk_bundle/hg38/Homo_sapiens_assembly38.fasta",
    bed_dir_hg19 => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/BED",
    bed_dir_hg38 => "/hwfssz1/ST_MCHRI/DISEASE/USER/heyuan/Pipeline/2018v1/Bed_hg38",
#    ComputationalData_VL => '/hwfssz1/ST_MCHRI/DISEASE/USER/heyuan/Pipeline/2018v1/data/dbNSFP/InChr',
    dbNSFP => '/hwfssz1/ST_MCHRI/DISEASE/USER/heyuan/Pipeline/2018v1/data/dbNSFP/InChr',
#    ComputationalData_GL => '/hwfssz1/ST_MCHRI/DISEASE/USER/heyuan/Pipeline/2018v1/data/dbNSFP/InChr',
    OtherDB =>'/hwfssz1/ST_MCHRI/DISEASE/USER/heyuan/Pipeline/2018v1/data/clinvar_hgmd',
    gwas_catalog=>'/hwfssz1/ST_MCHRI/DISEASE/USER/heyuan/Pipeline/2018v1/data/gwas',

);

1;
