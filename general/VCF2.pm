#!/use/bin/perl
#
package DisGen::general::VCF2;
use DisGen::general::MakeOpen;
use DisGen::general::AlleleFrequency;
use DisGen::general::GenotypeCount;

sub vcf2candidate {
	my ($sig_chr, $out_dir, $out_file, $ref_configs) = @_;
	my %configs = %$ref_configs;
	my %db_filters = ('KG' => 1, 'ESP' => 1,'PVFD' => 1, 'IN-HOUSE-1' => 1,'IN-HOUSE-2' => 1, 'IN-HOUSE-3' => 1,'CG' => 1, 'HapMap' => 1,'Wellderly' => 1, 'ExAC' => 1);
	my @af_dbs = ('KG', 'ESP','PVFD', 'IN-HOUSE-1','IN-HOUSE-2', 'IN-HOUSE-3','CG', 'HapMap','Wellderly', 'ExAC');

	map{
    	my ($af_df, $db_af_threshold) = ($1, $2) if /\s?(\w+)\s?<=\s?(\S+)\s?/;
	    $db_filters{$af_df} = $db_af_threshold;
	}(split /,/, $configs{'db_threshold'});

	my (%sample_ques, @sample_ques_adjs);
	my (@uhead_samples, @head_sample_names, %cgenes, %mgenes, %gs, %sgt);

	open VCF, "$family_vcf" or die $!;

	open OT, ">$out_dir/$out_file.tsv" or die $!;
	open CHOT, ">$out_dir/$out_file.comphet.c.tsv" or die $!;
	open MOT, ">$out_dir/$out_file.comphet.m.tsv" or die $!;

	my ($i, %ssite, %gcount, %gselected,  %sgene, %genes, %trs);

	my $vep_key;
	while(<VCF>){
    	chomp;
	    $vep_key = $1 if /##INFO=\<ID=CSQ,Number=\.,Type=String,Description="Consequence type as predicted by VEP\. Format: (\S+)"\>/;
	    next if /^##/;
		    @header = (split /\t/) if /^#/;
    @sampleNames = @header[9..$#header] if /^#/;
    my (@head_samples, @unknown_samples, @ques_raws, @que_unknowns) = ((),());

    map{
        unshift @head_samples, "$samples{$_}->{phenotype}-$_" if $samples{$_}->{phenotype} eq 'case' or $samples{$_}->{phenotype} =~ /\wP/;
        unshift @ques_raws, "$_" if $samples{$_}->{phenotype} eq 'case' or $samples{$_}->{phenotype} =~ /\wP/;
        push @head_samples, "$samples{$_}->{phenotype}-$_" if $samples{$_}->{phenotype} eq 'control' or $samples{$_}->{phenotype} =~ /\wC/;
        push @ques_raws, "$_" if $samples{$_}->{phenotype} eq 'control' or $samples{$_}->{phenotype} =~ /\wC/;
        push @unknown_samples, "$samples{$_}->{phenotype}-$_" if $samples{$_}->{phenotype} eq 'unknown' or $samples{$_}->{phenotype} =~ /\wU/;
        push @que_unknowns, "$_" if $samples{$_}->{phenotype} eq 'unknown' or $samples{$_}->{phenotype} =~ /\wU/;

    }@sampleNames;
    push @head_samples, @unknown_samples;
    push @ques_raws, @que_unknowns;

    my @detail_head_samples;
    map{push @detail_head_samples, "detail-$_";}(@head_samples);
    @head_sample_names = (@detail_head_samples, @head_samples);
    @uhead_samples = @head_samples;

    my $que_id = 0;
    map{$sample_ques{$_} = $que_id; $que_id ++;}@sampleNames if /^#/;
    map{$sample_ques_adjs[$_] = $sample_ques{$ques_raws[$_]};}(0..$#ques_raws) if /^#/;

}

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
