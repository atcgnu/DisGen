package DisGen::pipeline::Monitor;

sub robust2execute {
    my ($logpath, $logbase, $shellpath, $cmdline, $cycle_num, $out_fh, $tmp_dir, $dest_dir)=@_;
    my $cmdline2="for ((i=1;i<=$cycle_num;i++))\ndo\n    [ ! -e $logpath/$logbase.done ] && rm -rf $tmp_dir/* 2> /dev/null && $cmdline && ";
    $cmdline2.=" echo $logbase done && touch $logpath/$logbase.done\n";
    $cmdline2.="    [ -e $logpath/$logbase.done ] &&  i=$cycle_num && mv $tmp_dir/* $dest_dir/ 2> /dev/null\ndone\n";
    $cmdline2.="[ ! -e $logpath/$logbase.done ] && echo check $shellpath $logbase step >> $shellpath.error && exit 1\n\n";
    print $out_fh $cmdline2;
	return ("DONE");
}

1;
