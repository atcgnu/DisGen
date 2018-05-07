use strict;
use warnings;
use DisGen::general::MakeOpen;

package DisGen::general::ParseConfig;


sub parseconfig {
	my ($config) = @_;
	my ($flag, $flag_pd, $config_default, $config_user_defined, $config_app, %config_threshold) = (0, 0, '', '', '', ());
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
