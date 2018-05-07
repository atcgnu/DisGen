=head1 LICENSE

Copyright atcgnu

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut


=head1 CONTACT

Please email comments or questions to atcgnu@gmail.com

=cut

# atcgnu module for Bio::atcgnu::DisGen::general::ParseConfig
#
#


=head1 NAME

Bio::atcgnu::DisGen::general::ParseConfig - parsing configuration

=head1 SYNOPSIS

    print $genotype->variation()->name(), "\n";
    print $genotype->allele1(), '/', $genotype->allele2(), "\n";

=head1 DESCRIPTION

This is an abstract base class representing a genotype.  Specific types of
genotype are represented by subclasses such as IndividualGenotype and
PopulationGenotype.

=head1 METHODS

=cut


use strict;
use warnings;
use DisGen::general::MakeOpen;

package DisGen::general::ParseConfig;


sub parseconfig {
	my ($config) = @_;
	my ($flag, $flag_pd, $config_default, $config_user_defined, $config_app, %config_threshold) = (0, 0, '', '', '', ());
#	DisGen::general::MakeOpen::mkopen('CFG', $config, "<");
	open CFG, "$config" or die $!;
	while(<CFG>){
		chomp;
		next if /^#/;
		next if /^$/;
		
#print "$_\n";
		$flag_pd = 1 if /^FilterScreenStack:Population data:begin/;
		$flag = 1 if /^\[Population data:default\]/;
		next if /^\[Population data:default\]/;
		$flag = 2 if /^\[Population data:user defined\]/;
		next if /^\[Population data:user defined\]/;
		$flag_pd = 0 if /^FilterScreenStack:Population data:end/;

#print "flag: $flag\n";

		if($flag_pd == 1 and $flag == 1){
			$config_default .= "$_,";
		}elsif($flag_pd == 1 and $flag == 2){
			$config_user_defined .= "$_,";
		}else{
#			die "config erro: Population data, please check!\n";
		}

	}

	close CFG;
	$config_app = $config_user_defined if $flag_pd == 0 and $flag == 2;
	$config_app = $config_default if $flag_pd == 0 and $flag == 1;


	map{
		s/\s//g;
		my ($db, $threshold) = ($1, $2) if /(\S+)\(>(\S+)\)/;
		$config_threshold{$db} = $threshold if $db =~ /\S/;
#		print "$db => $threshold\n" if $db =~ /\S/;
	}(split /,/, $config_app);
	
	return (%config_threshold);
}

1;
