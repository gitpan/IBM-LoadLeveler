# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/02data_access.t'


use Test::More tests => 10;
use IBM::LoadLeveler;

#########################

#$ResultFile="/tmp/LoadLeveler-test.res";

# Make a Query Object
$query = ll_query(MACHINES);
ok(defined $query,"ll_query returned a query object");

# Make a request Object
$return=ll_set_request($query,QUERY_ALL,undef,ALL_DATA);
ok($return == 0,"ll_set_request defined a query");

# Make the request
$number=0;
$err=0;
$machines=ll_get_objs($query,LL_CM,NULL,$number,$err);
ok( $number > 0, "ll_get_objs should return some objects");

SKIP:
{

  skip( 'Query returned no objects, unable to continue this test',7) if ( $number == 0);


  # Test Data Types

  $cpus=ll_get_data($machines,LL_MachineCPUs);
  ok(defined $cpus,"ll_get_data - LL_INT_STAR data");

  $lav=ll_get_data($machines,LL_MachineLoadAverage);
  ok(defined $lav,"ll_get_data - LL_DOUBLE_STAR data");


  $name=ll_get_data($machines,LL_MachineName);
  ok(defined $name,"ll_get_data - LL_CHAR_STAR_STAR data");


  @classes=ll_get_data($machines,LL_MachineAvailableClassList);
  ok(defined @classes,"ll_get_data - LL_CHAR_STAR_STAR_STAR data");



  $time=ll_get_data($machines,LL_MachineTimeStamp);
  ok($time > 0,"ll_get_data - LL_TIME_T_STAR data");

  $adap=ll_get_data($machines,LL_MachineGetFirstAdapter);
  ok(defined $adap,"ll_get_data - LL_ELEMENT_STAR data");

#  print STDERR "\n";
#  print STDERR "LL_MachineCPUs               -> $cpus\n";
#  print STDERR "LL_MachineLoadAverage        -> $lav\n";
#  print STDERR "LL_MachineName               -> $name\n";
#  print STDERR "LL_MachineAvailableClassList -> ",join(":",@classes),"\n";
#  print STDERR "LL_MachineTimeStamp          -> ", scalar localtime $time, "\n";
#  print STDERR "LL_MachineGetFirstAdapter    -> $adap\n";

  skip( 'No Adapters returned',1) if ( ! defined $adap || $adap == 0);

  $aname=ll_get_data($adap,LL_AdapterName);
  ok(defined $aname,"ll_get_data - LL_CHAR_STAR_STAR (2) data");
#  print STDERR "LL_AdapterName               -> $aname\n";

}


# Tidy up at the end
ll_free_objs($query);
ll_deallocate($query);

#unlink $ResultFile if -f $ResultFile;
