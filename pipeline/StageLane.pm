package  DisGen::pipeline::StageLane;

use DisGen::pipeline::FQ2;

sub mkcleanFQ {
	my ($outDir, $version, $sampleName, $platform, %lanes) = @_;
        my @jobIDs;
        foreach my $slane (keys %lanes){ # ensure multi-lane sample handled properly
            my $i;
            map{
                $i ++;
                my $lane = "${slane}_$i";
                my ($fq1, $fq2) = (split /,/);
                my ($cleanFQ1, $cleanFQ2)=("pe_1.fq.gz","pe_2.fq.gz");
                my $script = "$outDir/$sampleName/$version/lane/$lane/sh.e.o/stage_lane_mkcleanFQ.sh";
#                DisGen::pipeline::FQ2::cleanFQ("SOAPnuke", "$lane", "stage_lane_mkcleanFQ.sh", $platform, $fq1, $fq2, "$outDir/$sampleName/$version", $cleanFQ1, $cleanFQ2); # Attention: check-up the quality system applied by sequencer
                my ($cmd) = DisGen::pipeline::FQ2::cleanFQ("SOAPnuke", $platform, $fq1, $fq2, "$outDir/$sampleName/$version", $cleanFQ1, $cleanFQ2); # Attention: check-up the quality system applied by sequencer

#my ($logpath, $logbase, $shellpath, $cmdline, $cycle_num, $out_fh)=@_;

				DisGen::pipeline::Monitor::robust2execute($logdir , "cleanFQ", $script, $cmd, $cycle, *OT);

                my $sig = $_wfsub_{echostring}->("$script");
                open OT, ">> $script" or die $!;
                print OT "is_end=\`tail -3 $script.o\* | awk \'{print \$2}\'|xargs\`\n";
                print OT "if echo \$is_end | grep -q 'end complete complete'\nthen\n\t$sig\nelse\n\techo failed\nfi\n";
                close OT;
                push @jobIDs, "$script:4G:4CPU";
            }(split /;/, $lanes{$slane}{FQs});
        }
        return (@jobIDs);

	return ();
}

1;
