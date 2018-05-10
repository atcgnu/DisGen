package DisGen::pipeline::StageMkdir;

sub byS{
	my ($outDir, $version, $sampleName, $familyID, $ref2lane) = @_;
	my %lanes = %$ref2lane;
    `mkdir -p $outDir/$sampleName/$version/1.alignment` unless -e "$outDir/$sampleName/$version/sample/result";
    `mkdir -p $outDir/$sampleName/$version/2.variant` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/2.variant/1.SNV-InDel` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/2.variant/2.CNV` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/2.variant/3.SV` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/2.variant/4.exogenousDNA` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/3.annotation` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/3.annotation/1.coding` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/3.annotation/2.noncoding` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/3.annotation` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/4.others/1.ROH` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/4.others/2.SHP` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/4.others/3.Minimal-Intron` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/4.others/4.exon-deletion` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/4.others/5.SRinversion` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/4.others/6.MHC` unless -e "$outDir/$sampleName/$version/sample/result/ROH";

    `mkdir -p $outDir/$sampleName/$version/0.temp` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/0.temp/sample/sh.e.o` unless -e "$outDir/$sampleName/$version/sample/sh.e.o";
    `mkdir -p $outDir/$sampleName/$version/0.temp/sample/result` unless -e "$outDir/$sampleName/$version/sample/result";
    `mkdir -p $outDir/$sampleName/$version/0.temp/sample/result/ROH` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/0.temp/sample/result/Stat/StatByChr` unless -e "$outDir/$sampleName/$version/sample/result/SOAP_Stat/StatByChr";
    `mkdir -p $outDir/$sampleName/$version/0.temp/sample/ByChr` unless -e "$outDir/$sampleName/$version/sample/ByChr";

    map{
        `mkdir -p $outDir/$sampleName/$version/0.temp/sample/ByChr/chr$_` unless -e "$outDir/$sampleName/$version/sample/ByChr/chr$_";
        `mkdir -p $outDir/$sampleName/$version/0.temp/sample/ByChr/chr$_/Stat` unless -e "$outDir/$sampleName/$version/sample/ByChr/chr$_/BAM_Stat";
    }(1..22,"X","Y","M");

    foreach my $slane (keys %lanes){
        my $i;
        map{
            $i ++;
            my $lane = "${slane}_$i";
            `mkdir -p $outDir/$sampleName/$version/0.temp/lane/$lane` unless -e "$outDir/$sampleName/$version/lane/$lane";
            `mkdir -p $outDir/$sampleName/$version/0.temp/lane/$lane/sh.e.o` unless -e "$outDir/$sampleName/$version/lane/$lane/sh.e.o";
            `mkdir -p $outDir/$sampleName/$version/0.temp/lane/$lane/cleanFQ` unless -e "$outDir/$sampleName/$version/lane/$lane/cleanFQ";
            `mkdir -p $outDir/$sampleName/$version/0.temp/lane/$lane/cleanFQ/SOAPnuke` unless -e "$outDir/$sampleName/$version/lane/$lane/cleanFQ/SOAPnuke";
            `mkdir -p $outDir/$sampleName/$version/0.temp/lane/$lane/alignment` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment";
            `mkdir -p $outDir/$sampleName/$version/0.temp/lane/$lane/alignment/bwa_mem` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment/bwa_mem";
        }(split /;/, $lanes{$slane}{FQs});
    }

}


sub bySC {
    my ($outDir, $version, $sampleName, $familyID, %lanes) = @_;

    `mkdir -p $outDir/$sampleName/$version/sample/sh.e.o` unless -e "$outDir/$sampleName/$version/sample/sh.e.o";
    `mkdir -p $outDir/$sampleName/$version/sample/result` unless -e "$outDir/$sampleName/$version/sample/result";
    `mkdir -p $outDir/$sampleName/$version/sample/result/noncoding` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/sample/result/ROH` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/sample/result/BAM_Stat/StatByChr` unless -e "$outDir/$sampleName/$version/sample/result//BAM_Stat/StatByChr";
    `mkdir -p $outDir/$sampleName/$version/sample/result/SOAP_Stat/StatByChr` unless -e "$outDir/$sampleName/$version/sample/result/SOAP_Stat/StatByChr";
    `mkdir -p $outDir/$sampleName/$version/sample/ByChr` unless -e "$outDir/$sampleName/$version/sample/ByChr";

    map{
        `mkdir -p $outDir/$sampleName/$version/sample/ByChr/chr$_` unless -e "$outDir/$sampleName/$version/sample/ByChr/chr$_";
        `mkdir -p $outDir/$sampleName/$version/sample/ByChr/chr$_/BAM_Stat` unless -e "$outDir/$sampleName/$version/sample/ByChr/chr$_/BAM_Stat";
        `mkdir -p $outDir/$sampleName/$version/sample/ByChr/chr$_/SOAP_Stat` unless -e "$outDir/$sampleName/$version/sample/ByChr/chr$_/SOAP_Stat";
    }(1..22,"X","Y","M");

    foreach my $slane (keys %lanes){
        my $i;
        map{
            $i ++;
            my $lane = "${slane}_$i";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane` unless -e "$outDir/$sampleName/$version/lane/$lane";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/sh.e.o` unless -e "$outDir/$sampleName/$version/lane/$lane/sh.e.o";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/cleanFQ` unless -e "$outDir/$sampleName/$version/lane/$lane/cleanFQ";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/cleanFQ/SOAPnuke` unless -e "$outDir/$sampleName/$version/lane/$lane/cleanFQ/SOAPnuke";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/alignment` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/alignment/bwa_mem` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment/bwa_mem";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/alignment/SOAPaligner` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment/SOAPaligner";
        }(split /;/, $lanes{$slane}{FQs});
    }
}

