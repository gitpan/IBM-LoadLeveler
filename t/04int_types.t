# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/02data_access.t'


use Test::More tests => 8;
use IBM::LoadLeveler;

#########################

# Make a Query Object
$query = ll_query(MACHINES);
ok(defined $query,"ll_query on MACHINES returned");

# Make a request Object
$return=ll_set_request($query,QUERY_ALL,undef,ALL_DATA);
ok($return == 0,"ll_set_request for QUERY_ALL");

# Make the request
$number=0;
$err=0;
my $mach=ll_get_objs($query,LL_CM,NULL,$number,$err);
ok($number > 0,"Get a machine list");
	
# Extract Pool List
my $size = ll_get_data($mach, LL_MachinePoolListSize);
ok(defined $size,"Get MachinePoolListSize = $size");
SKIP:
{
	skip( 'Unable to get a machine pool list size', 4) if ! defined $size || $size == 0;

	my @poolList = ll_get_data($mach, LL_MachinePoolList);
	ok($#poolList == $size-1,"Get the machine pool list");

	# Find an adapter with more than one window

	my $adapter = ll_get_data($mach, LL_MachineGetFirstAdapter);
	ok(defined $adapter,"Get the first adapter");

	while ( ll_get_data($adapter, LL_AdapterTotalWindowCount) == 0 )
	{
		$adapter = ll_get_data($mach, LL_MachineGetNextAdapter);
	}
	if ( defined $adapter )
	{
		$size = ll_get_data($adapter, LL_AdapterTotalWindowCount);
		ok(defined $size,"Get adapter window count");
	}

	if ( defined $size )
	{
    		@list = ll_get_data($adapter, LL_AdapterWindowList);
    		ok($#list == $size-1,"Get Adapter Window List");
	}
}
# Tidy up at the end
ll_free_objs($query);
ll_deallocate($query);
