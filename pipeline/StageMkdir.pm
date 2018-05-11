package DisGen::pipeline::StageMkdir;

sub byFSC{
#	($out_dir, $version, $sample_id, $family_id, \%lanes)
	my ($out_dir, $version, $sample_id, $family_id, $ref2lane) = @_;
	my %lanes = %$ref2lane;
    `mkdir -p $out_dir/$family_id/0.sh.e.o` unless -e "$out_dir/$family_id/0.sh.e.o";
    `mkdir -p $out_dir/$family_id/1.individual` unless -e "$out_dir/$family_id/1.individual";
    `mkdir -p $out_dir/$family_id/2.variant` unless -e "$out_dir/$family_id/2.variant";
    `mkdir -p $out_dir/$family_id/3.annotation` unless -e "$out_dir/$family_id/3.annotation";
    `mkdir -p $out_dir/$family_id/4.candidate` unless -e "$out_dir/$family_id/4.candidate";
    `mkdir -p $out_dir/$family_id/5.others` unless -e "$out_dir/$family_id/5.others";
    `mkdir -p $out_dir/$sample_id/$version/1.alignment` unless -e "$out_dir/$sample_id/$version/1.alignment";
    `mkdir -p $out_dir/$sample_id/$version/2.variant` unless -e "$out_dir/$sample_id/$version/2.variant";
    `mkdir -p $out_dir/$sample_id/$version/2.variant/1.SNV-InDel` unless -e "$out_dir/$sample_id/$version/2.variant/1.SNV-InDel";
    `mkdir -p $out_dir/$sample_id/$version/2.variant/2.CNV` unless -e "$out_dir/$sample_id/$version/2.variant/2.CNV";
    `mkdir -p $out_dir/$sample_id/$version/2.variant/3.SV` unless -e "$out_dir/$sample_id/$version/2.variant/3.SV";
    `mkdir -p $out_dir/$sample_id/$version/2.variant/4.exogenousDNA` unless -e "$out_dir/$sample_id/$version/2.variant/4.exogenousDNA";
    `mkdir -p $out_dir/$sample_id/$version/3.annotation` unless -e "$out_dir/$sample_id/$version/3.annotation";
    `mkdir -p $out_dir/$sample_id/$version/3.annotation/1.coding` unless -e "$out_dir/$sample_id/$version/3.annotation/1.coding";
    `mkdir -p $out_dir/$sample_id/$version/3.annotation/2.noncoding` unless -e "$out_dir/$sample_id/$version/3.annotation/2.noncoding";
    `mkdir -p $out_dir/$sample_id/$version/3.annotation` unless -e "$out_dir/$sample_id/$version/3.annotation";
    `mkdir -p $out_dir/$sample_id/$version/4.others/1.ROH` unless -e "$out_dir/$sample_id/$version/4.others/1.ROH";
    `mkdir -p $out_dir/$sample_id/$version/4.others/2.SHP` unless -e "$out_dir/$sample_id/$version/4.others/2.SHP";
    `mkdir -p $out_dir/$sample_id/$version/4.others/3.Minimal-Intron` unless -e "$out_dir/$sample_id/$version/4.others/3.Minimal-Intron";
    `mkdir -p $out_dir/$sample_id/$version/4.others/4.exon-deletion` unless -e "$out_dir/$sample_id/$version/4.others/4.exon-deletion";
    `mkdir -p $out_dir/$sample_id/$version/4.others/5.SRinversion` unless -e "$out_dir/$sample_id/$version/4.others/5.SRinversion";
    `mkdir -p $out_dir/$sample_id/$version/4.others/6.MHC` unless -e "$out_dir/$sample_id/$version/4.others/6.MHC";

    `mkdir -p $out_dir/$sample_id/$version/0.temp` unless -e "$out_dir/$sample_id/$version/0.temp";
    `mkdir -p $out_dir/$sample_id/$version/0.temp/2.sample/sh.e.o` unless -e "$out_dir/$sample_id/$version/0.temp/2.sample/sh.e.o";
    `mkdir -p $out_dir/$sample_id/$version/0.temp/2.sample/result` unless -e "$out_dir/$sample_id/$version/0.temp/2.sample/result";
    `mkdir -p $out_dir/$sample_id/$version/0.temp/2.sample/result/ROH` unless -e "$out_dir/$sample_id/$version/0.temp/2.sample/result/ROH";
    `mkdir -p $out_dir/$sample_id/$version/0.temp/2.sample/result/Stat/StatByChr` unless -e "$out_dir/$sample_id/$version/0.temp/2.sample/result/Stat/StatByChr";
    `mkdir -p $out_dir/$sample_id/$version/0.temp/2.sample/ByChr` unless -e "$out_dir/$sample_id/$version/0.temp/2.sample/ByChr";

    map{
        `mkdir -p $out_dir/$sample_id/$version/0.temp/2.sample/ByChr/chr$_` unless -e "$out_dir/$sample_id/$version/0.temp/2.sample/ByChr/chr$_";
        `mkdir -p $out_dir/$sample_id/$version/0.temp/2.sample/ByChr/chr$_/Stat` unless -e "$out_dir/$sample_id/$version/0.temp/2.sample/ByChr/chr$_/Stat";
    }(1..22,"X","Y","M");

    foreach my $slane (keys %lanes){
        my $i;
        map{
            $i ++;
            my $lane = "${slane}_$i";
            `mkdir -p $out_dir/$sample_id/$version/0.temp/1.lane/$lane` unless -e "$out_dir/$sample_id/$version/0.temp/1.lane/$lane";
            `mkdir -p $out_dir/$sample_id/$version/0.temp/1.lane/$lane/sh.e.o` unless -e "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/sh.e.o";
            `mkdir -p $out_dir/$sample_id/$version/0.temp/1.lane/$lane/cleanFQ` unless -e "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/cleanFQ";
            `mkdir -p $out_dir/$sample_id/$version/0.temp/1.lane/$lane/cleanFQ/SOAPnuke` unless -e "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/cleanFQ/SOAPnuke";
            `mkdir -p $out_dir/$sample_id/$version/0.temp/1.lane/$lane/alignment` unless -e "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/alignment";
            `mkdir -p $out_dir/$sample_id/$version/0.temp/1.lane/$lane/alignment/bwa_mem` unless -e "$out_dir/$sample_id/$version/0.temp/1.lane/$lane/alignment/bwa_mem";
        }(split /;/, $lanes{$slane}{FQs});
    }

}

1;
