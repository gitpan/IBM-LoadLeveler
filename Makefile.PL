use ExtUtils::MakeMaker;

$LoadL="/usr/lpp/LoadL/full";

#
# I hope this bit works out the base LoadLeveler version.
# Can't use the variables in the llapi.h file because the version number is the
# same for 3.1 & 3.2!  I am sure there is a very good reason for this, I don't know
# what it is, but i'm sure it must be a very good reason.
#
# The code extracts the package version using lslpp, so you get a string like: 3.1.0.16
# then doubles any single digits to get 03.01.00.16 and then removes the dots to get a 
# number which you can use to compare in #ifdef statements
#
open(LLVER,"/usr/bin/lslpp -Ou -qlc LoadL.full |");
$_=<LLVER>;
$_=~/^[^:]+:[^:]+:([^:]+):/;
close(LLVER);
$LLVER=$1;
$LLVER=~s/(\d\.)/0\1/g;
$LLVER=~s/\.(\d)$/.0\1/;
$LLVER=~s/\.//g;
$LLVER=~s/^0(\d+)/\1/;

WriteMakefile(
    'NAME'		=> 'IBM::LoadLeveler',
    'VERSION_FROM'	=> 'LoadLeveler.pm',
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM    => 'LoadLeveler.pod', # retrieve abstract from module
       AUTHOR           => 'Mike Hawkins <mike.hawkins@awe.co.uk>') : ()),
    'PM'                => { 'llapi.ph'       => '$(INST_LIBDIR)/llapi.ph',
			     'LoadLeveler.pm' => '$(INST_LIBDIR)/LoadLeveler.pm'
			   },
    'MAN3PODS'		=> { 'LoadLeveler.pod'=> '$(INST_MAN3DIR)/LoadLeveler.$(MAN3EXT)',
			     'DataAccess.pod' => '$(INST_MAN3DIR)/LoadLeveler::DataAccess.$(MAN3EXT)',
			     'Submit.pod'     => '$(INST_MAN3DIR)/LoadLeveler::Submit.$(MAN3EXT)',
			     'Query.pod'      => '$(INST_MAN3DIR)/LoadLeveler::Query.$(MAN3EXT)',
			     'Workload.pod'   => '$(INST_MAN3DIR)/LoadLeveler::Workload.$(MAN3EXT)',
			   },
    'LIBS'		=> ["-L$LoadL/lib -lllapi"], # e.g., '-lm'
    'DEFINE'		=> "-DLLVER=$LLVER -L$LoadL/lib",
    'INC'		=> "-I$LoadL/include",
    'OBJECT'		=> '$(O_FILES) ',
    #'OBJECT'		=> '$(O_FILES) '. "$LoadL/lib/llapi_shr.o",
    'macro'		=> { LoadL => "$LoadL" },
    'clean'             => { FILES => "llapi.ph" },
);
sub MY::postamble {
    my $postamble = <<'END';
llapi.ph: $(LoadL)/include/llapi.h
	( cd $(LoadL)/include ; h2ph -d /tmp llapi.h )
	cat /tmp/llapi.ph | sed -e /require.*/d > $(INST_LIB)/../../llapi.ph
	rm /tmp/llapi.ph
html: LoadLeveler.pm DataAccess.pod
	pod2html --flush --noindex --podpath=. --htmlroot=. --outfile=DataAccess.html DataAccess.pod
	pod2html --noindex --podpath=. --htmlroot=. --outfile=Submit.html Submit.pod
	pod2html --noindex --podpath=. --htmlroot=. --outfile=Query.html Query.pod
	pod2html --noindex --podpath=. --htmlroot=. --outfile=Workload.html Workload.pod
	pod2html --noindex --podpath=. --htmlroot=. --outfile=LoadLeveler.html LoadLeveler.pod
END
    $postamble;
}
