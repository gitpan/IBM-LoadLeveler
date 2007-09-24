#########################

use Test::More tests => 2;
use IBM::LoadLeveler;

#########################

# Make A Command file

$CmdFile="/tmp/LoadLeveler-test.cmd";
#$ResultFile="/tmp/LoadLeveler-test.res";

ok(open(CMD,"> $CmdFile" ),"opening an empty file to generate a JCF");

print CMD << "EOF";

#!/bin/sh

#@ job_name = perl-loadleveler-test
#@ wall_clock_limit = 1:00
##@ resources = ConsumableCpus(1)
#@ class = large
#@ queue

#
# simulate a compute bound job by killing some time
#

sleep 300

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

ok(defined $job_name,"llsubmit test job");

# Now we have a job, get some information to compare
# the data access API against.

# ----- Work in progress ----

#ok(open(RES,"> $ResultFile"),"open a file to store some results");
#@steps=@{$job_step};
#print STDERR "\n$steps -> $#{$job_step}  -> $#steps\n";
#%step=%{$steps[0]};

#print RES "$step{'step_name'}\n";
#print STDERR "@{$step{'id'}}\n";
#print STDERR "$step{'shell'}\n";
#print RES "$uid\n";
#close(RES);

unlink $CmdFile;