sub byFS {
    my ($outDir, $version, $sampleName, $familyID, %lanes) = @_;
    open SH, "$outDir/mkdir.sh";

    `mkdir -p $outDir/$familyID/sh.e.o` unless -e "$outDir/$familyID/sh.e.o";
    `mkdir -p $outDir/$familyID/result` unless -e "$outDir/$familyID/result";
    `mkdir -p $outDir/$familyID/individual` unless -e "$outDir/$familyID/individual";
    `mkdir -p $outDir/$sampleName/$version/sample/sh.e.o` unless -e "$outDir/$sampleName/$version/sample/sh.e.o";
    `mkdir -p $outDir/$sampleName/$version/sample/result` unless -e "$outDir/$sampleName/$version/sample/result";
    `mkdir -p $outDir/$sampleName/$version/sample/result/noncoding` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/sample/result/ROH` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/sample/result/BAM_Stat/StatByChr` unless -e "$outDir/$sampleName/$version/sample/result//BAM_Stat/StatByChr";
    `mkdir -p $outDir/$sampleName/$version/sample/result/SOAP_Stat/StatByChr` unless -e "$outDir/$sampleName/$version/sample/result/SOAP_Stat/StatByChr";
    `mkdir -p $outDir/$sampleName/$version/sample/ByChr` unless -e "$outDir/$sampleName/$version/sample/ByChr";
    `ln -s $outDir/$sampleName $outDir/$familyID/individual/` unless -e "$outDir/$familyID/individual/$sampleName";

    foreach my $slane (keys %lanes){
        my $i;
        map{
            $i ++;
            my $lane = "${slane}_$i";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane` unless -e "$outDir/$sampleName/$version/lane/$lane";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/sh.e.o` unless -e "$outDir/$sampleName/$version/lane/$lane/sh.e.o";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/cleanFQ` unless -e "$outDir/$sampleName/$version/lane/$lane/cleanFQ";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/cleanFQ/SOAPnuke` unless -e "$outDir/$sampleName/$version/lane/$lane/cleanFQ/SOAPnuke";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/alignment` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/alignment/bwa_mem` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment/bwa_mem";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/alignment/SOAPaligner` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment/SOAPaligner";
        }(split /;/, $lanes{$slane}{FQs});
    }

}

sub byFSC {
    my ($outDir, $version, $sampleName, $familyID, %lanes) = @_;
    open SH, "$outDir/mkdir.sh";

    `mkdir -p $outDir/$familyID/sh.e.o` unless -e "$outDir/$familyID/sh.e.o";
    `mkdir -p $outDir/$familyID/result` unless -e "$outDir/$familyID/result";
    `mkdir -p $outDir/$familyID/individual` unless -e "$outDir/$familyID/individual";
    `mkdir -p $outDir/$sampleName/$version/sample/sh.e.o` unless -e "$outDir/$sampleName/$version/sample/sh.e.o";
    `mkdir -p $outDir/$sampleName/$version/sample/result` unless -e "$outDir/$sampleName/$version/sample/result";
    `mkdir -p $outDir/$sampleName/$version/sample/result/noncoding` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/sample/result/ROH` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/sample/result/BAM_Stat/StatByChr` unless -e "$outDir/$sampleName/$version/sample/result//BAM_Stat/StatByChr";
    `mkdir -p $outDir/$sampleName/$version/sample/result/SOAP_Stat/StatByChr` unless -e "$outDir/$sampleName/$version/sample/result/SOAP_Stat/StatByChr";
    `mkdir -p $outDir/$sampleName/$version/sample/ByChr` unless -e "$outDir/$sampleName/$version/sample/ByChr";
    `ln -s $outDir/$sampleName $outDir/$familyID/individual/` unless -e "$outDir/$familyID/individual/$sampleName";
    map{
        `mkdir -p $outDir/$sampleName/$version/sample/ByChr/chr$_` unless -e "$outDir/$sampleName/$version/sample/ByChr/chr$_";
        `mkdir -p $outDir/$sampleName/$version/sample/ByChr/chr$_/BAM_Stat` unless -e "$outDir/$sampleName/$version/sample/ByChr/chr$_/BAM_Stat";
        `mkdir -p $outDir/$sampleName/$version/sample/ByChr/chr$_/SOAP_Stat` unless -e "$outDir/$sampleName/$version/sample/ByChr/chr$_/SOAP_Stat";
    }(1..22,"X","Y","M");
    foreach my $slane (keys %lanes){
        my $i;
        map{
            $i ++;
            my $lane = "${slane}_$i";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane` unless -e "$outDir/$sampleName/$version/lane/$lane";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/sh.e.o` unless -e "$outDir/$sampleName/$version/lane/$lane/sh.e.o";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/cleanFQ` unless -e "$outDir/$sampleName/$version/lane/$lane/cleanFQ";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/cleanFQ/SOAPnuke` unless -e "$outDir/$sampleName/$version/lane/$lane/cleanFQ/SOAPnuke";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/alignment` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/alignment/bwa_mem` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment/bwa_mem";
            `mkdir -p $outDir/$sampleName/$version/lane/$lane/alignment/SOAPaligner` unless -e "$outDir/$sampleName/$version/lane/$lane/alignment/SOAPaligner";
        }(split /;/, $lanes{$slane}{FQs});
    }
}

1;
