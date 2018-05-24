package DisGen::pipeline::Monitor;

sub robust2execute {
    my ($logpath, $analysis_step, $shellpath, $cmdline, $cycle_num, $out_fh, $tmp_dir, $dest_dir)=@_;
    my $cmdline2="for ((i=1;i<=$cycle_num;i++))\ndo\n    [ ! -e $logpath/$analysis_step.done ] && rm -rf $tmp_dir/* 2> /dev/null && $cmdline && ";
    $cmdline2.=" echo $analysis_step done && touch $logpath/$analysis_step.done\n";
    $cmdline2.="    [ -e $logpath/$analysis_step.done ] &&  i=$cycle_num && mv $tmp_dir/* $dest_dir/ 2> /dev/null\ndone\n";
    $cmdline2.="[ ! -e $logpath/$analysis_step.done ] && echo check $shellpath $analysis_step step >> $shellpath.checkErrorStep && exit 1\n\n";
    print $out_fh $cmdline2;
}


sub EchoSWRD {
    my ($logpath, $analysis_step, $shellpath, $out_fh)=@_;
	my $ostr = "[ -e $logpath/$analysis_step.done ] && echo Still_waters_run_deep 1>&2 &&  echo Still_waters_run_deep >$shellpath.sign\n";
    print $out_fh $ostr;
}

1;
