use ExtUtils::MakeMaker;
use English;

#
# I hope this bit works out the base LoadLeveler version.
# Can't use the variables in the llapi.h file because the version number is the
# same for 3.1 & 3.2!  I am sure there is a very good reason for this, I don't know
# what it is, but i'm sure it must be a very good reason.
#
#
# If the code doesn't work out the base version then set it here by hand.
# The ifdefs expect a 7 digit number, which is the version stripped of dots,
# all single numbers doubled and leading zeros removed, so if you have
# version 3.3.0.4 the number will be 3030004
#
# $LLVER=3020016
#

if ( ! defined $LLVER )
{
    if ( $OSNAME =~ /linux/i )
    {
	$LoadL="/opt/ibmll/LoadL/full";
	$ExtraLibs="-lstdc++"; # stops load failure with error undefined symbol: __gxx_personality_v0
	
	# Find the rpm command
	open(RPM,"whereis -b rpm |");
	$_=<RPM>;
	my @binaries = split;
	my $rpm="";
	foreach my $bin ( @binaries )
	{
	    if ( -f $bin &&  -x $bin )
	    {
		$rpm=$bin;
	    }
	}
	close(RPM);
	if ( $rpm eq "" )
	{
	    print STDERR "Whoa, you seem to be running Linux but I can't find the rpm command\n";
	    print STDERR "You will need to set the \$LLVER variable by hand in Makefile.PL\n";
	    exit 1;
	}

	# This is very slow, is there a better way ?

	my @packages=`$rpm -qa`;
	foreach my $package (@packages)
	{
	    next unless $package=~/LoadL-full/;
	    my @f=split "-",$package;
	    $LLVER=$f[$#f-1];
	}
	if ( ! defined $LLVER )
	{
	    print STDERR "Whoa, I can't find a version number for the LoadL-full- package using \"$rpm -qa\"\n";
	    print STDERR "You will need to set the \$LLVER variable by hand in Makefile.PL\n";
	    exit 1;
	}
    }
    elsif  ( $OSNAME =~ /AIX/i )
    {
	$LoadL="/usr/lpp/LoadL/full";
	$ExtraLibs="";
	
	#
	# The code extracts the package version using lslpp.
	#
	open(LLVER,"/usr/bin/lslpp -Ou -qlc LoadL.full |");
	$_=<LLVER>;
	$_=~/^[^:]+:[^:]+:([^:]+):/;
	close(LLVER);
	$LLVER=$1;
    }
    elsif ( $OSNAME =~ /MSWin32/i )
    {
	print STDERR "You're having a laugh, this looks like a Windows box. Come back when you have a real computer\n";
	exit 1;
    }
    else
    {
	print STDERR "Whoa, I don't recognise your OS ($OSNAME), so I'm not going to build\n";
	exit 1;
    }
}

#
# The code converts the package version to a number, eg
# String is 3.1.0.16
# 	doubles any single digits:      03.01.00.16
#       removes the dots:               03010016
#	removes the leading 0 (octal):  3010016
# The final number is used in #ifdef statements
#
# The 1 while ..... construct repeatedly runs the doubling search. This is needed
# because if you watch one .0. then the start for the next search is the first digit
# in the next number. See Page 155 of Camel V3. Alternativly just trust me that it works :)
#

1 while $LLVER=~s/\.(\d)\./.0\1./g;
$LLVER=~s/\.(\d)$/.0\1/;
$LLVER=~s/\.//g;
$LLVER=~s/^0(\d+)/\1/;

print "Building for version $LLVER on $OSNAME\n\n";

WriteMakefile(
    'NAME'		=> 'IBM::LoadLeveler',
    'VERSION_FROM'	=> 'LoadLeveler.pm',
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM    => 'LoadLeveler.pod', # retrieve abstract from module
       AUTHOR           => 'Mike Hawkins <mike.hawkins\@awe.co.uk>') : ()),
    'PM'                => { 'llapi.ph'        => '$(INST_LIBDIR)/llapi.ph',
			     'LoadLeveler.pm'  => '$(INST_LIBDIR)/LoadLeveler.pm'
			   },
    'MAN3PODS'		=> { 'LoadLeveler.pod' => '$(INST_MAN3DIR)/LoadLeveler.$(MAN3EXT)',
			     'DataAccess.pod'  => '$(INST_MAN3DIR)/LoadLeveler::DataAccess.$(MAN3EXT)',
			     'Submit.pod'      => '$(INST_MAN3DIR)/LoadLeveler::Submit.$(MAN3EXT)',
			     'Query.pod'       => '$(INST_MAN3DIR)/LoadLeveler::Query.$(MAN3EXT)',
			     'Workload.pod'    => '$(INST_MAN3DIR)/LoadLeveler::Workload.$(MAN3EXT)',
			     'Reservation.pod' => '$(INST_MAN3DIR)/LoadLeveler::Reservation.$(MAN3EXT)',
			   },
    'LIBS'		=> ["-L$LoadL/lib -lllapi $ExtraLibs"], # e.g., '-lm'
    'DEFINE'		=> "-DLLVER=$LLVER -L$LoadL/lib",
    'INC'		=> "-I$LoadL/include",
    'OBJECT'		=> '$(O_FILES) ',
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
	pod2html --noindex --podpath=. --htmlroot=. --outfile=Reservation.html Reservation.pod
	pod2html --noindex --podpath=. --htmlroot=. --outfile=Submit.html Submit.pod
	pod2html --noindex --podpath=. --htmlroot=. --outfile=Query.html Query.pod
	pod2html --noindex --podpath=. --htmlroot=. --outfile=Workload.html Workload.pod
	pod2html --noindex --podpath=. --htmlroot=. --outfile=LoadLeveler.html LoadLeveler.pod
END
    $postamble;
}
