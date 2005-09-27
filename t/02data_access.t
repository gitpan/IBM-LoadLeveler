# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/02data_access.t'


#########################
# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 4 };
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
$job=ll_get_objs($query,LL_CM,NULL,$number,$err);
printf  "%sok 3\n", $number > 0 ? '' : 'not ';
	
# Extract Some Data
$name=ll_get_data($job,LL_MachineName);
printf  "%sok 4\n", defined $name ? '' : 'not ';

# Tidy up at the end
ll_free_objs($job);
ll_deallocate($query);
