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
    bwa => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/bwa-0.7.10/bwa",
    filtBAM => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/script/filterBAM.pl",
    java => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/jre1.8.0_131/bin/java",
    gatk => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar",
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
    bwa7ucsc19ref => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/bundle_2.8_hg19/bwa-0.7.10-r789/ucsc.hg19.fasta",
    bundle_28_hg19 =>"/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/bundle_2.8_hg19",
    ucsc19ref => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/bundle_2.8_hg19/ucsc.hg19.fasta",
    bed_dir => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/data/BED",

);

1;
