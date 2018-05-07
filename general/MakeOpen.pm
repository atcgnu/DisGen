#!/usr/bin/perl

package DisGen::general::MakeOpen;

sub mkopen {
    my ($fh,$file,$mode)=@_;
    if( $file =~ /\.gz$/ ){
        open $fh ,"gzip -dc $file |" or die "Cannot open input file $file" unless $mode =~ />/;
        open $fh ,"| gzip > $file" or die "Cannot open output file $file" if $mode eq '>';
        open $fh ,"| gzip >> $file" or die "Cannot open output file $file" if $mode eq '>>';
    }elsif( $file =~ /\.bz2$/ ){
        open $fh ,"bunzip2 -dc $file |" or die "Cannot open input file $file" unless $mode =~ />/;
        open $fh ,"| bzip2 > $file" or die "Cannot open output file $file" if $mode eq '>';
        open $fh ,"| bzip2 >> $file" or die "Cannot open output file $file" if $mode eq '>>';
    }else{
       open $fh, $file or die "Cannot open input file $file" unless $mode =~ />/;
        open $fh, "> $file" or die "Cannot open output file $file" if $mode eq '>';
        open $fh, ">> $file" or die "Cannot open output file $file" if $mode eq '>>';
    }
}

1;
