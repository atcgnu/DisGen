package DisGen::pipeline::BAM2;

sub sortedbam {
	my ($tool, $input_bam, $out_file_prefix, $out_dir) =@_;
	my $cmd;

	if($tool =~ /picard/i){
		$cmd = "$DisGen::general::Resource::_wftool_{java} -XX:+UseParallelGC -XX:ParallelGCThreads=4 -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{picardtoolsdir}/SortSam.jar I=$input_bam OUTPUT=$out_dir/$out_file_prefix.sorted.bam CREATE_INDEX=true CREATE_MD5_FILE=true VALIDATION_STRINGENCY=LENIENT COMPRESSION_LEVEL=0 MAX_RECORDS_IN_RAM=500000 SO=coordinate && rm $input_bam";
	}
	return ($cmd);
}

sub dedupbam {
	my ($tool, $input_bam_ref, $out_file_prefix, $out_dir) = @_;
	my $cmd;

	my @input_bams = @$input_bam_ref;
	my ($input_bam, $input_bam_arg);

	map{
		$input_bam .= "$_ ";
		$input_bam_arg .= "I=$_ ";
	}(@input_bams);
	
	if($tool =~ /picard/i){
		$cmd = "$DisGen::general::Resource::_wftool_{java} -XX:+UseParallelGC -XX:ParallelGCThreads=4 -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{picardtoolsdir}/MarkDuplicates.jar $input_bam_arg OUTPUT=$out_dir/$out_file_prefix.dedup.bam METRICS_FILE=$out_dir/$out_file_prefix.dedup.txt VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=false && rm $input_bam && $DisGen::general::Resource::_wftool_{samtools} index $out_dir/$out_file_prefix.dedup.bam $out_dir/$out_file_prefix.dedup.bai"
	}
	return ($cmd);
}

sub realnbam {
	my ($tool, $ref_version, $input_bam, $out_file_prefix, $out_dir) = @_;
    my $cmd;

	if ($tool =~ /gatk3/i){
		if ($ref_version =~ /hg19|GRCh37/i){
			$cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} -T RealignerTargetCreator -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -I $input_bam -o $out_dir/$out_file_prefix.dedup.intervals -nt 4 && $DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} -T IndelRealigner -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -targetIntervals $out_dir/$out_file_prefix.dedup.intervals -I $input_bam -o $out_dir/$out_file_prefix.dedup.realn.bam && rm $input_bam && $DisGen::general::Resource::_wftool_{samtools} index $out_dir/$out_file_prefix.dedup.realn.bam $out_dir/$out_file_prefix.dedup.realn.bai";
		}elsif($ref_version =~ /hg38|GRCh38/i){
			$cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} RealignerTargetCreator -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam -o $out_dir/$out_file_prefix.dedup.intervals -nt 4 && $DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} IndelRealigner -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -targetIntervals $out_dir/$out_file_prefix.dedup.intervals -I $input_bam -o $out_dir/$out_file_prefix.dedup.realn.bam && rm $input_bam && $DisGen::general::Resource::_wftool_{samtools} index $out_dir/$out_file_prefix.dedup.realn.bam $out_dir/$out_file_prefix.dedup.realn.bai";
		}
	}elsif($tool =~ /gatk4/i){
		$cmd = "echo 'Pass: Indel Realignment tools are not in GATK4'";
	}
	return ($cmd);
}

