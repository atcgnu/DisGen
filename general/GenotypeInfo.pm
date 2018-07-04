#! /usr/bin/perl
package DisGen::general::GenotypeInfo;
use DisGen::general::Resource;

sub get_hom_all {
	my ($chr, $pos, $ref, $allele) = @_;
	my ($db_file, $dbh, $db_ary_ref) = ('', 0, 0);
#	my @db_query_results = (".") x 44;
	my @db_query_results;
	$db_file="$DisGen::general::Resource::_wfdata_{dbhom}/dbhom.chr$chr.db";
#	key|chr|pos|count|case_num|zygosity|genotype|gender|affected_status
#	21:9411318:C/T|21|9411318|7|7|hom:0,het:7|C/T:7|M:5,F:1,U:1|Case:7,Control:0
	if(-f $db_file){
		$dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
		$db_ary_ref=$dbh->selectall_arrayref("SELECT * FROM db WHERE key37 = '$chr:$pos:$allele/$allele'");
		map{
			foreach my $i (0..32) {
                $db_query_results[$i] = @$_[$i];
            }
		} @$db_ary_ref;
		$dbh->disconnect();
	}
	return (\@db_query_results);
}

1;
