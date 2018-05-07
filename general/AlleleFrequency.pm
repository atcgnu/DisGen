#! /usr/bin/perl
package DisGen::general::AlleleFrequency;

use DBI;
use DisGen::general::Resource;

sub get_af {
	my ($chr, $pos, $ref, $allele, $dbs, $db_count) = @_;
	my ($db_file, $v_snv_num, $v_indel_num, $dbh, $db_ary_ref, @db_query_results) = ('', 0, 0);
	if(length($ref) == 1 && length($allele) == 1){
                $db_file="$DisGen::general::Resource::_wfdata_{dbpp}/dbpp.chr$chr.snv.db";
                $v_snv_num ++;
        }else{
                $db_file="$DisGen::general::Resource::_wfdata_{dbpp}/dbpp.chr$chr.indel.db";
                $v_indel_num ++;
        }


        if(-f $db_file){
                $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
                $db_ary_ref=$dbh->selectall_arrayref("SELECT $dbs FROM dbpp WHERE key37 = '$chr:$pos:$ref:$allele'");
                map{
                        foreach my $i (0..$db_count-1){
                                $db_query_results[$i] = @$_[$i];
                        }
                } @$db_ary_ref;
                $dbh->disconnect();
        }

	return ($v_snv_num, $v_indel_num, \@db_query_results);
}

sub get_all_af {
    my ($chr, $pos, $ref, $allele) = @_;
    my ($db_file, $v_snv_num, $v_indel_num, $dbh, $db_ary_ref, $db_query_result, @db_query_results) = ('', 0, 0);
    if(length($ref) == 1 && length($allele) == 1){
                $db_file="$DisGen::general::Resource::_wfdata_{dbpp}/dbpp.chr$chr.snv.db";
                $v_snv_num ++;
        }else{
                $db_file="$DisGen::general::Resource::_wfdata_{dbpp}/dbpp.chr$chr.indel.db";
                $v_indel_num ++;
        }


        if(-f $db_file){
                $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
                $db_ary_ref=$dbh->selectall_arrayref("SELECT * FROM dbpp WHERE key37 = '$chr:$pos:$ref:$allele'");
                map{
                    $db_query_result = "@$_";
                } @$db_ary_ref;
                $dbh->disconnect();
        }

	my @db_query_results = (split /\s/, $db_query_result);
    return ($v_snv_num, $v_indel_num, \@db_query_results);
}
1;
