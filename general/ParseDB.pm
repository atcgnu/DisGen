use strict;
use warnings;
use DisGen::general::MakeOpen;

package DisGen::general::ParseDB;

sub parseSDB {
    my ($db) = @_;
    my (%predigrees, %mss, %ss);
    open DB, "$db" or die $!;
    while(<DB>){
        chomp;
        next if /^#/;
        if (/^\@/){
            my ($famileID, $path2predigree) = ($1, $2) if /@\s?(\S+):predigree:(\S+)$/;
            $predigrees{$famileID} = "$path2predigree";
            next;
        }

        my ($family_id, $sample_id, $sample_name, $gender, $age, $population, $father_name, $mother_name, $disease, $phenotype, $lane_info, $region, $sequence_platform, $grch) = (split /\s+/);
        $ss{$sample_id} = {
            family_id => $family_id,
            sample_id => $sample_id,
            sample_name => $sample_name,
            gender => $gender,
            age => $age,
            population => $population,
            father_name => $father_name,
            mother_name => $mother_name,
            disease => $disease,
            phenotype => $phenotype,
            lane_info => $lane_info,
            region => $region,
            sequence_platform => $sequence_platform,
            grch => $grch,
            predigree => $predigrees{$family_id},
            ms => $mss{$family_id}
        };
    }
    close DB;
    return (%ss);
}


1;

