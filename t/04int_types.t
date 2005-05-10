# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/02data_access.t'


#########################
# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 8 };
use IBM::LoadLeveler;

#########################


# Make a Query Object
$query = ll_query(MACHINES);
printf  "%sok 1\n", defined $query ? '' : 'not ';

# Make a request Object
$return=ll_set_request($query,QUERY_ALL,undef,ALL_DATA);
printf  "%sok 2\n", $return == 0 ? '' : 'not ';

# Make the request
$number=0;
$err=0;
$mach=ll_get_objs($query,LL_CM,NULL,$number,$err);
printf  "%sok 3\n", $number > 0 ? '' : 'not ';
	
# Extract Pool List
$size = ll_get_data($mach, LL_MachinePoolListSize);
printf  "%sok 4\n", defined  $size ? '' : 'not ';
@poolList = ll_get_data($mach, LL_MachinePoolList);
printf  "%sok 5\n", $#poolList == $size-1 ? '' : 'not ';

# Find an adapter with more than one window

$adapter = ll_get_data($mach, LL_MachineGetFirstAdapter);
printf  "%sok 6\n", defined  $size ? '' : 'not ';

while ( ll_get_data($adapter, LL_AdapterTotalWindowCount) == 0 )
{
	$adapter = ll_get_data($mach, LL_MachineGetNextAdapter);
	last if ! $adapter
}
$size = ll_get_data($adapter, LL_AdapterTotalWindowCount);
printf  "%sok 7\n", defined  $size ? '' : 'not ';
@list = ll_get_data($adapter, LL_AdapterWindowList);
printf  "%sok 8\n", $#list == $size-1 ? '' : 'not ';

# Tidy up at the end
ll_free_objs($job);
ll_deallocate($query);
