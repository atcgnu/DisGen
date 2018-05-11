package DisGen::pipeline::Monitor;

sub robust2execute {
    my ($logpath, $logbase, $shellpath, $cmdline, $cycle_num, $out_fh)=@_;
    my $cmdline2="for ((i=1;i<=$cycle_num;i++))\ndo\n    [ ! -e $logpath/$logbase.done ] && $cmdline && ";
    $cmdline2.=" echo $logbase done && touch $logpath/$logbase.done\n";
    $cmdline2.="    [ -e $logpath/$logbase.done ] &&  i=$cycle_num\ndone\n";
    $cmdline2.="[ ! -e $logpath/$logbase.done ] && echo check $shellpath $logbase step >> $shellpath.error && exit 1\n\n";
    print $out_fh $cmdline2;
}

1;
