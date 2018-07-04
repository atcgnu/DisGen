#!/use/bin/perl
#
package DisGen::general::VCF2SQL;
use DisGen::general::MakeOpen;
use DisGen::general::GenotypeInfo;
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
	open OTMT, "> $out_dir/Cosegregation.monoplace.tail.tsv" or die $!;
	open OTM, "> $out_dir/$out_file.Cosegregation.monoplace.tsv" or die $!;

	my $table = "t_sg";
	my @col;
	while(<VCF>){
        chomp;
		next if /^##/;
		my $gt_info;

		if (/^#/){
			my @header = (split /\t/);
		    @sampleNames = @header[9..$#header];
			map{
				s/-/_/g;
			}(@sampleNames);

			@col = ('key', 'chr', 'pos', 'rs', 'ref', 'alt', 'ad', 'ar', 'xl', @sampleNames);
			my %field;

			map{
		        $field{$col[$_]} = "$col[$_] varchr (50)";
			}(0..$#col);


			my @field = map{$field{$_}}@col;
			print OTMH "CREATE TABLE $table (".(join ",",@field).");\nBEGIN;\n";

		}else{
			my ($chr, $pos, $rs, $ref, $alt, $qua, $filter, $info, $format, @sample_infos) = (split /\t/);
			$chr =~ s/chr//;
			next unless $chr eq $sig_chr;

			my $is_nocall = 'N';

			my @ks = (split /:/, $format);
			
			my @gt_infos;

			foreach my $index (0..$#sampleNames){
				$sample_infos[$index] =~ s/'//g;
				my @vs = (split /:/, $sample_infos[$index]);
		        my %tag;
        		map{$tag{$ks[$_]} = $vs[$_] if $vs[$_]}(0..$#ks);
				$gt_info .= "\t'$tag{'GT'}'";
				push @gt_infos, $tag{'GT'};
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
			my @line = ("$chr:$pos:$ref:$alt", $chr, $pos, $rs, $ref, $alt, $ad_flag, $ar_flag, $xls_flag, @gt_infos);
			my @out =map{"\'$_\'"}@line;
	        print OTM "insert into $table values (".(join ",",@out).");\n";
		}

	}
	print OTMT "COMMIT;\n";
	print OTMT "create index $table\_index on $table($col[0]);";
	close OTMH;
	close OTM;
	close OTMT;

	close VCF;
}

sub PopulationDataTSV{
	my ($vcf, $sig_chr, $out_dir, $out_file) = @_;
	open VCF, "$vcf" or die $!;
	open OTAFH, "> $out_dir/PopulationData.AF.header.tsv" or die $!;
	open OTAFT, "> $out_dir/PopulationData.AF.tail.tsv" or die $!;
	open OTAF, "> $out_dir/$out_file.PopulationData.AF.tsv" or die $!;
	open OTGCH, "> $out_dir/PopulationData.GC.header.tsv" or die $!;
	open OTGCT, "> $out_dir/PopulationData.GC.tail.tsv" or die $!;
	open OTGC, "> $out_dir/$out_file.PopulationData.GC.tsv" or die $!;
	open OTGIH, "> $out_dir/PopulationData.GI.header.tsv" or die $!;
	open OTGIT, "> $out_dir/PopulationData.GI.tail.tsv" or die $!;
	open OTGI, "> $out_dir/$out_file.PopulationData.GI.tsv" or die $!;

    my $table_af = "t_af";
    my $table_gc = "t_gc";
    my $table_gi = "t_gi";
    my @col_af = ('key37', 'chr', 'pos', 'end', 'ref', 'allele', 'var_type', 'rs', 'dbnum_005', 'db_005', 'dbnum_01', 'db_01', 'dbnum_05', 'db_05', 'ESP6500_AC', 'ESP6500_AF', 'ESP6500_EA_AC', 'ESP6500_EA_AF', 'ESP6500_AA_AC', 'ESP6500_AA_AF', 'Gp3_1000_AC', 'Gp3_1000_AF', 'Gp3_1000_EAS_AF', 'Gp3_1000_AMR_AF', 'Gp3_1000_AFR_AF', 'Gp3_1000_EUR_AF', 'Gp3_1000_SAS_AF', 'ExAC_AC', 'ExAC_AF', 'ExAC_AFR_AC', 'ExAC_AFR_AF', 'ExAC_AMR_AC', 'ExAC_AMR_AF', 'ExAC_Adj_AC', 'ExAC_Adj_AF', 'ExAC_EAS_AC', 'ExAC_EAS_AF', 'ExAC_FIN_AC', 'ExAC_FIN_AF', 'ExAC_NFE_AC', 'ExAC_NFE_AF', 'ExAC_OTH_AC', 'ExAC_OTH_AF', 'ExAC_SAS_AC', 'ExAC_SAS_AF', 'MDD_12000_AC', 'MDD_12000_AF', 'Kaviar_AC', 'Kaviar_AF', 'gnomAD_exomes_AC', 'gnomAD_exomes_AF', 'gnomAD_exomes_AFR_AC', 'gnomAD_exomes_AFR_AF', 'gnomAD_exomes_AMR_AC', 'gnomAD_exomes_AMR_AF', 'gnomAD_exomes_ASJ_AC', 'gnomAD_exomes_ASJ_AF', 'gnomAD_exomes_EAS_AC', 'gnomAD_exomes_EAS_AF', 'gnomAD_exomes_FIN_AC', 'gnomAD_exomes_FIN_AF', 'gnomAD_exomes_NFE_AC', 'gnomAD_exomes_NFE_AF', 'gnomAD_exomes_SAS_AC', 'gnomAD_exomes_SAS_AF', 'gnomAD_exomes_OTH_AC', 'gnomAD_exomes_OTH_AF', 'gnomAD_genome_AC', 'gnomAD_genome_AF', 'gnomAD_genome_AFR_AC', 'gnomAD_genome_AFR_AF', 'gnomAD_genome_AMR_AC', 'gnomAD_genome_AMR_AF', 'gnomAD_genome_ASJ_AC', 'gnomAD_genome_ASJ_AF', 'gnomAD_genome_EAS_AC', 'gnomAD_genome_EAS_AF', 'gnomAD_genome_FIN_AC', 'gnomAD_genome_FIN_AF', 'gnomAD_genome_NFE_AC', 'gnomAD_genome_NFE_AF', 'gnomAD_genome_SAS_AC', 'gnomAD_genome_SAS_AF', 'gnomAD_genome_OTH_AC', 'gnomAD_genome_OTH_AF', 'SISI_cg_AC', 'SISI_cg_AF', 'SISI_illumina_AC', 'SISI_illumina_AF');
    my @col_gc = ('key', 'chr', 'pos', 'count', 'case_num', 'zygosity', 'genotype', 'gender', 'affected_status');
    my @col_gi = ('key37', 'kg_all_gtc', 'kg_afr_gtc', 'kg_amr_gtc', 'kg_eas_gtc', 'kg_eur_gtc', 'kg_sas_gtc', 'esp_all_gtc', 'esp_ea_gtc', 'esp_aa_gtc', 'stsi_illumina_gtc', 'stsi_cg_gtc', 'gnomad_genome_afr_gtc', 'gnomad_genome_amr_gtc', 'gnomad_genome_asj_gtc', 'gnomad_genome_eas_gtc', 'gnomad_genome_fin_gtc', 'gnomad_genome_nfe_gtc', 'gnomad_genome_oth_gtc', 'gnomad_genome_raw_gtc', 'gnomad_genome_all_gtc', 'gnomad_exome_afr_gtc', 'gnomad_exome_amr_gtc', 'gnomad_exome_asj_gtc', 'gnomad_exome_eas_gtc', 'gnomad_exome_fin_gtc', 'gnomad_exome_nfe_gtc', 'gnomad_exome_oth_gtc', 'gnomad_exome_sas_gtc', 'gnomad_exome_male_gtc', 'gnomad_exome_female_gtc', 'gnomad_exome_raw_gtc', 'gnomad_exome_all_gtc');

	my (%field_af, %field_gc, %field_gi);

	map{
        $field_af{$col_af[$_]} = "$col_af[$_] varchr (50)";
    }(0..$#col_af);

	map{
        $field_gc{$col_gc[$_]} = "$col_gc[$_] varchr (50)";
    }(0..$#col_gc);

	map{
        $field_gi{$col_gi[$_]} = "$col_gi[$_] varchr (50)";
    }(0..$#col_gi);

    my @field_af = map{$field_af{$_}}@col_af;
    my @field_gc = map{$field_gc{$_}}@col_gc;
    my @field_gi = map{$field_gi{$_}}@col_gi;

    print OTAFH "CREATE TABLE $table_af (".(join ",",@field_af).");\nBEGIN;\n";
    print OTGCH "CREATE TABLE $table_gc (".(join ",",@field_gc).");\nBEGIN;\n";
    print OTGIH "CREATE TABLE $table_gi (".(join ",",@field_gi).");\nBEGIN;\n";

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
#			print OTGC "$chr:$pos:$ref:$allele\t$gc_info\n";
#####
            my @line_gc = (@dbcase_query_results);
            my @out_gc =map{"\'$_\'"}@line_gc;
            print OTGC "insert into $table_gc values (".(join ",",@out_gc).");\n" unless $gc_info =~ /^\./ or $gc_info =~ /^$/;
#####
			my ($temp_v_snv_num, $temp_v_indel_num, $ref_dbpp_query_results) = DisGen::general::AlleleFrequency::get_all_af($chr, $pos, $ref, $allele);
        	my @dbpp_query_results = @$ref_dbpp_query_results;
	        $pd_info = join "\t", @dbpp_query_results;	
#			print OTAF "$pd_info\n";
#########
            my @line_af = @$ref_dbpp_query_results;
            my @out_af =map{"\'$_\'"}@line_af;
            print OTAF "insert into $table_af values (".(join ",",@out_af).");\n" unless $pd_info =~ /^$/;
#########
			my ($ref_dbhom_query_results) = DisGen::general::GenotypeInfo::get_hom_all($chr, $pos, $ref, $allele);
        	my @dbhom_query_results = @$ref_dbhom_query_results;
	        $gi_info = join "\t", @dbhom_query_results;	
#			print OTGI "$gi_info\n" unless $gi_info =~ /^\./ or $gi_info =~ /^$/;
######
            my @line_gi = @$ref_dbhom_query_results;
            my @out_gi =map{"\'$_\'"}@line_gi;
            print OTGI "insert into $table_gi values (".(join ",",@out_gi).");\n" unless $gi_info =~ /^\./ or $gi_info =~ /^$/;
		}
	}
	close VCF;
	print OTAFT "COMMIT;\n";
	print OTAFT "create index $table_af\_index on $table_af($col_af[0]);";
	print OTGCT "COMMIT;\n";
	print OTGCT "create index $table_gc\_index on $table_gc($col_gc[0]);";
	print OTGIT "COMMIT;\n";
	print OTGIT "create index $table_gi\_index on $table_gi($col_gi[0]);";
}

sub ComputationalDataTSV{
	my ($vcf, $sig_chr, $out_dir, $out_file, $ref_version) = @_;
	$ref_version ||= 'hg19';
    open VCF, "$vcf" or die $!;
    open OTALH, "> $out_dir/ComputationalData.AL.header.tsv" or die $!;
    open OTALT, "> $out_dir/ComputationalData.AL.tail.tsv" or die $!;
    open OTAL, "> $out_dir/$out_file.ComputationalData.AL.tsv" or die $!;

    my $table_al = "t_al";
    my @col_al = ('key38', 'key37', 'aaref', 'aaalt', 'rs_dbsnp', 'damagetools', 'SIFT_score', 'SIFT_converted_rankscore', 'SIFT_pred', 'Polyphen2_HDIV_score', 'Polyphen2_HDIV_rankscore', 'Polyphen2_HDIV_pred', 'Polyphen2_HVAR_score', 'Polyphen2_HVAR_rankscore', 'Polyphen2_HVAR_pred', 'LRT_score', 'LRT_converted_rankscore', 'LRT_pred', 'MutationTaster_score', 'MutationTaster_converted_rankscore', 'MutationTaster_pred', 'MutationAssessor_score', 'MutationAssessor_rankscore', 'MutationAssessor_pred', 'FATHMM_score', 'FATHMM_converted_rankscore', 'FATHMM_pred', 'PROVEAN_score', 'PROVEAN_converted_rankscore', 'PROVEAN_pred', 'MetaSVM_score', 'MetaSVM_rankscore', 'MetaSVM_pred', 'MetaLR_score', 'MetaLR_rankscore', 'MetaLR_pred', 'M_CAP_score', 'M_CAP_rankscore', 'M_CAP_pred', 'CADD_raw', 'CADD_raw_rankscore', 'CADD_phred', 'fathmm_MKL_coding_score', 'fathmm_MKL_coding_rankscore', 'fathmm_MKL_coding_pred');

    my (%field_al);

    map{
        $field_al{$col_al[$_]} = "$col_al[$_] varchr (50)";
    }(0..$#col_al);

    my @field_al = map{$field_al{$_}}@col_al;

    print OTALH "CREATE TABLE $table_al (".(join ",",@field_al).");\nBEGIN;\n";

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
            my @line_al = @$ref_query_results;
            my @out_al =map{"\'$_\'"}@line_al;
            print OTAL "insert into $table_al values (".(join ",",@out_al).");\n" unless $al_info =~ /^$/;
		}
	}
	print OTALT "COMMIT;\n";
	print OTALT "create index $table_al\_index on $table_al($col_al[1]);";
	close OTALH;
	close OTALT;
	close OTAL;
}

sub FunctionalDataTSV{}

sub OtherDatabaseTSV{
    my ($vcf, $sig_chr, $out_dir, $out_file, $ref_version) = @_;
	$ref_version ||= 'hg19';
    open VCF, "$vcf" or die $!;
    open OTODH, "> $out_dir/OtherDatabase.header.tsv" or die $!;
    open OTODT, "> $out_dir/OtherDatabase.tail.tsv" or die $!;
    open OTOD, "> $out_dir/$out_file.OtherDatabase.tsv" or die $!;

	my $table_od = "t_od";
    my @col_od = ('alleleid', 'variantid', 'varianttype', 'omim', 'key37', 'key38', 'zygosity', 'gene', 'transcript', 'clinvar_alleleid', 'clinvar_variantid', 'clinvar_clinicalsignificance', 'hgmd_acc_num', 'hgmdclass', 'pmid');

    my (%field_od);

    map{
        $field_od{$col_od[$_]} = "$col_od[$_] varchr (50)";
    }(0..$#col_od);

    my @field_od = map{$field_od{$_}}@col_od;

    print OTODH "CREATE TABLE $table_od (".(join ",",@field_od).");\nBEGIN;\n";

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
#            print OTOD "$al_info\n" unless $al_info =~ /^$/;

            my $od_info = join "\t", @query_results;
            my @line_od = @$ref_query_results;
            my @out_od =map{"\'$_\'"}@line_od;
            print OTOD "insert into $table_od values (".(join ",",@out_od).");\n" unless $od_info =~ /^$/;
        }
    }
	print OTODT "COMMIT;\n";
	print OTODT "create index $table_od\_index on $table_od($col_od[1]);";
    close OTODH;
    close OTODT;
    close OTOD;

}

1;
