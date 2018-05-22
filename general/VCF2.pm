#!/use/bin/perl
#
package DisGen::general::VCF2;
use DisGen::general::MakeOpen;
use DisGen::general::AlleleFrequency;
use DisGen::general::GenotypeCount;
use DisGen::general::ComputationalData;

sub CosegregationTSV{
    my ($vcf, $ref_samples) = @_;
    open VCF, "$vcf" or die $!;
	open OTM, "> $out_dir/$out_file.Cosegregation.monoplace.tsv" or die $!;
	open OTB, "> $out_dir/$out_file.Cosegregation.biplace.tsv" or die $!;
#	open OTG, "> $out_dir/$out_file.Cosegregation.genelevel.tsv" or die $!;
	while(<VCF>){
        chomp;
		next if /^##/;
		if (/^#/){
			my @header = (split /\t/);
		    my @sampleNames = @header[9..$#header];

	    	my (@head_samples, @unknown_samples, @ques_raws, @que_unknowns) = ((),());
	
			map{
		        unshift @head_samples, "$samples{$_}->{phenotype}-$_" if $samples{$_}->{phenotype} eq 'case' or $samples{$_}->{phenotype} =~ /\wP/; # case first
    		    unshift @ques_raws, "$_" if $samples{$_}->{phenotype} eq 'case' or $samples{$_}->{phenotype} =~ /\wP/; # case first
        		push @head_samples, "$samples{$_}->{phenotype}-$_" if $samples{$_}->{phenotype} eq 'control' or $samples{$_}->{phenotype} =~ /\wC/; # control follow case
		        push @ques_raws, "$_" if $samples{$_}->{phenotype} eq 'control' or $samples{$_}->{phenotype} =~ /\wC/; # control follow case
    		    push @unknown_samples, "$samples{$_}->{phenotype}-$_" if $samples{$_}->{phenotype} eq 'unknown' or $samples{$_}->{phenotype} =~ /\wU/; # unknown at the end
        		push @que_unknowns, "$_" if $samples{$_}->{phenotype} eq 'unknown' or $samples{$_}->{phenotype} =~ /\wU/; # unknown at the end
		    }@sampleNames;

		    push @head_samples, @unknown_samples;
    		push @ques_raws, @que_unknowns;		

	    	my $que_id = 0;
		    map{$sample_ques{$_} = $que_id; $que_id ++;}@sampleNames;
    		map{$sample_ques_adjs[$_] = $sample_ques{$ques_raws[$_]};}(0..$#ques_raws);
		}else{
			next;
		}

	}
	close VCF;
}

sub PopulationDataTSV{
	my ($vcf, $sig_chr, $out_dir, $out_file) = @_;
	open VCF, "$vcf" or die $!;
	open OTAF, "> $out_dir/$out_file.PopulationData.AF.tsv" or die $!;
	open OTGC, "> $out_dir/$out_file.PopulationData.GC.tsv" or die $!;
	while(<VCF>){
		chomp;
		next if /^#/;
		my ($chr, $pos, $rs, $ref, $alt) = (split /\t/)[0,1,2,3,4];
		$chr =~ s/chr//;
        next unless $chr eq $sig_chr;
		foreach my $allele (split /,/, $alt){
    	    my ($gc_info, $pd_info);

			my ($ref_dbcase_query_results) = DisGen::general::GenotypeCount::get_gc($chr, $pos, $ref, $allele);
        	my @dbcase_query_results = @$ref_dbcase_query_results;
	        $gc_info = join "\t", @dbcase_query_results;	
			print OTGC "$chr:$pos:$ref:$allele\t$gc_info\n";

			my ($temp_v_snv_num, $temp_v_indel_num, $ref_dbpp_query_results) = DisGen::general::AlleleFrequency::get_all_af($chr, $pos, $ref, $allele);
        	my @dbpp_query_results = @$ref_dbpp_query_results;
	        $pd_info = join "\t", @dbpp_query_results;	
			print OTAF "$pd_info\n";
		}
	}
	close VCF;
}

sub ComputationalDataTSV{
	my ($vcf, $sig_chr, $out_dir, $out_file, $ref_version) = @_;
    open VCF, "$vcf" or die $!;
    open OTAL, "> $out_dir/$out_file.ComputationalData.AL.tsv" or die $!;
    while(<VCF>){
        chomp;
        next if /^#/;
        my ($chr, $pos, $rs, $ref, $alt) = (split /\t/)[0,1,2,3,4];
        $chr =~ s/chr//;
        next unless $chr eq $sig_chr;
        foreach my $allele (split /,/, $alt){
            my ($al_info);
            my ($ref_query_results) = DisGen::general::ComputationalData::get_all_predict($chr, $pos, $ref, $allele, $ref_version);
            my @query_results = @$ref_query_results;
            $al_info = join "\t", @query_results;
#            print OTAL "$chr:$pos:$ref:$allele\t$al_info\n";
            print OTAL "$al_info\n" unless $al_info =~ /^$/;
		}
	}
	close OTAL;
}

sub FunctionalDataTSV{}
sub SegregationDataTSV{}
sub OtherDatabasesTSV{}

sub vcf2test{
	my ($vcf, $sig_chr, $out_dir, $out_file, $config) = @_;

	my ($dbs, $af_header, $db_count);

	my %pd_threshold = %$config;
	foreach (keys %pd_threshold){
    	$dbs .= "$_," unless $_ eq 'db_count_threshold';
	    $af_header .= "$_\t" unless $_ eq 'db_count_threshold';
    	$db_count ++ unless $_ eq 'db_count_threshold';
	}


	$dbs =~ s/,$//g;
	$af_header =~ s/\t$//g;


	my ($v_num, $v_snv_num, $v_indel_num, $v_highaf_num, $v_snv_highaf_num, $v_indel_highaf_num, %stat) = (0,0,0,0);
#	&mkopen('VCF', $vcf, "<");
	open VCF, "$vcf" or die $!;
#	&mkopen('OT', "$out_file.AF", ">");
	open OT, "> $out_file.AF" or die $!;
#	&mkopen('OT2', "$out_file.stat", ">");
	open OT2, "> $out_file.stat" or die $!;
	while(<VCF>){
		chomp;
		print OT "filter\t#_of_highAF_db\t$af_header\t$_\n" if /^CHR/ and $sig_chr eq 'HEADER';
		next if /^##/;
		next if /^#/;
# CHR     POS     ID      REF     ALT	VarType	Allele
		my ($chr, $pos, $rs, $ref, $alt) = (split /\t/)[0,1,2,3,4];
		$chr =~ s/chr//;
		next unless $chr eq $sig_chr;

		my $sample_info = (join "\t", @sample_infos);
		foreach my $allele (split /,/, $alt){
		$v_num  ++;
##########
		my ($ref_dbcase_query_results) = DisGen::general::GenotypeCount::get_gc($chr, $pos, $ref, $allele);
		my @dbcase_query_results = @$ref_dbcase_query_results;
		my $gc_info;
		$gc_info = join "\t", @dbcase_query_results;
#print "$chr:$pos:$ref:$allele -> $dbcase_query_results[0] | $dbcase_query_results[1] | $dbcase_query_results[2]\n";
#########
		my ($temp_v_snv_num, $temp_v_indel_num, $ref_dbpp_query_results) = DisGen::general::AlleleFrequency::get_af($chr, $pos, $ref, $allele, $dbs, $db_count);
		$v_snv_num += $temp_v_snv_num;
		$v_indel_num += $temp_v_indel_num;

		my @dbpp_query_results = @$ref_dbpp_query_results;

		my ($is_pass, $i, $af_info, $db_num) = ('PASS', 0, '', 0);
		foreach (split /,/, $dbs){
			if ($dbpp_query_results[$i] > 0.05){
				$stat{$_}{'gt5'} ++;
			} elsif ($dbpp_query_results[$i] > 0.01 && $dbpp_query_results[$i] <= 0.05){
				$stat{$_}{'1to5'} ++;
			} elsif ($dbpp_query_results[$i] > 0.001 && $dbpp_query_results[$i] <= 0.01){
				$stat{$_}{'01to1'} ++;
			} elsif ($dbpp_query_results[$i] > 0 && $dbpp_query_results[$i] <= 0.001){
				$stat{$_}{'001to01'} ++;
			} else {
				$stat{$_}{'novel'} ++;
			}

				$af_info .= "$dbpp_query_results[$i]\t";
#				$af_info .= "$_=$dbpp_query_results[$i];";
			if ($dbpp_query_results[$i] > $pd_threshold{$_}){
				$is_pass = 'HighAF';
				$db_num ++;
			}
			$i ++;
		}
#print "db_count_threshold: $pd_threshold{db_count_threshold}\n";
		$is_pass = 'filter-HighAF'if $db_num > $pd_threshold{db_count_threshold};
		
#		$af_info = '.' unless $af_info =~ /\w+/;
		if($af_info !~ /\w+/){
			@dbpp_query_results = ('.') x $db_count;
			$af_info = join "\t", @dbpp_query_results;
		}
		$af_info =~ s/;$//;
		$af_info =~ s/\t$//;

		if ($is_pass eq 'filter-HighAF'){
			$v_highaf_num ++ ;
			if(length($ref) == 1 && length($allele) == 1){
				$v_snv_highaf_num ++;
			}else{
				$v_indel_highaf_num ++;
			}
		}
#		print OT "chr$chr\t$pos\t$rs\t$ref\t$allele\t$is_pass\t$db_num\t$af_info\n";
		print OT "$is_pass\t$db_num\t$af_info\t$gc_info\t$_\n";
		}
	}
	print OT2 "chr$sig_chr, total allele: $v_num (snv: $v_snv_num | indel: $v_indel_num ), filter-high AF allele:$v_highaf_num (snv: $v_snv_highaf_num | indel: $v_indel_highaf_num )\n";
	print OT2 "gt5\t1to5\t01to1\t001to01\tnovel\tdb\n";
	foreach (split /,/, $dbs){
		print OT2 "$stat{$_}{'gt5'}\t$stat{$_}{'1to5'}\t$stat{$_}{'01to1'}\t$stat{$_}{'001to01'}\t$stat{$_}{'novel'}\t$_\n";
	}
	close VCF;
}

1;
