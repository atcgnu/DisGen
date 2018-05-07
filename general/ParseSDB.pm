use strict;
use warnings;
use DisGen::general::MakeOpen;

package DisGen::general::ParseSDB;

sub parseSDB {
    my ($db) = @_;
    my (%predigrees, %mss, %ss);
    open DB, "$db" or die $!;
    while(<DB>){
        chomp;
        next if /^#/;
        if (/^\@/){
            my ($famile_ID, $path2predigree) = ($1, $2) if /@\s?(\S+):predigree:(\S+)$/;
            $predigrees{$famile_ID} = "$path2predigree";
            my ($famile_ID, $path2ms) = ($1, $2) if /@\s?(\S+):ms:(\S+)$/;
            $mss{$famile_ID} = "$path2ms";
            next;
        }

        my ($familyID, $sampleID, $sampleName, $gender, $age, $population, $fatherName, $motherName, $disease, $phenotype, $lanes, $chip, $platform, $grch) = (split /\s+/);
        $ss{$sampleID} = {
            familyID => $familyID,
            sampleID => $sampleID,
            sampleName => $sampleName,
            gender => $gender,
            age => $age,
            population => $population,
            fatherName => $fatherName,
            motherName => $motherName,
            disease => $disease,
            phenotype => $phenotype,
            lanes => $lanes,
            chip => $chip,
            platform => $platform,
            grch => $grch,
            predigree => $predigrees{$familyID},
            ms => $mss{$familyID}
        };
    }
    close DB;
    return (%ss);
}


1;

