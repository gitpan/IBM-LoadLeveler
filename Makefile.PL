use ExtUtils::MakeMaker;

$LoadL="/usr/lpp/LoadL/full";

WriteMakefile(
    'NAME'		=> 'IBM::LoadLeveler',
    'VERSION_FROM'	=> 'LoadLeveler.pm',
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM    => 'LoadLeveler.pm', # retrieve abstract from module
       AUTHOR           => 'Mike Hawkins <mike.hawkins@awe.co.uk>') : ()),
    'PM'                => { 'llapi.ph'       => '$(INST_LIBDIR)/llapi.ph',
			     'LoadLeveler.pm' => '$(INST_LIBDIR)/LoadLeveler.pm'},
    'MAN3PODS'		=> { 'LoadLeveler.pm' => '$(INST_MAN3DIR)/LoadLeveler.$(MAN3EXT)'},
    'LIBS'		=> ["-L$LoadL/lib -lllapi"], # e.g., '-lm'
    'DEFINE'		=> "-L$LoadL/lib",
    'INC'		=> "-I$LoadL/include",
    'OBJECT'		=> '$(O_FILES) '. "$LoadL/lib/llapi_shr.o",
    'macro'		=> { LoadL => "$LoadL" },
    'clean'             => { FILES => "llapi.ph" },
);
sub MY::postamble {
    my $postamble = <<'END';
llapi.ph: $(LoadL)/include/llapi.h
	( cd $(LoadL)/include ; h2ph -d /tmp llapi.h )
	cat /tmp/llapi.ph | sed -e /require.*/d > $(INST_LIB)/../../llapi.ph
	rm /tmp/llapi.ph
html: LoadLeveler.pm
	pod2html --noindex --outfile=LoadLeveler.html LoadLeveler.pm
	
END
    $postamble;
}
