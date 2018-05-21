package DisGen::pipeline::FQ2;

use DisGen::general::Resource;

sub linkFQ {
# linkFQ($fq1, $fq2, "$tmp_dir", "$dest_cleanFQ")
	my ($fq1, $fq2, $out_dir) = @_;
	my $cmd = "ln -s $fq1 $fq2 $out_dir/";
	return ($cmd);
}

sub fastQC {
    &check_log_stat($logdir, "fastqc_raw", $shell , "$_wftool_{perl} $_wftool_{fastqc} -f fastq $fq1 $fq2 -t 6 -o $out_dir", $cycle, *OT);
}

sub cleanFQ {
	my ($tool, $version, $fq1, $fq2, $out_dir, $cleanFQ1, $cleanFQ2) = @_;
	my $cmd;

	if ($tool =~ /soapnuke/i){
		if ($version =~ /BGISEQ/i){
			$cmd = "$DisGen::general::Resource::_wftool_{SOAPnuke} filter -Q 2 -G -f AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA -r CAACTCCTTGGCTCACAGAACGACATGGCTACGATCCGACTT -1 $fq1 -2 $fq2 -o $out_dir -C $cleanFQ1 -D $cleanFQ2";
		}elsif($version =~ /Hiseq4000|xTen/i){

			$cmd = "$DisGen::general::Resource::_wftool_{SOAPnuke} filter --seqType 1 --outType 1 -Q 2 -G -1 $fq1 -2 $fq2 -o $out_dir -C $cleanFQ1 -D $cleanFQ2";
		}elsif($version =~ /illumina|Hiseq2000|Hiseq2500/i){
			$cmd = "$DisGen::general::Resource::_wftool_{SOAPnuke} filter -G -1 $fq1 -2 $fq2 -o $out_dir -C $cleanFQ1 -D $cleanFQ2";
		}elsif($version =~ /MiSeq/i and $head =~ /#[ATCGN]+\/[12]$/){
			$cmd = "$DisGen::general::Resource::_wftool_{SOAPnuke} filter -Q 2 -G -1 $fq1 -2 $fq2 -o $out_dir -C $cleanFQ1 -D $cleanFQ2";
		}elsif($version =~ /^auto/i){

		}else{
			
		}
	}

	return ($cmd);
}

sub bkbam {
	my ($tool, $rg, $cleanFQ1, $cleanFQ2, $out_dir, $out_file_prefix) = @_;
	my $cmd;
	
	if ($tool =~ /bwa/i){
		$cmd = "$DisGen::general::Resource::_wftool_{bwa} mem -t 8 -R \"$rg\" -M -Y  $DisGen::general::Resource::_wfdata_{bwa7ucsc19ref} $cleanFQ1 $cleanFQ2 | $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{filtBAM} $out_dir/$out_file_prefix.raw.bam";
#		$cmd = "$DisGen::general::Resource::_wftool_{bwa} mem -t 8 -R \"$rg\" -aM $DisGen::general::Resource::_wfdata_{bwa7ucsc19ref} $cleanFQ1 $cleanFQ2 | $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{filtBAM} $out_dir/lane.raw.bam";
	}
	
	return ($cmd);
}

sub bam {
	my ($tool, $ref_version, $rg, $cleanFQ1, $cleanFQ2, $out_dir, $out_file_prefix) = @_;
    my $cmd;

	if ($ref_version =~ /hg19|GRCh37/i){
		if ($tool =~ /bwa/i){
			$cmd = "$DisGen::general::Resource::_wftool_{bwa} mem -t 8 -R \"$rg\" -M -Y  $DisGen::general::Resource::_wfdata_{bwa7hg19ref} $cleanFQ1 $cleanFQ2 | $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{filtBAM} $out_dir/$out_file_prefix.raw.bam";	
		}
	}elsif ($ref_version =~ /hg38|GRCh38/i){
		if ($tool =~ /bwa/i){
			$cmd = "$DisGen::general::Resource::_wftool_{bwa} mem -t 8 -R \"$rg\" -M -Y  $DisGen::general::Resource::_wfdata_{bwa7hg38ref} $cleanFQ1 $cleanFQ2 | $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{filtBAM} $out_dir/$out_file_prefix.raw.bam";
		}
	}
}

1;