sub bqsrbam {
	my ($tool, $ref_version, $input_bam, $out_file_prefix, $out_dir, $region) = @_;
    my ($bed, $cmd);

	$bed = "-L $region" if -e "$region";
	if($tool =~ /gatk3/i){
		if ($ref_version =~ /hg19|GRCh37/i){
			$cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} -T BaseRecalibrator -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -I $input_bam -knownSites $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/dbsnp_138.hg19.vcf -o $out_dir/$out_file_prefix.dedup.realn.recal.grp $bed && $DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} -T PrintReads -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -I $input_bam -BQSR $out_dir/$out_file_prefix.dedup.realn.recal.grp -o $out_dir/$out_file_prefix.dedup.realn.recal.bam && rm $input_bam && $DisGen::general::Resource::_wftool_{samtools} index $out_dir/$out_file_prefix.dedup.realn.recal.bam $out_dir/$out_file_prefix.dedup.realn.recal.bai";
		}elsif($ref_version =~ /hg38|GRCh38/i){
			$cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} BaseRecalibrator -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam -knownSites $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -o $out_dir/$out_file_prefix.dedup.realn.recal.grp $bed && $DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} PrintReads -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam -BQSR $out_dir/$out_file_prefix.dedup.realn.recal.grp -o $out_dir/$out_file_prefix.dedup.realn.recal.bam && rm $input_bam && $DisGen::general::Resource::_wftool_{samtools} index $out_dir/$out_file_prefix.dedup.realn.recal.bam $out_dir/$out_file_prefix.dedup.realn.recal.bai";
	
		}
	}elsif($tool =~ /gatk4/i){
		if ($ref_version =~ /hg19|GRCh37/i){
			$cmd = "$DisGen::general::Resource::_wftool_{gatk4} BaseRecalibrator -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -I $input_bam --known-sites $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/dbsnp_138.hg19.vcf -O $out_dir/$out_file_prefix.dedup.recal.table $bed && $DisGen::general::Resource::_wftool_{gatk4} ApplyBQSR -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -I $input_bam -bqsr $out_dir/$out_file_prefix.dedup.recal.table -O $out_dir/$out_file_prefix.dedup.recal.bam && rm $input_bam && $DisGen::general::Resource::_wftool_{samtools} index $out_dir/$out_file_prefix.dedup.recal.bam $out_dir/$out_file_prefix.dedup.recal.bai";

		}elsif($ref_version =~ /hg38|GRCh38/i){
			$cmd = "$DisGen::general::Resource::_wftool_{gatk4} BaseRecalibrator -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam --known-sites $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -O $out_dir/$out_file_prefix.dedup.recal.table $bed && $DisGen::general::Resource::_wftool_{gatk4} ApplyBQSR  -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam -bqsr $out_dir/$out_file_prefix.dedup.recal.table -O $out_dir/$out_file_prefix.dedup.recal.bam && rm $input_bam && $DisGen::general::Resource::_wftool_{samtools} index $out_dir/$out_file_prefix.dedup.recal.bam $out_dir/$out_file_prefix.dedup.recal.bai";
		}
	}
	return ($cmd);
}

sub chrbam {
	my ($tool, $input_bam, $out_file_prefix, $out_dir) = @_;
    my ($bed, $cmd);

	$cmd = "$DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{bamByChr} $input_bam $out_dir";

	return ($cmd);
}

sub cram {

}

sub gvcf2vcf {
    my ($tool, $ref_version, $input_bam, $out_file_prefix, $out_dir, $region) = @_;
    my ($bed, $cmd);


    $bed = "-L $region" if -e $region; # if region is WGS, -L argument is not need
    if($tool =~ /gatk3/i){

	    if ($ref_version =~ /hg19|GRCh37/i){
		    $cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} -T HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -I $input_bam -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/dbsnp_138.hg19.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.g.vcf $bed && $DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} -T GenotypeGVCFs -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta --variant $out_dir/$out_file_prefix.g.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.gatkHC.vcf --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/dbsnp_138.hg19.vcf -stand_call_conf 30.0 -stand_emit_conf 10.0 $bed";

	    }elsif($ref_version =~ /hg38|GRCh38/i){
		    $cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.g.vcf $bed && $DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} GenotypeGVCFs -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta --variant $out_dir/$out_file_prefix.g.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.gatkHC.vcf --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -stand_call_conf 30.0 -stand_emit_conf 10.0 $bed";
		}

	}elsif($tool =~ /gatk4/i){
    	if ($ref_version =~ /hg19|GRCh37/i){
        	$cmd = "$DisGen::general::Resource::_wftool_{gatk4} HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -I $input_bam -ERC GVCF -OBI --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/dbsnp_138.hg19.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.g.vcf $bed && $DisGen::general::Resource::_wftool_{gatk4} GenotypeGVCFs -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta --variant $out_dir/$out_file_prefix.g.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.gatkHC.vcf --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/dbsnp_138.hg19.vcf $bed";

	    }elsif($ref_version =~ /hg38|GRCh38/i){
    	    $cmd = "$DisGen::general::Resource::_wftool_{gatk4} HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam -ERC GVCF --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.g.vcf $bed && $DisGen::general::Resource::_wftool_{gatk4} GenotypeGVCFs -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta --variant $out_dir/$out_file_prefix.g.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.gatkHC.vcf --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf $bed";
	    }
	}
	return ($cmd);
}

