# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/02data_access.t'


#########################
# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 4 };
use IBM::LoadLeveler;

#########################

# Make A Command file

$CmdFile="/tmp/LoadLeveler-test.cmd";

printf "%sok 1\n", open(CMD,"> $CmdFile" ) ? '' : 'not ';

print CMD << "EOF";

#!/bin/sh
#
#@ job_name = perl-loadleveler-test
#@ queue

#
# simulate a compute bound job by killing some time
#
sleep 60

echo The name of this job is $0
echo

echo This job is running on `hostname`
echo

echo This job is running from `pwd`
echo

echo The environment is `env`
echo

echo These ids are logged onto the system:
who


EOF

close CMD;
my ($job_name,$owner,$group,$uid,$gid,$host,$steps,$job_step)=llsubmit($CmdFile,NULL,NULL);

printf "%sok 2\n", defined $job_name ? '' : 'not ';

printf "%sok 3\n", $#{$job_step} > -1 ? '' : 'not ';
$stepref=@{$job_step}[0];	
%step=%{$stepref};
printf "%sok 4\n", defined $step{'step_name'} ?  '' : 'not ';

unlink $CmdFile;
