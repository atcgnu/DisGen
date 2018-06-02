package DisGen::pipeline::VCF2;

sub vepVCF {
    my ($tool, $ref_version, $input_vcf, $out_file_prefix, $out_dir) = @_;
    my $cmd;

	if($tool =~ /vep91/i){
		$vep = $DisGen::general::Resource::_wftool_{VEP91};
		$cache = $DisGen::general::Resource::_wfdata_{vep91cache};
	}elsif($tool =~ /vep77/i){
		$vep = $DisGen::general::Resource::_wftool_{VEP77};
		$cache = $DisGen::general::Resource::_wfdata_{vep77cache};
	}

	if($ref_version =~ /hg19|GRCh37/i){
		$cmd = "export PERL5LIB=$DisGen::general::Resource::env_vars{PERL5LIB} && export PATH=$DisGen::general::Resource::env_vars{PATH} && $DisGen::general::Resource::_wftool_{perl} $vep -i $input_vcf -o $out_dir/$out_file_prefix.VEP.vcf --offline --dir_cache $cache --vcf --merged --force_overwrite --quiet --fork 10 --hgvs --assembly GRCh37 --everything";
	}elsif($ref_version =~ /hg38|GRCh38/i){
		$cmd = "export PERL5LIB=$DisGen::general::Resource::env_vars{PERL5LIB} && export PATH=$DisGen::general::Resource::env_vars{PATH} && $DisGen::general::Resource::_wftool_{perl} $vep -i $input_vcf -o $out_dir/$out_file_prefix.VEP.vcf --offline --dir_cache $cache --vcf --merged --force_overwrite --quiet --fork 10 --hgvs --assembly GRCh38 --everything";
	}

	return ($cmd);
}

sub unionVCF {
# merge vcfs of one sample with difference caller to a single vcf
	my ($tool, $input_call_result_list, $out_file_prefix, $out_dir, $bed) = @_;
	my $cmd;

	$cmd = "$DisGen::general::Resource::_wftool_{union_vcf} $bed $input_call_result_list > $out_dir/$out_file_prefix.vcf";

	return ($cmd);
}

sub cohortVCF {
# merge vcfs of difference sample to a single vcf
#
}

1;