sub gvcf {
    my ($tool, $ref_version, $input_bam, $out_file_prefix, $out_dir, $region) = @_;
    my ($bed, $cmd);


    $bed = "-L $region" if -e $region; # if region is WGS, -L argument is not need
    if($tool =~ /gatk3/i){

        if ($ref_version =~ /hg19|GRCh37/i){
            $cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} -T HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -I $input_bam -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/dbsnp_138.hg19.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.g.vcf $bed";

        }elsif($ref_version =~ /hg38|GRCh38/i){
            $cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.g.vcf $bed";
        }

    }elsif($tool =~ /gatk4/i){
        if ($ref_version =~ /hg19|GRCh37/i){
            $cmd = "$DisGen::general::Resource::_wftool_{gatk4} HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta -I $input_bam -ERC GVCF -OBI --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/dbsnp_138.hg19.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.g.vcf $bed";

        }elsif($ref_version =~ /hg38|GRCh38/i){
            $cmd = "$DisGen::general::Resource::_wftool_{gatk4} HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam -ERC GVCF --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.g.vcf $bed";
#            $cmd = "$DisGen::general::Resource::_wftool_{gatk4} HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_bam -ERC GVCF --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.g.vcf";
        }
    }
    return ($cmd);
}

sub vcf {
    my ($tool, $ref_version, $input_bam, $out_file_prefix, $out_dir, $region, $interval) = @_;
    my ($bed, $cmd);
    $bed = "-L $region" if -e $region; # if region is WGS, -L argument is not need
    if($tool =~ /platypus/i){
        if ($ref_version =~ /hg19|GRCh37/i){
			$cmd = "$DisGen::general::Resource::_wftool_{python} $DisGen::general::Resource::_wftool_{platypus} callVariants --bamFiles=$input_bam --refFile=$DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta --output=$out_dir/$out_file_prefix.platypus.vcf --regions=$interval";
        }elsif($ref_version =~ /hg38|GRCh38/i){
			$cmd = "$DisGen::general::Resource::_wftool_{python} $DisGen::general::Resource::_wftool_{platypus} callVariants --bamFiles=$input_bam --refFile=$DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta--output=$out_dir/$out_file_prefix.platypus.vcf --regions=$interval";
		}
	}

    return ($cmd);

}

sub sr_inversion {
	if ($ref_version =~ /hg19|GRCh37/i){
		$cmd = "$DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{SRinversion} -i $input_bam -o $out_dir/$out_file_prefix.s1 -s 1 -r $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta && $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{SRinversion} -i $input_bam -o $out_dir/$out_file_prefix.s2 -s 2 -r $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta";
	}elsif($ref_version =~ /hg38|GRCh38/i){
		$cmd = "$DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{SRinversion} -i $input_bam -o $out_dir/$out_file_prefix.s1 -s 1 -r $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta && $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{SRinversion} -i $input_bam -o $out_dir/$out_file_prefix.s2 -s 2 -r $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta";
	}
}

1;
