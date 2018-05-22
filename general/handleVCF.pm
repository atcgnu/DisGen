
sub parseVCFh {
#	my ($ref_sampledb, $ref_vcfh) = @_;
    my ($vcf, $ref_samples) = @_;
    open VCF, "$vcf" or die $!;
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
	return ();
}
