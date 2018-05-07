#!/use/bin/perl
#
package DisGen::general::Resource;

our %env_vars = (
    PATH => "\$PATH",
    PERL5LIB => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/perl-5.24.0/lib"
);

our %_wftool_ = (
    perl => "/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdresearch/v2.0.0/software/perl-5.24.0/bin/perl"
);

our %_wfdata_ = (
    dbpp => '/hwfssz1/ST_MCHRI/DISEASE/USER/heyuan/Project/Freq/sql',
    dbcase => '/hwfssz1/ST_MCHRI/DISEASE/DEV/pipeline/rdclinic/v3.0.0/data/dbcase',
);

1;
