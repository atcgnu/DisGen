package  DisGen::pipeline::RDresearch;

use DisGen::pipeline::FQ2;
use DisGen::pipeline::BAM2;
use DisGen::pipeline::VCF2;
use DisGen::pipeline::GVCF2;
use DisGen::pipeline::SETENV;
use DisGen::pipeline::Monitor;
use DisGen::pipeline::EchoString;

sub StageLane {
	my ($out_dir, $version, $sample_id, $region, $ref_lanes) = @_;
		my %lanes = %$ref_lanes;
        my ($ref_version, @jobIDs);
		
		$ref_version = 'hg19' if $version =~ /hg19|grch37/i;
		$ref_version = 'hg38' if $version =~ /hg38|grch38/i;
		my $bed_dir = "bed_dir_$ref_version";

        foreach my $slane (keys %lanes){ # ensure multi-lane sample handled properly
            my $i;
            map{
                $i ++;
                my $lane = "${slane}_$i";
		
				my $out_file_prefix = "lane";

				my ($rgpu, $rgsm, $rgid, $rglb) = ('unknown', 'unknown', 'unknown', 'unknown');
                $rgid = "RGID_$lane";
                my $rg="\@RG\\tID:$rgid\\tPL:ILLUMINA\\tPU:$rgpu\\tLB:$rglb\\tSM:$sample_id\\tCN:BGI"; # GATK do not recognize BGISEQ, so set PL as 'ILLUMINA' by default

                my ($fq1, $fq2) = (split /,/);

				if($fq1 eq $fq2){ # || !-e $fq1 || !-e $fq2
                    die "fq1:$fq1 eq fq2 $fq2\nplease check fq settings of $sample_id\n";
                }elsif (!-e $fq1){
                    die "fq1 inexistence\nplease check $fq1 of $sample_id\n";
				}elsif(!-e $fq2){
                    die "fq2 inexistence\nplease check $fq2 of $sample_id\n";
				}

                my ($cleanFQ1, $cleanFQ2)=("pe_1.fq.gz","pe_2.fq.gz");
                my $script = "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/sh.e.o/stage_lane.sh";
                my $log_dir = "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/sh.e.o/log";
                my $tmp_dir = "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/tmp";

				my $dest_cleanFQ = "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/cleanFQ/SOAPnuke";
				my $dest_alignment = "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/alignment/bwa_mem";

				`mkdir -p $log_dir` unless -e "mkdir -p $log_dir";
				`mkdir -p $tmp_dir` unless -e "mkdir -p $tmp_dir";

				open OT, ">$script" or die $!;
# mkcleanFQ
                my ($linkFQ_cmd) = DisGen::pipeline::FQ2::linkFQ($fq1, $fq2, "$tmp_dir"); # Attention: check-up the quality system applied by sequencer
				DisGen::pipeline::Monitor::robust2execute($log_dir , "linkFQ", $script, $linkFQ_cmd, 3, *OT, "$tmp_dir", "$dest_cleanFQ");

                my ($rawFQ_QC_cmd) = DisGen::pipeline::FQ2::stat("fastqc", $fq1, $fq2, "$tmp_dir"); # Attention: check-up the quality system applied by sequencer
				DisGen::pipeline::Monitor::robust2execute($log_dir , "rawFQ_QC", $script, $rawFQ_QC_cmd, 3, *OT, "$tmp_dir", "$dest_cleanFQ");

                my ($cleanFQ_cmd) = DisGen::pipeline::FQ2::cleanFQ("SOAPnuke", $version, $fq1, $fq2, "$tmp_dir", $cleanFQ1, $cleanFQ2); # Attention: check-up the quality system applied by sequencer
				#my ($logpath, $logbase, $shellpath, $cmdline, $cycle_num, $out_fh, $tmp_dir, $dest_dir)=@_;
				DisGen::pipeline::Monitor::robust2execute($log_dir , "rawFQ2cleanedFQ", $script, $cleanFQ_cmd, 3, *OT, "$tmp_dir", "$dest_cleanFQ");

                my ($cleanFQ_QC_cmd) = DisGen::pipeline::FQ2::stat("fastqc", "$dest_cleanFQ/pe_1.fq.gz", "$dest_cleanFQ/pe_2.fq.gz", "$tmp_dir"); # Attention: check-up the quality system applied by sequencer
				DisGen::pipeline::Monitor::robust2execute($log_dir , "cleanFQ_QC", $script, $cleanFQ_QC_cmd, 3, *OT, "$tmp_dir", "$dest_cleanFQ");

# my ($tool, $rg, $ref, $outDir, $cleanFQ1, $cleanFQ2) = @_;
                my ($alignment_cmd) = DisGen::pipeline::FQ2::bam('bwa', $ref_version, $rg, "$dest_cleanFQ/$cleanFQ1", "$dest_cleanFQ/$cleanFQ2", "$tmp_dir", $out_file_prefix); # Attention: check-up the quality system applied by sequencer
				DisGen::pipeline::Monitor::robust2execute($log_dir , "cleanedFQ2rawBAM", $script, $alignment_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

                my ($sortbam_cmd) = DisGen::pipeline::BAM2::sortedbam('picard', "$dest_alignment/$out_file_prefix.raw.bam", "$out_file_prefix", "$tmp_dir"); 
				DisGen::pipeline::Monitor::robust2execute($log_dir , "rawBAM2sortedBAM", $script, $sortbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

#                my ($dedupbam_cmd) = DisGen::pipeline::BAM2::dedupbam('picard', "$dest_alignment/$out_file_prefix.sorted.bam", "$out_file_prefix", "$tmp_dir"); 
#				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "dedupbam", $script, $dedupbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

#                my ($realnbam_cmd) = DisGen::pipeline::BAM2::realnbam('gatk', "$dest_alignment/$out_file_prefix.dedup.bam", "$out_file_prefix", "$tmp_dir"); 
#				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "realnbam", $script, $realnbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

#                my ($bqsrbam_cmd) = DisGen::pipeline::BAM2::bqsrbam('gatk', "$dest_alignment/$out_file_prefix.dedup.realn.bam", "$out_file_prefix", "$tmp_dir", $region); 
#				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "bqsrbam", $script, $bqsrbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

				DisGen::pipeline::Monitor::EchoSWRD($log_dir , "rawBAM2sortedBAM", $script, *OT);

                close OT;
                push @jobIDs, "$script:8G:8CPU";
            }(split /;/, $lanes{$slane}{FQs});
        }
        return (\@jobIDs);
}

sub StageSample {
    my ($out_dir, $version, $sample_id, $region, $ref_lanes, $bychr, $ref_cohort) = @_;
	my %lanes = %$ref_lanes;
	my %cohort = %$ref_cohort;

    my ($ref_version, @jobIDs);
	
	$ref_version = 'hg19' if $version =~ /hg19|grch37/i;
	$ref_version = 'hg38' if $version =~ /hg38|grch38/i;
	my $bed_dir = "bed_dir_$ref_version";

    my $script = "$out_dir/$sample_id/$version/0.temp/2.sample/sh.e.o/stage_sample.sh";
    my $log_dir = "$out_dir/$sample_id/$version/0.temp/2.sample/sh.e.o/log";
    my $tmp_dir = "$out_dir/$sample_id/$version/0.temp/2.sample/tmp";

    my $dest_alignment = "$out_dir/$sample_id/$version/0.temp/2.sample/result";
    my $dest_bychr = "$out_dir/$sample_id/$version/0.temp/2.sample/ByChr";

    `mkdir -p $log_dir` unless -e "mkdir -p $log_dir";
    `mkdir -p $tmp_dir` unless -e "mkdir -p $tmp_dir";

    my $out_file_prefix = "sample";
	my @dedup_input_bam;

    open OT, ">$script" or die $!;

	my ($setenv_cmd) = DisGen::pipeline::SETENV::DEFAULT('default');
	print OT "$setenv_cmd\n\n";

    foreach my $slane (keys %lanes){ # ensure multi-lane sample handled properly
        my $i;
        map{
            $i ++;
            my $lane = "${slane}_$i";
			push @dedup_input_bam, "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/alignment/bwa_mem/lane.sorted.bam";
        }(split /;/, $lanes{$slane}{FQs});
    }

    my ($dedupbam_cmd) = DisGen::pipeline::BAM2::dedupbam('picard', \@dedup_input_bam, "$out_file_prefix", "$tmp_dir"); 
	DisGen::pipeline::Monitor::robust2execute($log_dir , "soredBAM2dedupedBAM", $script, $dedupbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

#    my ($realnbam_cmd) = DisGen::pipeline::BAM2::realnbam('gatk4', $ref_version, "$dest_alignment/$out_file_prefix.dedup.bam", "$out_file_prefix", "$tmp_dir"); 
#	DisGen::pipeline::Monitor::robust2execute($log_dir , "realnbam", $script, $realnbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

    my ($bqsrbam_cmd) = DisGen::pipeline::BAM2::bqsrbam('gatk4', $ref_version, "$dest_alignment/$out_file_prefix.dedup.bam", "$out_file_prefix", "$tmp_dir", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr${chr}.bed"); 
	DisGen::pipeline::Monitor::robust2execute($log_dir , "dedupedBAM2bqsrBAM", $script, $bqsrbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");
#	DisGena::pipeline::Monitor::EchoSWRD($log_dir , "dedupedBAM2bqsrBAM", $script, *OT);

	if($bychr eq 'YES'){

    	my $dest_bychr = "$out_dir/$sample_id/$version/0.temp/2.sample/ByChr";

	    my ($chrbam_cmd) = DisGen::pipeline::BAM2::chrbam('bamByChr', "$dest_alignment/$out_file_prefix.dedup.recal.bam", "$out_file_prefix", "$dest_bychr"); 
		DisGen::pipeline::Monitor::robust2execute($log_dir , "sampleBAM2chrBAM", $script, $chrbam_cmd, 3, *OT, "$tmp_dir", "$dest_bychr");
		DisGen::pipeline::Monitor::EchoSWRD($log_dir , "sampleBAM2chrBAM", $script, *OT);

		my ($ref_job_chr, $ref_job_merge) = &StageChr($out_dir, $version, $sample_id, $region, $ref_cohort);

	    close OT;
    	push @jobIDs, "$script:8G:8CPU";
	    return (\@jobIDs, $ref_job_chr, $ref_job_merge);
	}else{

	    my ($bam2gvcf_cmd) = DisGen::pipeline::BAM2::gvcf('gatk4', $ref_version, "$dest_alignment/$out_file_prefix.dedup.recal.bam", "$out_file_prefix", "$tmp_dir", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/${region}_0bp.bed"); 
		DisGen::pipeline::Monitor::robust2execute($log_dir , "BAM2GVCF", $script, $bam2gvcf_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

	    my ($gvcf2vcf_cmd) = DisGen::pipeline::GVCF2::vcf('gatk4', $ref_version, "$dest_alignment/$out_file_prefix.g.vcf", "$out_file_prefix", "$tmp_dir", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/${region}_0bp.bed"); 
		DisGen::pipeline::Monitor::robust2execute($log_dir , "GVCF2VCF", $script, $gvcf2vcf_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

      	my ($vcf2vep_cmd) = DisGen::pipeline::VCF2::VEPvcf('vep91', $ref_version, "$dest_alignment/$out_file_prefix.gatkHC.vcf", "$out_file_prefix", "$tmp_dir", $region); 
		DisGen::pipeline::Monitor::robust2execute($log_dir , "VCF2VEP", $script, $vcf2vpe_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

#		DisGen::pipeline::Monitor::EchoSWRD($log_dir , "bam2gvcf2vcf", $script, *OT);
		DisGen::pipeline::Monitor::EchoSWRD($log_dir , "VCF2VEP", $script, *OT);
	    close OT;
    	push @jobIDs, "$script:8G:8CPU";
	    return (\@jobIDs);
	}
}

sub StageChr {
    my ($out_dir, $version, $sample_id, $region, $ref_cohort) = @_;

	my %cohort = %$ref_cohort;

    my ($ref_version, @jobIDs_chr, @jobIDs_sample);
	
    $ref_version = 'hg19' if $version =~ /hg19|grch37/i;
    $ref_version = 'hg38' if $version =~ /hg38|grch38/i;
    my $bed_dir = "bed_dir_$ref_version";

    my $log_dir = "$out_dir/$sample_id/$version/0.temp/2.sample/sh.e.o/log";
    my $tmp_dir = "$out_dir/$sample_id/$version/0.temp/2.sample/tmp";
    my $des_dir = "$out_dir/$sample_id/$version/0.temp/2.sample/result";

#    my (@jobIDs_chr, @jobIDs_sample);
    my ($chr_gvcf_vcf, $chr_gatk_vcf);
    my $script_merge = "$out_dir/$sample_id/$version/0.temp/2.sample/sh.e.o/stage_sample_mergeChrVCF.sh";

    open SOT, ">$script_merge" or die $!;
    my ($setenv_cmd) = DisGen::pipeline::SETENV::DEFAULT('default');
    print SOT "$setenv_cmd\n\n";

    foreach my $chr (1..22,'X','Y','M'){
if (-s "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr$chr.bed"){
        my $script = "$out_dir/$sample_id/$version/0.temp/2.sample/ByChr/chr$chr/sh.e.o/stage_chr.sh";
        my $log_dir = "$out_dir/$sample_id/$version/0.temp/2.sample/ByChr/chr$chr/sh.e.o/log";
        my $tmp_dir = "$out_dir/$sample_id/$version/0.temp/2.sample/ByChr/chr$chr/tmp";

        `mkdir -p $log_dir` unless -e "$log_dir";
        `mkdir -p $tmp_dir` unless -e "$tmp_dir";

        open OT, ">$script" or die $!;

		my ($setenv_cmd) = DisGen::pipeline::SETENV::DEFAULT('default');
		print OT "$setenv_cmd\n\n";

        my $dest_call = "$out_dir/$sample_id/$version/0.temp/2.sample/ByChr/chr$chr";
        my $out_file_prefix = "chr$chr";

#        my ($bam2gvcf2vcf_cmd) = DisGen::pipeline::BAM2::gvcf2vcf('gatk4', $ref_version, "$dest_call/chr$chr.bam", "$out_file_prefix", "$tmp_dir", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr${chr}.bed");
#===========
#stat
#     my ($tool, $input_bam, $out_dir, $region, $ccds) = @_;
#
if (-e "$DisGen::general::Resource::_wfdata_{CCDS}/chr$chr"){
        my ($bam2stat_cmd) = DisGen::pipeline::BAM2::stat_by_chr('SoapChrStat', "$dest_call/chr$chr.bam", "$tmp_dir", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr$chr.bed", "$DisGen::general::Resource::_wfdata_{CCDS}/chr$chr");
		DisGen::pipeline::Monitor::robust2execute($log_dir , "BAM2STAT", $script, $bam2stat_cmd, 3, *OT, "$tmp_dir", "$dest_call/Stat");
}
# platypus
	    my ($bam2platypusVCF_cmd) = DisGen::pipeline::BAM2::vcf('platypus', $ref_version, "$dest_call/chr$chr.bam", "$out_file_prefix", "$tmp_dir", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr$chr.bed", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr$chr.interval");
 
		DisGen::pipeline::Monitor::robust2execute($log_dir , "BAM2platypusVCF", $script, $bam2platypusVCF_cmd, 3, *OT, "$tmp_dir", "$dest_call");
# speedseq
	    my ($bam2speedseqVCF_cmd) = DisGen::pipeline::BAM2::vcf('speedseq', $ref_version, "$dest_call/chr$chr.bam", "$out_file_prefix", "$tmp_dir", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr$chr.bed", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr$chr.interval");
		DisGen::pipeline::Monitor::robust2execute($log_dir , "BAM2speedseqVCF", $script, $bam2speedseqVCF_cmd, 3, *OT, "$tmp_dir", "$dest_call");
 
# gatk4
	    my ($bam2gvcf_cmd) = DisGen::pipeline::BAM2::gvcf('gatk4', $ref_version, "$dest_call/chr$chr.bam", "$out_file_prefix", "$tmp_dir", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr$chr.bed"); 
		DisGen::pipeline::Monitor::robust2execute($log_dir , "BAM2GVCF", $script, $bam2gvcf_cmd, 3, *OT, "$tmp_dir", "$dest_call");
	    my ($gvcf2vcf_cmd) = DisGen::pipeline::GVCF2::vcf('gatk4', $ref_version, "$dest_call/$out_file_prefix.g.vcf", "$out_file_prefix", "$tmp_dir", "$DisGen::general::Resource::_wfdata_{$bed_dir}/${region}_0bp/chr$chr.bed"); 
		DisGen::pipeline::Monitor::robust2execute($log_dir , "GVCF2VCF", $script, $gvcf2vcf_cmd, 3, *OT, "$tmp_dir", "$dest_call");

        $chr_gvcf_vcf .= " $dest_call/chr$chr.g.vcf";
        $chr_gatk_vcf .= " $dest_call/chr$chr.gatkHC.vcf";
        $chr_platypus_vcf .= " $dest_call/chr$chr.platypus.vcf";
        $chr_speedseq_vcf .= " $dest_call/chr$chr.speedseq.vcf.gz";

		DisGen::pipeline::Monitor::EchoSWRD($log_dir , "GVCF2VCF", $script, *OT);
        close OT;
    	push @jobIDs_chr, "$script:8G:1CPU";
		}
    }

#     my ($tool, $out_dir, $stat_chr_dir, $sample, $gender) = @_;

	DisGen::pipeline::Monitor::robust2execute($log_dir , "linkByChrSTAT2sample", $script_merge, "ln -s $out_dir/$sample_id/$version/0.temp/2.sample/ByChr/*/Stat/* $tmp_dir", 3, *SOT, "$tmp_dir", "$out_dir/$sample_id/$version/0.temp/2.sample/result/Stat/StatByChr");

    my ($bam2sample_stat_cmd) = DisGen::pipeline::BAM2::stat_by_sample('SoapAllStat',  "$tmp_dir", "$out_dir/$sample_id/$version/0.temp/2.sample/result/Stat/StatByChr", $sample_id, $cohort{$sample_id}->{gender});
	DisGen::pipeline::Monitor::robust2execute($log_dir , "BAM2sampleSTAT", $script_merge, $bam2sample_stat_cmd, 3, *SOT, "$tmp_dir", "$out_dir/$sample_id/$version/0.temp/2.sample/result//Stat");

    DisGen::pipeline::Monitor::robust2execute($log_dir , "mergeChrvcf", $script_merge, "$DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{vcf_concat} $chr_gvcf_vcf > $tmp_dir/sample.gvcf.vcf && $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{vcf_concat} $chr_gatk_vcf > $tmp_dir/sample.gatkHC.vcf && $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{vcf_concat} $chr_platypus_vcf  > $tmp_dir/sample.platypus.vcf && $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{vcf_concat} $chr_speedseq_vcf > $tmp_dir/sample.speedseq.vcf", 3, *SOT, "$tmp_dir", "$des_dir");
    DisGen::pipeline::Monitor::EchoSWRD($log_dir , "mergeChrvcf", $script_merge, *SOT);

    push @jobIDs_sample, "$script_merge:1G:1CPU";
    return (\@jobIDs_chr, \@jobIDs_sample);

}

sub StageFamily{}
sub StageTrio{}

1;
