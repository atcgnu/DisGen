#!/use/bin/perl
#
package DisGen::general::Resource;

our %env_vars = (
    PATH => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/bin:\$PATH",
    PERL5LIB => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/perl-5.24.0/lib:/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/vcftools_0.1.12b/lib/perl5/site_perl"
);

our %_wftool_ = (
    perl => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/perl-5.24.0/bin/perl",
    fastqc => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/FastQC/fastqc",
    python => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/Python-2.7.12/bin/python2.7",
	SOAPnuke => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/bin/SOAPnuke",
#    bwa => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/bwa-0.7.10/bwa",
    bwa => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/bwa-0.7.17/bwa",
    filtBAM => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/script/filterBAM.pl",
    SoapChrStat => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/script/SoapChrStat.pl",
    SoapAllStat => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/script/SoapAllStat.pl",
    java => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/jre1.8.0_131/bin/java",
    gatk3 => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar",
    gatk4 => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/gatk-4.0.4.0/gatk",
    platypus => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/Platypus_0.7.2/Platypus.py",
    picardtoolsdir => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/picard-tools-1.117",
    samtools => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/samtools-1.8/samtools",
#    samtools => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/samtools-0.1.19/samtools",
#    bamByChr => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/script/bamByChr.pl",
    bamByChr => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdclinic/v3.0.0/script/bamByChr.pl",
    VEP77 => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/ensembl-tools-release-77/scripts/variant_effect_predictor/variant_effect_predictor.pl",
    VEP91 => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/VEP/v91/ensembl-vep/vep",
    bcftools => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/samtools-0.1.19/bcftools/bcftools",
    bgzip => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/bin/bgzip",
    tabix => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/bin/tabix",
	union_vcf => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/script/multiCallerGT.panel.pl",
    vcf_concat => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/vcftools_0.1.12b/bin/vcf-concat",
    speedseq => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/speedseq/bin/speedseq",
    SRinversion => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/sr_inversion_merge/SRinversion.pl",
    ExonDel => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/ExonDel/ExonDel.pl",
    UPDio => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/UPDio/version_1.0/UPDio.pl",

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
	vep77cache => '/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/cache',
	vep91cache => '/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v3.0.0/software/VEP/v91/ensembl-vep/cache',
    CCDS => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/CCDS",


);

1;
