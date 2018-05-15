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
	my ($tool, $input_bam, $out_file_prefix, $out_dir) = @_;
    my $cmd;

	$cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk} -T RealignerTargetCreator -R $DisGen::general::Resource::_wfdata_{bundle_28_hg19}/ucsc.hg19.fasta -I $input_bam -o $out_dir/$out_file_prefix.dedup.intervals -nt 4 && $DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk} -T IndelRealigner -R $DisGen::general::Resource::_wfdata_{bundle_28_hg19}/ucsc.hg19.fasta -targetIntervals $out_dir/$out_file_prefix.dedup.intervals -I $input_bam -o $out_dir/$out_file_prefix.dedup.realn.bam && rm $input_bam && $DisGen::general::Resource::_wftool_{samtools} index $out_dir/$out_file_prefix.dedup.realn.bam $out_dir/$out_file_prefix.dedup.realn.bai";

	return ($cmd);
}

sub bqsrbam {
	my ($tool, $input_bam, $out_file_prefix, $out_dir, $region) = @_;
    my ($bed, $cmd);

	$bed = "-L $DisGen::general::Resource::_wfdata_{bed_dir}/${region}_0bp/${region}_0bp.bed" if -e "$DisGen::general::Resource::_wfdata_{bed_dir}/${region}_0bp/${region}_0bp.bed";
	$cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk} -T BaseRecalibrator -R $DisGen::general::Resource::_wfdata_{bundle_28_hg19}/ucsc.hg19.fasta -I $input_bam -knownSites $DisGen::general::Resource::_wfdata_{bundle_28_hg19}/dbsnp_138.hg19.vcf -o $out_dir/$out_file_prefix.dedup.realn.recal.grp $bed && $DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk} -T PrintReads -R $DisGen::general::Resource::_wfdata_{bundle_28_hg19}/ucsc.hg19.fasta -I $input_bam -BQSR $out_dir/$out_file_prefix.dedup.realn.recal.grp -o $out_dir/$out_file_prefix.dedup.realn.recal.bam && rm $input_bam && $DisGen::general::Resource::_wftool_{samtools} index $out_dir/$out_file_prefix.dedup.realn.recal.bam $out_dir/$out_file_prefix.dedup.realn.recal.bai";

	return ($cmd);
}

sub chrbam {

}

sub cram {

}

sub gvcf2vcf {
    my ($tool, $input_bam, $out_file_prefix, $out_dir, $region) = @_;
    my ($bed, $cmd);

    $bed = "-L $DisGen::general::Resource::_wfdata_{bed_dir}/${region}_0bp/${region}_0bp.bed" if -e "$DisGen::general::Resource::_wfdata_{bed_dir}/${region}_0bp/${region}_0bp.bed"; # if region is WGS, -L argument is not need
    $cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk} -T HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{bundle_28_hg19}/ucsc.hg19.fasta -I $input_bam -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 --dbsnp $DisGen::general::Resource::_wfdata_{bundle_28_hg19}/dbsnp_138.hg19.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.gvcf.vcf $bed && $DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk} -T GenotypeGVCFs -R $DisGen::general::Resource::_wfdata_{bundle_28_hg19}/ucsc.hg19.fasta --variant $out_dir/$out_file_prefix.gvcf.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.gatkHC.vcf --dbsnp $DisGen::general::Resource::_wfdata_{bundle_28_hg19}/dbsnp_138.hg19.vcf -stand_call_conf 30.0 -stand_emit_conf 10.0 $bed";

	return ($cmd);
}

sub gvcf {}

1;
