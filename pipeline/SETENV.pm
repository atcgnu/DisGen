package DisGen::pipeline::SETENV;

sub DEFAULT {
    my ($tool) = @_;
    my $cmd;

	$cmd = "export PERL5LIB=$DisGen::general::Resource::env_vars{PERL5LIB} && export PATH=$DisGen::general::Resource::env_vars{PATH}";

	return ($cmd);
}

1;
