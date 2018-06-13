package DisGen::general::ComputationalData;

use DBI;
use DisGen::general::Resource;

sub get_predict{
	my ($chr, $pos, $ref, $allele, $dbs, $db_count, $ref_version) = @_;
	my ($db_file, $dbh, $db_ary_ref, @db_query_results) = ('');

	$db_file="$DisGen::general::Resource::_wfdata_{dbNSFP}/chr$chr.db";
	if(-f $db_file){
		$dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
		if ($ref_version =~/hg19/i or $ref_version =~/grch37/i){
			$db_ary_ref=$dbh->selectall_arrayref("SELECT $dbs FROM db WHERE key37 = '$chr:$pos:$ref>$allele'");
		}elsif ($ref_version =~/hg38/i or $ref_version =~/grch38/i){
			$db_ary_ref=$dbh->selectall_arrayref("SELECT $dbs FROM db WHERE key38 = '$chr:$pos:$ref>$allele'");
		}else{
			die "ERROR:The $db_file only support hg19/grch37 and hg38/grch38\n";
		}
		
		map{
                        foreach my $i (0..$db_count-1){
                                $db_query_results[$i] = @$_[$i];
                        }
                } @$db_ary_ref;
                $dbh->disconnect();		

	}else{

		die "ERROR:Can't find $db_file\n";
	}
	
	return (\@db_query_results);
}

sub get_all_predict{
	my ($chr, $pos, $ref, $allele, $ref_version) = @_;
	my ($db_file, $dbh, $db_ary_ref, $db_query_result, @db_query_results) = ('');
	$db_file="$DisGen::general::Resource::_wfdata_{dbNSFP}/chr$chr.db";
	
	if(-f $db_file){
		$dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
                if ($ref_version =~/hg19/i or $ref_version =~/grch37/i){
                        $db_ary_ref=$dbh->selectall_arrayref("SELECT * FROM db WHERE key37 = '$chr:$pos:$ref>$allele'");
                }elsif ($ref_version =~/hg38/i or $ref_version =~/grch38/i){
                        $db_ary_ref=$dbh->selectall_arrayref("SELECT * FROM db WHERE key38 = '$chr:$pos:$ref>$allele'");
                }else{
                        die "ERROR:The $db_file only support hg19/grch37 and hg38/grch38\n";
                }
        	
		map{
                $db_query_result = "@$_"; # double quotation marks is necessary
        } @$db_ary_ref;
        $dbh->disconnect();        
#print "db_query_result: $db_query_result\n";
		@db_query_results = (split /\s/, $db_query_result);	
	}else{
		die "ERROR:Can't find $db_file\n";
	}	
	return (\@db_query_results);
}

sub get_all_predict_pos{
	my ($chr,$pos,$ref_version) = @_;
	my ($db_file, $dbh, $db_ary_ref, $db_query_result, @db_query_results) = ('');
        $db_file="$DisGen::general::Resource::_wfdata_{dbNSFP}/chr$chr.db";

        if(-f $db_file){
                $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");
                if ($ref_version =~/hg19/i or $ref_version =~/grch37/i){
                        $db_ary_ref=$dbh->selectall_arrayref("SELECT * FROM db WHERE key37 LIKE '$chr:$pos:%'");
                }elsif ($ref_version =~/hg38/i or $ref_version =~/grch38/i){
                        $db_ary_ref=$dbh->selectall_arrayref("SELECT * FROM db WHERE key38 LIKE '$chr:$pos:%'");
                }else{
                        die "ERROR:The $db_file only support hg19/grch37 and hg38/grch38\n";
                }

                map{
                    $db_query_result = "@$_"; # double quotation marks is necessary
                } @$db_ary_ref;
                $dbh->disconnect();
                @db_query_results = (split /\s/, $db_query_result);
        }else{
                die "ERROR:Can't find $db_file\n";
        }

        return (\@db_query_results);	
}

1;
