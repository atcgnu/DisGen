#!/use/bin/perl

package DisGen::general::VEP2;

sub vep2threeT {
	my ($vep) = @_;
	
	open VEP, "$vep" or die $!;
	while(<VEP>){

	}
	close VEP;
}

1;
