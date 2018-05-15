package  DisGen::pipeline::RDresearch;

use DisGen::pipeline::FQ2;
use DisGen::pipeline::EchoString;
use DisGen::pipeline::Monitor;
use DisGen::pipeline::BAM2;

sub StageLane {
	my ($out_dir, $version, $sample_id, $region, %lanes) = @_;
        my @jobIDs;

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
                my $sig = DisGen::pipeline::EchoString::swrd($script); 
# mkcleanFQ
                my ($linkFQ_cmd) = DisGen::pipeline::FQ2::linkFQ($fq1, $fq2, "$tmp_dir"); # Attention: check-up the quality system applied by sequencer
				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "linkFQ", $script, $linkFQ_cmd, 3, *OT, "$tmp_dir", "$dest_cleanFQ");

                my ($cleanFQ_cmd) = DisGen::pipeline::FQ2::cleanFQ("SOAPnuke", $version, $fq1, $fq2, "$tmp_dir", $cleanFQ1, $cleanFQ2); # Attention: check-up the quality system applied by sequencer
				#my ($logpath, $logbase, $shellpath, $cmdline, $cycle_num, $out_fh, $tmp_dir, $dest_dir)=@_;
				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "cleanFQ", $script, $cleanFQ_cmd, 3, *OT, "$tmp_dir", "$dest_cleanFQ");

# my ($tool, $rg, $ref, $outDir, $cleanFQ1, $cleanFQ2) = @_;
                my ($alignment_cmd) = DisGen::pipeline::FQ2::bam('bwa', $rg, "$dest_cleanFQ/$cleanFQ1", "$dest_cleanFQ/$cleanFQ2", "$tmp_dir", $out_file_prefix); # Attention: check-up the quality system applied by sequencer
				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "alignment", $script, $alignment_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

                my ($sortbam_cmd) = DisGen::pipeline::BAM2::sortedbam('picard', "$dest_alignment/$out_file_prefix.raw.bam", "$out_file_prefix", "$tmp_dir"); 
				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "sortbam", $script, $sortbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

#                my ($dedupbam_cmd) = DisGen::pipeline::BAM2::dedupbam('picard', "$dest_alignment/$out_file_prefix.sorted.bam", "$out_file_prefix", "$tmp_dir"); 
#				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "dedupbam", $script, $dedupbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

#                my ($realnbam_cmd) = DisGen::pipeline::BAM2::realnbam('gatk', "$dest_alignment/$out_file_prefix.dedup.bam", "$out_file_prefix", "$tmp_dir"); 
#				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "realnbam", $script, $realnbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

#                my ($bqsrbam_cmd) = DisGen::pipeline::BAM2::bqsrbam('gatk', "$dest_alignment/$out_file_prefix.dedup.realn.bam", "$out_file_prefix", "$tmp_dir", $region); 
#				my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "bqsrbam", $script, $bqsrbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

                close OT;
                push @jobIDs, "$script:8G:8CPU";
            }(split /;/, $lanes{$slane}{FQs});
        }
        return (@jobIDs);
}

sub StageSample {
    my ($out_dir, $version, $sample_id, $region, %lanes) = @_;
        my @jobIDs;
        my $script = "$out_dir/$sample_id/$version/0.temp/2.sample/sh.e.o/stage_sample.sh";
        my $log_dir = "$out_dir/$sample_id/$version/0.temp/2.sample/sh.e.o/log";
        my $tmp_dir = "$out_dir/$sample_id/$version/0.temp/2.sample/tmp";

        my $dest_alignment = "$out_dir/$sample_id/$version/0.temp/2.sample/result";

        `mkdir -p $log_dir` unless -e "mkdir -p $log_dir";
        `mkdir -p $tmp_dir` unless -e "mkdir -p $tmp_dir";

		my $segment = 0;
        my $out_file_prefix = "sample";
		my @dedup_input_bam;

        open OT, ">$script" or die $!;
        my $sig = DisGen::pipeline::EchoString::swrd($script);

        foreach my $slane (keys %lanes){ # ensure multi-lane sample handled properly
            my $i;
            map{
                $i ++;
				$segment += 1;
                my $lane = "${slane}_$i";
				push @dedup_input_bam, "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/alignment/bwa_mem/lane.sorted.bam";
            }(split /;/, $lanes{$slane}{FQs});
        }

#		if ($segment >1){

        my ($dedupbam_cmd) = DisGen::pipeline::BAM2::dedupbam('picard', \@dedup_input_bam, "$out_file_prefix", "$tmp_dir"); 
		my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "dedupbam", $script, $dedupbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

        my ($realnbam_cmd) = DisGen::pipeline::BAM2::realnbam('gatk', "$dest_alignment/$out_file_prefix.dedup.bam", "$out_file_prefix", "$tmp_dir"); 
		my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "realnbam", $script, $realnbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

        my ($bqsrbam_cmd) = DisGen::pipeline::BAM2::bqsrbam('gatk', "$dest_alignment/$out_file_prefix.dedup.realn.bam", "$out_file_prefix", "$tmp_dir", $region); 
		my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "bqsrbam", $script, $bqsrbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

#		}elsif($segment == 1){

#		}else{

#		}

		if($bychr eq 'YES'){

        my ($bqsrbam_cmd) = DisGen::pipeline::BAM2::bqsrbam('gatk', "$dest_alignment/$out_file_prefix.dedup.realn.bam", "$out_file_prefix", "$tmp_dir", $region); 
		my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "bqsrbam", $script, $bqsrbam_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

		}else{

        my ($bam2gvcf2vcf_cmd) = DisGen::pipeline::BAM2::gvcf2vcf('gatk', "$dest_alignment/$out_file_prefix.dedup.realn.recal.bam", "$out_file_prefix", "$tmp_dir", $region); 
		my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "bam2gvcf2vcf", $script, $bam2gvcf2vcf_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");

        my ($vcf2VEPvcf_cmd) = DisGen::pipeline::VCF2::VEPvcf('vep', "$dest_alignment/$out_file_prefix.GATK.vcf", "$out_file_prefix", "$tmp_dir", $region); 
		my ($rt) = DisGen::pipeline::Monitor::robust2execute($log_dir , "vcf2VEPvcf", $script, $vcf2VEPvcf_cmd, 3, *OT, "$tmp_dir", "$dest_alignment");
		}

        close OT;
        push @jobIDs, "$script:8G:8CPU";
        return (@jobIDs);

}

sub StageChr {}
sub StageFamily{}
sub StageTrio{}

1;
