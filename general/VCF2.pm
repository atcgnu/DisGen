#!/use/bin/perl
#
package DisGen::general::VCF2;
use DisGen::general::MakeOpen;
use DisGen::general::GenotypeCount;
use DisGen::general::Cosegregation;
use DisGen::general::OtherDatabase;
use DisGen::general::AlleleFrequency;
use DisGen::general::ComputationalData;

sub CosegregationTSV{
    my ($vcf, $sig_chr, $out_dir, $out_file, $ref_samples) = @_;
	my %samples = %$ref_samples;
	my @sampleNames;
    open VCF, "$vcf" or die $!;
	open OTMH, "> $out_dir/Cosegregation.monoplace.header.tsv" or die $!;
	open OTM, "> $out_dir/$out_file.Cosegregation.monoplace.tsv" or die $!;
#	open OTB, "> $out_dir/$out_file.Cosegregation.biplace.tsv" or die $!;
#	open OTG, "> $out_dir/$out_file.Cosegregation.genelevel.tsv" or die $!;


	while(<VCF>){
        chomp;
		next if /^##/;
		my $gt_info;

		if (/^#/){
			my @header = (split /\t/);
		    @sampleNames = @header[9..$#header];
			my $sample_header;
			map{
				$sample_header .= "\t$_";
			}(@sampleNames);
			print OTMH "#key\tAD\tAR\tXL$sample_header\n";

#	    	my (@head_samples, @unknown_samples, @ques_raws, @que_unknowns) = ((),());
	
#			map{
#		        unshift @head_samples, "$samples{$_}->{phenotype}-$_" if $samples{$_}->{phenotype} eq 'case' or $samples{$_}->{phenotype} =~ /\wP/; # case first
#    		    unshift @ques_raws, "$_" if $samples{$_}->{phenotype} eq 'case' or $samples{$_}->{phenotype} =~ /\wP/; # case first
#        		push @head_samples, "$samples{$_}->{phenotype}-$_" if $samples{$_}->{phenotype} eq 'control' or $samples{$_}->{phenotype} =~ /\wC/; # control follow case
#		        push @ques_raws, "$_" if $samples{$_}->{phenotype} eq 'control' or $samples{$_}->{phenotype} =~ /\wC/; # control follow case
#    		    push @unknown_samples, "$samples{$_}->{phenotype}-$_" if $samples{$_}->{phenotype} eq 'unknown' or $samples{$_}->{phenotype} =~ /\wU/; # unknown at the end
#        		push @que_unknowns, "$_" if $samples{$_}->{phenotype} eq 'unknown' or $samples{$_}->{phenotype} =~ /\wU/; # unknown at the end
#		    }@sampleNames;

#		    push @head_samples, @unknown_samples;
#    		push @ques_raws, @que_unknowns;		

#	    	my $que_id = 0;
#		    map{$sample_ques{$_} = $que_id; $que_id ++;}@sampleNames;
#    		map{$sample_ques_adjs[$_] = $sample_ques{$ques_raws[$_]};}(0..$#ques_raws);
		}else{
			my ($chr, $pos, $rs, $ref, $alt, $qua, $filter, $info, $format, @sample_infos) = (split /\t/);
			$chr =~ s/chr//;
			next unless $chr eq $sig_chr;

			my $is_nocall = 'N';

			my @ks = (split /:/, $format);
			
			foreach my $index (0..$#sampleNames){
				$sample_infos[$index] =~ s/'//g;
				my @vs = (split /:/, $sample_infos[$index]);
		        my %tag;
        		map{$tag{$ks[$_]} = $vs[$_] if $vs[$_]}(0..$#ks);
				$gt_info .= "\t'$tag{'GT'}'";
		        $samples{$sampleNames[$index]}->{GT} = $tag{'GT'};

		        $samples{$sampleNames[$index]}->{GT} = '0/0' if $tag{'GT'} eq './.' or $tag{'GT'} eq '.|.';
        		$samples{$sampleNames[$index]}->{GT} = '0/0' if $tag{'GT'} eq '.' ;
		        $samples{$sampleNames[$index]}->{GT} = '1/1' if $tag{'GT'} eq '1' ;
        		$samples{$sampleNames[$index]}->{GT} = '0/0' if $tag{'GT'} eq '0/.' or $tag{'GT'} eq '0|.';
		        $samples{$sampleNames[$index]}->{GT} = '1/0' if $tag{'GT'} eq '1/.' or $tag{'GT'} eq '1|.';
        		$samples{$sampleNames[$index]}->{GT} = '2/0' if $tag{'GT'} eq '2/.' or $tag{'GT'} eq '2|.';

		        $is_nocall = 'Y' if $tag{'GT'} eq '.' or $tag{'GT'} eq './.' or $tag{'GT'} eq '.|.' or $tag{'GT'} eq '0/.' or $tag{'GT'} eq '0|.' or $tag{'GT'} eq '1/.' or $tag{'GT'} eq '1|.' or $tag{'GT'} eq './1' or $tag{'GT'} eq '.|1' or $tag{'GT'} eq '2/.' or $tag{'GT'} eq '2|.' or $tag{'GT'} eq './2' or $tag{'GT'} eq '.|2' or $tag{'GT'} eq '3/.' or $tag{'GT'} eq '3|.' or $tag{'GT'} eq './3' or $tag{'GT'} eq '.|3';
			}
			
			my ($ad_flag, $ar_flag, $xls_flag) = DisGen::general::Cosegregation::monoplace(\@sampleNames, \%samples, $chr, $is_nocall);
#			print OTM "chr$chr\t$pos\t$ref\t$alt\t$ad_flag\t$ar_flag\t$xls_flag\t$gt_info\n";
			print OTM "$chr:$pos:$ref:$alt\t$ad_flag\t$ar_flag\t$xls_flag\t$gt_info\n";
		}

	}
	close VCF;

}

sub PopulationDataTSV{
	my ($vcf, $sig_chr, $out_dir, $out_file) = @_;
	open VCF, "$vcf" or die $!;
	open OTAF, "> $out_dir/PopulationData.AF.header.tsv" or die $!;
	open OTAF, "> $out_dir/$out_file.PopulationData.AF.tsv" or die $!;
	open OTGC, "> $out_dir/PopulationData.GC.header.tsv" or die $!;
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
	$ref_version ||= 'hg19';
    open VCF, "$vcf" or die $!;
    open OTALH, "> $out_dir/ComputationalData.AL.header.tsv" or die $!;
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
sub OtherDatabaseTSV{
    my ($vcf, $sig_chr, $out_dir, $out_file, $ref_version) = @_;
	$ref_version ||= 'hg19';
    open VCF, "$vcf" or die $!;
    open OTH, "> $out_dir/OtherDatabase.header.tsv" or die $!;
    open OT, "> $out_dir/$out_file.OtherDatabase.tsv" or die $!;
    while(<VCF>){
        chomp;
        next if /^#/;
        my ($chr, $pos, $rs, $ref, $alt) = (split /\t/)[0,1,2,3,4];
        $chr =~ s/chr//;
        next unless $chr eq $sig_chr;
        foreach my $allele (split /,/, $alt){
            my ($al_info);
            my ($ref_query_results) = DisGen::general::OtherDatabase::get_all($chr, $pos, $ref, $allele, $ref_version);
            my @query_results = @$ref_query_results;
            $al_info = join "\t", @query_results;
            print OT "$al_info\n" unless $al_info =~ /^$/;
        }
    }
    close OTAL;

}

1;
