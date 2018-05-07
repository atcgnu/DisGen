#! /usr/bin/perl
package DisGen::general::GenotypeCount;
use DisGen::general::Resource;

sub get_gc {
	my ($chr, $pos, $ref, $allele) = @_;
	my ($db_file, $dbh, $db_ary_ref) = ('', 0, 0);
	my @db_query_results = (".") x 6;
	$db_file="$DisGen::general::Resource::_wfdata_{dbcase}/dbcase.chr$chr.db";
#	key|chr|pos|count|case_num|zygosity|genotype|gender|affected_status
#	21:9411318:C/T|21|9411318|7|7|hom:0,het:7|C/T:7|M:5,F:1,U:1|Case:7,Control:0
	if(-f $db_file){
		$dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
		$db_ary_ref=$dbh->selectall_arrayref("SELECT count,case_num,zygosity,genotype,gender,affected_status FROM dbcase WHERE key = '$chr:$pos:$ref/$allele'");
		map{
			foreach my $i (0..5) {
                $db_query_results[$i] = @$_[$i];
            }
		} @$db_ary_ref;
		$dbh->disconnect();
	}
	return (\@db_query_results);
}

1;
