package DisGen::pipeline::FQ2;

use DisGen::general::Resource;

sub cleanFQ {
	my ($tool, $platform, $fq1, $fq2, $outDir, $cleanFQ1, $cleanFQ2) = @_;
	my $cmd;

	if ($tools =~ /soapnuke/i){
		if ($platform =~ /BGISEQ/i){
			$cmd = "$DisGen::general::Resource::_wftool_{SOAPnuke} filter -Q 2 -G -f AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA -r CAACTCCTTGGCTCACAGAACGACATGGCTACGATCCGACTT -1 $fq1 -2 $fq2 -o $out_dir -C $cleanFQ1 -D $cleanFQ2";
		}elsif($platform =~ /Hiseq4000|xTen/i){
			$cmd = "$DisGen::general::Resource::_wftool_{SOAPnuke} filter --seqType 1 --outType 1 -Q 2 -G -1 $fq1 -2 $fq2 -o $out_dir -C $cleanFQ1 -D $cleanFQ2";
		}elsif($platform =~ /illumina|Hiseq2000|Hiseq2500/i){
			$cmd = "$DisGen::general::Resource::_wftool_{SOAPnuke} filter -G -1 $fq1 -2 $fq2 -o $out_dir -C $cleanFQ1 -D $cleanFQ2";
		}elsif($platform =~ /MiSeq/i and $head =~ /#[ATCGN]+\/[12]$/){
			$cmd = "$DisGen::general::Resource::_wftool_{SOAPnuke} filter -Q 2 -G -1 $fq1 -2 $fq2 -o $out_dir -C $cleanFQ1 -D $cleanFQ2";
		}elsif($platform =~ /^auto/i){

		}else{
			
		}
	}

	return ($cmd);
}

sub bam {
	my ($tool, $rg, $ref, $outDir, $cleanFQ1, $cleanFQ2) = @_;
	my $cmd;
	
	if ($tools =~ /bwa/i){
		$cmd = "$DisGen::general::Resource::_wftool_{bwa} mem -t 8 -R \"$rg\" -aM $ref $cleanFQ1 $cleanFQ2 | $DisGen::general::Resource::_wftool_{perl} $DisGen::general::Resource::_wftool_{filtBAM} $out_dir/lane.raw.bam";
	}
	
	return ($cmd);
}

1;
