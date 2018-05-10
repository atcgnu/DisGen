package DisGen::general::StageMkdir;

sub byS {
	my ($outDir, $version, $sampleName, $familyID, %lanes) = @_;

    `mkdir -p $outDir/$sampleName/$version/sample/sh.e.o` unless -e "$outDir/$sampleName/$version/sample/sh.e.o";
    `mkdir -p $outDir/$sampleName/$version/sample/result` unless -e "$outDir/$sampleName/$version/sample/result";
    `mkdir -p $outDir/$sampleName/$version/sample/result/noncoding` unless -e "$outDir/$sampleName/$version/sample/result/noncoding";
    `mkdir -p $outDir/$sampleName/$version/sample/result/ROH` unless -e "$outDir/$sampleName/$version/sample/result/ROH";
    `mkdir -p $outDir/$sampleName/$version/sample/result/BAM_Stat/StatByChr` unless -e "$outDir/$sampleName/$version/sample/result//BAM_Stat/StatByChr";
    `mkdir -p $outDir/$sampleName/$version/sample/result/SOAP_Stat/StatByChr` unless -e "$outDir/$sampleName/$version/sample/result/SOAP_Stat/StatByChr";
    `mkdir -p $outDir/$sampleName/$version/sample/ByChr` unless -e "$outDir/$sampleName/$version/sample/ByChr";

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
