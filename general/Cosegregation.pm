
sub monoplace {
	my ($sampleNames_ref, $samples_ref, $chr, $is_nocall) = @_;
    my @sampleNames = @$sampleNames_ref;
    my $sample_num = scalar @sampleNames;
    my %samples = %$samples_ref;
    my (@caseGTs, @controlGTs, @unknownGTs);
    my %ads = ('case' => '0', 'control' => '0', 'unknown' => '0');
    my %ars = ('case' => '0', 'control' => '0', 'unknown' => '0');
    my %xls = ('case' => '0', 'control' => '0', 'unknown' => '0');

    foreach my $index (0..$#sampleNames){
        my @subs = sort (split /[\/\|]/, $samples{$sampleNames[$index]}{GT});

        push @caseGTs, $sampleNames[$index] if $samples{$sampleNames[$index]}{phenotype} eq 'case';
        push @controlGTs, $sampleNames[$index] if $samples{$sampleNames[$index]}{phenotype} eq 'control';

        if($samples{$sampleNames[$index]}{phenotype} eq 'case' or $samples{$sampleNames[$index]}{phenotype}  =~ /\wP/){
            $ads{'case'} ++ if $subs[0] != $subs[1];
            $ars{'case'} ++ if $subs[0] == $subs[1] and $samples{$sampleNames[$index]}{GT} ne '0/0';
            $xls{'case'} ++ if $chr eq 'X' and $samples{$sampleNames[$index]}{GT} ne '0/0';
        }elsif($samples{$sampleNames[$index]}{phenotype} eq 'control' or $samples{$sampleNames[$index]}{phenotype} =~ /\wC/){
            $ads{'control'} ++ if $samples{$sampleNames[$index]}{GT} eq '0/0';
            $ars{'control'} ++ if $samples{$sampleNames[$index]}{GT}  =~ /0/;
            $xls{'control'} ++ if $chr eq 'X' and $samples{$sampleNames[$index]}{GT}  =~ /0/;
        }elsif($samples{$sampleNames[$index]}{phenotype} eq 'unknown' or $samples{$sampleNames[$index]}{phenotype} eq 'unknown' =~ /\wU/){
            $ads{'unknown'} ++ ;
            $ars{'unknown'} ++ ;
            $xls{'unknown'} ++ ;
        }
    }

    foreach my $control_check (@controlGTs){
        foreach my $case_check (@caseGTs){
            if ($samples{$control_check}{GT} eq $samples{$case_check}{GT}){
                $ars{'control'} -- unless $ars{'control'} == 0;
                $xls{'control'} -- unless $xls{'control'} == 0;
            }elsif($samples{$control_check}{GT} eq '1/0' and $samples{$case_check}{GT} =~ /1/){
                $ads{'case'} -- unless $ads{'case'} == 0;
            }elsif($samples{$control_check}{GT} eq '2/0' and $samples{$case_check}{GT} =~ /2/){
                $ads{'case'} -- unless $ads{'case'} == 0;
            }
            last;
        }
    }

    my ($ad_flag, $ar_flag, $com_het_flag, $xls_flag);
    my ($is_ad_co, $is_ar_co, $is_comhet_co, $is_xl_co) = ('N', 'N', 'N', 'N');

    my $gt_sig = 'Y';
    $gt_sig = 'N' if $is_nocall eq 'Y';
    $is_ad_co = "Y" if $ads{'case'} + $ads{'control'} + $ads{'unknown'} == $sample_num;
    $is_ar_co = "Y" if $ars{'case'} + $ars{'control'} + $ars{'unknown'} == $sample_num;
    $is_xl_co = "Y" if $xls{'case'} + $xls{'control'} + $xls{'unknown'} == $sample_num;

    $ad_flag = "AD:$gt_sig$is_ad_co:$ads{'case'}:$ads{'control'}:$ads{'unknown'}";
    $ar_flag = "AR:$gt_sig$is_ar_co:$ars{'case'}:$ars{'control'}:$ars{'unknown'}";
    $xl_flag = "XL:$gt_sig$is_xl_co:$xls{'case'}:$xls{'control'}:$xls{'unknown'}";


    return($ad_flag, $ar_flag, $xls_flag);
}

sub biplace { 
    my ($sv1, $sv2, $ref_sgt, $ref_samples) = @_;
    my $sample_num = 0;
    my @sample_names = @$ref_samples;
    my %com_hets = ('case' => '0', 'control' => '0', 'unknown' => '0');
    my %sgt = %$ref_sgt;
    my %sample;
    my $is_comhet_co = 'N';
    foreach(@sample_names){
        $sample_num ++;
        $sample{$_} ++ if $sgt{$sv1}{$_} ne '0/0';
        $sample{$_} ++ if $sgt{$sv2}{$_} ne '0/0';
    }

    foreach(@sample_names){
        $com_hets{'case'} ++ if ($_ =~ /^\wP/i or $_ =~ /^case/i) and $sample{$_} == 2;
        $com_hets{'control'} ++ if ($_ =~ /^\wC/i or $_ =~ /^control/i) and $sample{$_} != 2;
        $com_hets{'unknown'} ++ if ($_ =~ /^\wU/i or $_ =~ /^unknown/i);
    }
    my $gt_sig = 'Y';
    $gt_sig = 'N' if $sgt{$sv1}{'is_nocall'} eq 'Y' or $sgt{$sv2}{'is_nocall'} eq 'Y';
    my $co_sig = 'N';
    $co_sig = "Y" if $com_hets{'case'} + $com_hets{'control'} + $com_hets{'unknown'} == $sample_num;
    return ("CompHet:$gt_sig$co_sig:$com_hets{'case'}:$com_hets{'control'}:$com_hets{'unknown'}");

}

sub gene {}

