package DisGen::pipeline::GVCF2;

sub vcf {
    my ($tool, $ref_version, $input_gvcf_list, $out_file_prefix, $out_dir, $region) = @_;
    my ($bed, $cmd);


    $bed = "-L $region" if -e $region; # if region is WGS, -L argument is not need
    if($tool =~ /gatk3/i){

	    if ($ref_version =~ /hg19|GRCh37/i){
		    $cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} -T GenotypeGVCFs -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta $input_gvcf_list -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.gatkHC.vcf --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/dbsnp_138.hg19.vcf -stand_call_conf 30.0 -stand_emit_conf 10.0 $bed";

	    }elsif($ref_version =~ /hg38|GRCh38/i){
		    $cmd = "$DisGen::general::Resource::_wftool_{java} -Xmx10g -Djava.io.tmpdir=`pwd`/tmp -jar $DisGen::general::Resource::_wftool_{gatk3} GenotypeGVCFs -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta $input_gvcf_list -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -o $out_dir/$out_file_prefix.gatkHC.vcf --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -stand_call_conf 30.0 -stand_emit_conf 10.0 $bed";
		}

	}elsif($tool =~ /gatk4/i){
    	if ($ref_version =~ /hg19|GRCh37/i){
        	$cmd = "$DisGen::general::Resource::_wftool_{gatk4} GenotypeGVCFs -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta $input_gvcf_list -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.gatkHC.vcf --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf $bed";

	    }elsif($ref_version =~ /hg38|GRCh38/i){
    	    $cmd = "$DisGen::general::Resource::_wftool_{gatk4} GenotypeGVCFs -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta $input_gvcf_list -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.gatkHC.vcf --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf $bed";
	    }
	}
	return ($cmd);
}

sub multi_sample_gvcf {
    my ($tool, $ref_version, $input_gvcf_list, $out_file_prefix, $out_dir, $region) = @_;
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
            $cmd = "$DisGen::general::Resource::_wftool_{gatk4} CombineGVCFs -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg19}/ucsc.hg19.fasta $input_gvcf_list -O $out_dir/$out_file_prefix.g.vcf $bed";

        }elsif($ref_version =~ /hg38|GRCh38/i){
            $cmd = "$DisGen::general::Resource::_wftool_{gatk4} HaplotypeCaller -R $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/Homo_sapiens_assembly38.fasta -I $input_gvcf_list -ERC GVCF --dbsnp $DisGen::general::Resource::_wfdata_{gatk_bundle_hg38}/dbsnp_146.hg38.vcf -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -O $out_dir/$out_file_prefix.g.vcf $bed";
        }
    }
    return ($cmd);
}
1;
