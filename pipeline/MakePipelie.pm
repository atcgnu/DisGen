package DisGen::pipeline::MakePipelie;

sub mkpym{
    my @refarrays = @_;
    foreach (0..$#refarrays -1){
        my @array1 = @{$refarrays[$_]};
        my @array2 = @{$refarrays[$_+1]};
        foreach my $i (@array1){
            foreach my $j (@array2){
                print "$i   $j\n";
            }
        }
    }
}

sub mkwdl{

}

1;
