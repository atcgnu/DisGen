#! /usr/bin/perl
package DisGen::pipeline::EchoString;

sub swrd {
	my $sh=shift;
	my $ostr="echo Still_waters_run_deep 1>&2 ; echo Still_waters_run_deep >$sh.sign\n";
	return $ostr;
}

1;
