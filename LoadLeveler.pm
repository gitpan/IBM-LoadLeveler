# -*- Perl -*-
package IBM::LoadLeveler;

use 5.006;
use strict;
use warnings;
use Carp;

require Exporter;
require DynaLoader;
use AutoLoader;

our @ISA = qw(Exporter DynaLoader);

require 'llapi.ph';

our @EXPORT = qw(
	JOBS MACHINES PERF CLUSTERS WLMSTAT MATRIX

	QUERY_ALL       QUERY_JOBID   QUERY_STEPID QUERY_USER
	QUERY_GROUP     QUERY_CLASS   QUERY_HOST   QUERY_PERF
	QUERY_STARTDATE QUERY_ENDDATE

	ALL_DATA  STATUS_LINE Q_LINE

	LL_STARTD LL_SCHEDD LL_CM  LL_MASTER LL_STARTER LL_HISTORY_FILE

	STATE_IDLE              STATE_PENDING
        STATE_STARTING          STATE_RUNNING
	STATE_COMPLETE_PENDING  STATE_REJECT_PENDING
        STATE_REMOVE_PENDING    STATE_VACATE_PENDING
        STATE_COMPLETED         STATE_REJECTED
        STATE_REMOVED    	STATE_VACATED
        STATE_CANCELED          STATE_NOTRUN
        STATE_TERMINATED        STATE_UNEXPANDED
        STATE_SUBMISSION_ERR    STATE_HOLD
        STATE_DEFERRED          STATE_NOTQUEUED
        STATE_PREEMPTED         STATE_PREEMPT_PENDING
        STATE_RESUME_PENDING

	LL_CONTROL_RECYCLE	LL_CONTROL_RECONFIG
	LL_CONTROL_START	LL_CONTROL_STOP
	LL_CONTROL_DRAIN	LL_CONTROL_DRAIN_STARTD
	LL_CONTROL_DRAIN_SCHEDD LL_CONTROL_PURGE_SCHEDD
	LL_CONTROL_FLUSH	LL_CONTROL_SUSPEND
	LL_CONTROL_RESUME	LL_CONTROL_RESUME_STARTD
	LL_CONTROL_RESUME_SCHEDD LL_CONTROL_FAVOR_JOB
	LL_CONTROL_UNFAVOR_JOB  LL_CONTROL_FAVOR_USER
	LL_CONTROL_UNFAVOR_USER LL_CONTROL_HOLD_USER
	LL_CONTROL_HOLD_SYSTEM  LL_CONTROL_HOLD_RELEASE
	LL_CONTROL_PRIO_ABS	LL_CONTROL_PRIO_ADJ

	ll_version
	ll_query
	ll_set_request
	ll_get_objs
	ll_get_data
	ll_next_obj
	ll_free_objs
	ll_deallocate

	llsubmit
	
	ll_get_jobs
	ll_get_nodes

	ll_control
	llctl
	llfavorjob
	llfavoruser
	llhold
	llprio
	ll_preempt
	ll_start_job
	ll_terminate_job

	ll_error

	LL_JobManagementInteractiveClass
	LL_JobManagementListenSocket
	LL_JobManagementAccountNo
	LL_JobManagementSessionType
	LL_JobManagementPrinterFILE
	LL_JobManagementRestorePrinter

	LL_JobGetFirstStep
	LL_JobGetNextStep
	LL_JobCredential
	LL_JobName
	LL_JobStepCount
	LL_JobStepType
	LL_JobSubmitHost
	LL_JobSubmitTime
	LL_JobVersionNum

	LL_StepNodeCount
	LL_StepGetFirstNode
	LL_StepGetNextNode
	LL_StepMachineCount
	LL_StepGetFirstMachine
	LL_StepGetNextMachine
	LL_StepGetFirstSwitchTable
	LL_StepGetNextSwitchTable
	LL_StepGetMasterTask
	LL_StepTaskInstanceCount
	LL_StepAccountNumber
	LL_StepAdapterUsage
	LL_StepComment
	LL_StepCompletionCode
	LL_StepCompletionDate
	LL_StepEnvironment
	LL_StepErrorFile
	LL_StepExecSize
	LL_StepHostName
	LL_StepID
	LL_StepInputFile
	LL_StepImageSize
	LL_StepImmediate
	LL_StepIwd
	LL_StepJobClass
	LL_StepMessages
	LL_StepName
	LL_StepNodeUsage
	LL_StepOutputFile
	LL_StepParallelMode
	LL_StepPriority
	LL_StepShell
	LL_StepStartDate
	LL_StepDispatchTime
	LL_StepState
	LL_StepStartCount
	LL_StepCpuLimitHard
	LL_StepCpuLimitSoft
	LL_StepCpuStepLimitHard
	LL_StepCpuStepLimitSoft
	LL_StepCoreLimitHard
	LL_StepCoreLimitSoft
	LL_StepDataLimitHard
	LL_StepDataLimitSoft
	LL_StepFileLimitHard
	LL_StepFileLimitSoft
	LL_StepRssLimitHard
	LL_StepRssLimitSoft
	LL_StepStackLimitHard
	LL_StepStackLimitSoft
	LL_StepWallClockLimitHard
	LL_StepWallClockLimitSoft
	LL_StepHostList
	LL_StepHoldType
	LL_StepLoadLevelerGroup
	LL_StepGetFirstAdapterReq
	LL_StepGetNextAdapterReq
	LL_StepRestart
	LL_StepBlocking
	LL_StepTaskGeometry
	LL_StepTotalTasksRequested
	LL_StepTasksPerNodeRequested
	LL_StepTotalNodesRequested
	LL_StepSystemPriority
	LL_StepClassSystemPriority
	LL_StepGroupSystemPriority
	LL_StepUserSystemPriority
	LL_StepQueueSystemPriority
	LL_StepExecutionFactor
	LL_StepImageSize64
	LL_StepCpuLimitHard64
	LL_StepCpuLimitSoft64
	LL_StepCpuStepLimitHard64
	LL_StepCpuStepLimitSoft64
	LL_StepCoreLimitHard64
	LL_StepCoreLimitSoft64
	LL_StepDataLimitHard64
	LL_StepDataLimitSoft64
	LL_StepFileLimitHard64
	LL_StepFileLimitSoft64
	LL_StepRssLimitHard64
	LL_StepRssLimitSoft64
	LL_StepStackLimitHard64
	LL_StepStackLimitSoft64
	LL_StepWallClockLimitHard64
	LL_StepWallClockLimitSoft64
	LL_StepStepUserTime64
	LL_StepStepSystemTime64
	LL_StepStepMaxrss64
	LL_StepStepIxrss64
	LL_StepStepIdrss64
	LL_StepStepIsrss64
	LL_StepStepMinflt64
	LL_StepStepMajflt64
	LL_StepStepNswap64
	LL_StepStepInblock64
	LL_StepStepOublock64
	LL_StepStepMsgsnd64
	LL_StepStepMsgrcv64
	LL_StepStepNsignals64
	LL_StepStepNvcsw64
	LL_StepStepNivcsw64
	LL_StepStarterUserTime64
	LL_StepStarterSystemTime64
	LL_StepStarterMaxrss64
	LL_StepStarterIxrss64
	LL_StepStarterIdrss64
	LL_StepStarterIsrss64
	LL_StepStarterMinflt64
	LL_StepStarterMajflt64
	LL_StepStarterNswap64
	LL_StepStarterInblock64
	LL_StepStarterOublock64
	LL_StepStarterMsgsnd64
	LL_StepStarterMsgrcv64
	LL_StepStarterNsignals64
	LL_StepStarterNvcsw64
	LL_StepStarterNivcsw64
	LL_StepMachUsageCount
	LL_StepGetFirstMachUsage
	LL_StepGetNextMachUsage
	LL_StepCheckpointable
	LL_StepCheckpointing
	LL_StepCkptAccumTime
	LL_StepCkptFailStartTime
	LL_StepCkptFile
	LL_StepCkptGoodElapseTime
	LL_StepCkptGoodStartTime
	LL_StepCkptTimeHardLimit
	LL_StepCkptTimeHardLimit64
	LL_StepCkptTimeSoftLimit
	LL_StepCkptTimeSoftLimit64
	LL_StepCkptRestart
	LL_StepCkptRestartSameNodes
	LL_StepWallClockUsed
	LL_StepLargePage

	LL_MachineAdapterList
	LL_MachineArchitecture
	LL_MachineAvailableClassList
	LL_MachineCPUs
	LL_MachineDisk
	LL_MachineFeatureList
	LL_MachineConfiguredClassList
	LL_MachineKbddIdle
	LL_MachineLoadAverage
	LL_MachineMachineMode
	LL_MachineMaxTasks
	LL_MachineName
	LL_MachineOperatingSystem
	LL_MachinePoolList
	LL_MachineRealMemory
	LL_MachineScheddRunningJobs
	LL_MachineScheddState
	LL_MachineScheddTotalJobs
	LL_MachineSpeed
	LL_MachineStartdState
	LL_MachineStartdRunningJobs
	LL_MachineStepList
	LL_MachineTimeStamp
	LL_MachineVirtualMemory
	LL_MachinePoolListSize
	LL_MachineFreeRealMemory
	LL_MachinePagesScanned
	LL_MachinePagesFreed
	LL_MachinePagesPagedIn
	LL_MachinePagesPagedOut
	LL_MachineGetFirstResource
	LL_MachineGetNextResource
	LL_MachineGetFirstAdapter
	LL_MachineGetNextAdapter
	LL_MachineDrainingClassList
	LL_MachineDrainClassList
	LL_MachineStartExpr
	LL_MachineSuspendExpr
	LL_MachineContinueExpr
	LL_MachineVacateExpr
	LL_MachineKillExpr
	LL_MachineDisk64
	LL_MachineRealMemory64
	LL_MachineVirtualMemory64
	LL_MachineFreeRealMemory64
	LL_MachinePagesScanned64
	LL_MachinePagesFreed64
	LL_MachinePagesPagedIn64
	LL_MachinePagesPagedOut64
	LL_MachineLargePageSize64
	LL_MachineLargePageCount64
	LL_MachineLargePageFree64

	LL_NodeTaskCount
	LL_NodeGetFirstTask
	LL_NodeGetNextTask
	LL_NodeMaxInstances
	LL_NodeMinInstances
	LL_NodeRequirements
	LL_NodeInitiatorCount

	LL_SwitchTableJobKey

	LL_TaskTaskInstanceCount
	LL_TaskGetFirstTaskInstance
	LL_TaskGetNextTaskInstance
	LL_TaskExecutable
	LL_TaskExecutableArguments
	LL_TaskIsMaster
	LL_TaskGetFirstResourceRequirement
	LL_TaskGetNextResourceRequirement

	LL_TaskInstanceAdapterCount
	LL_TaskInstanceGetFirstAdapter
	LL_TaskInstanceGetNextAdapter
	LL_TaskInstanceGetFirstAdapterUsage
	LL_TaskInstanceGetNextAdapterUsage
	LL_TaskInstanceMachineName
	LL_TaskInstanceTaskID

	LL_AdapterInterfaceAddress
	LL_AdapterMode
	LL_AdapterName
	LL_AdapterUsageWindow
	LL_AdapterUsageProtocol
	LL_AdapterUsageWindowMemory
	LL_AdapterCommInterface
	LL_AdapterUsageMode
	LL_AdapterMinWindowSize
	LL_AdapterMaxWindowSize
	LL_AdapterMemory
	LL_AdapterTotalWindowCount
	LL_AdapterAvailWindowCount
	LL_AdapterUsageAddress

	LL_CredentialGid
	LL_CredentialGroupName
	LL_CredentialUid
	LL_CredentialUserName

	LL_StartdPerfJobsRunning
	LL_StartdPerfJobsPending
	LL_StartdPerfJobsSuspended
	LL_StartdPerfCurrentJobs
	LL_StartdPerfTotalJobsReceived
	LL_StartdPerfTotalJobsCompleted
	LL_StartdPerfTotalJobsRemoved
	LL_StartdPerfTotalJobsVacated
	LL_StartdPerfTotalJobsRejected
	LL_StartdPerfTotalJobsSuspended
	LL_StartdPerfTotalConnections
	LL_StartdPerfFailedConnections
	LL_StartdPerfTotalOutTransactions
	LL_StartdPerfFailedOutTransactions
	LL_StartdPerfTotalInTransactions
	LL_StartdPerfFailedInTransactions

	LL_ScheddPerfJobsIdle
	LL_ScheddPerfJobsPending
	LL_ScheddPerfJobsStarting
	LL_ScheddPerfJobsRunning
	LL_ScheddPerfCurrentJobs
	LL_ScheddPerfTotalJobsSubmitted
	LL_ScheddPerfTotalJobsCompleted
	LL_ScheddPerfTotalJobsRemoved
	LL_ScheddPerfTotalJobsVacated
	LL_ScheddPerfTotalJobsRejected
	LL_ScheddPerfTotalConnections
	LL_ScheddPerfFailedConnections
	LL_ScheddPerfTotalOutTransactions
	LL_ScheddPerfFailedOutTransactions
	LL_ScheddPerfTotalInTransactions
	LL_ScheddPerfFailedInTransactions

	LL_VersionCheck

	LL_AdapterReqCommLevel
	LL_AdapterReqUsage

	LL_ClusterGetFirstResource
	LL_ClusterGetNextResource
	LL_ClusterSchedulingResources
	LL_ClusterDefinedResources
	LL_ClusterSchedulingResourceCount
	LL_ClusterDefinedResourceCount
	LL_ClusterEnforcedResources
	LL_ClusterEnforcedResourceCount
	LL_ClusterEnforceSubmission

	LL_ClusterSchedulerType

	LL_ResourceName
	LL_ResourceInitialValue
	LL_ResourceAvailableValue
	LL_ResourceInitialValue64
	LL_ResourceAvailableValue64

	LL_ResourceRequirementName
	LL_ResourceRequirementValue
	LL_ResourceRequirementValue64

	LL_WlmStatCpuTotalUsage
	LL_WlmStatCpuSnapshotUsage
	LL_WlmStatMemoryHighWater
	LL_WlmStatMemorySnapshotUsage

	LL_MatrixTimeSlice 
	LL_MatrixColumnCount
	LL_MatrixRowCount
	LL_MatrixGetFirstColumn
	LL_MatrixGetNextColumn

	LL_ColumnMachineName 
	LL_ColumnProcessorNumber
	LL_ColumnRowCount
	LL_ColumnStepNames

	LL_MachUsageMachineName 
	LL_MachUsageMachineSpeed
	LL_MachUsageDispUsageCount
	LL_MachUsageGetFirstDispUsage
	LL_MachUsageGetNextDispUsage

	LL_DispUsageEventUsageCount
	LL_DispUsageGetFirstEventUsage
	LL_DispUsageGetNextEventUsage
	LL_DispUsageStepUserTime64
	LL_DispUsageStepSystemTime64
	LL_DispUsageStepMaxrss64
	LL_DispUsageStepIxrss64
	LL_DispUsageStepIdrss64
	LL_DispUsageStepIsrss64
	LL_DispUsageStepMinflt64
	LL_DispUsageStepMajflt64
	LL_DispUsageStepNswap64
	LL_DispUsageStepInblock64
	LL_DispUsageStepOublock64
	LL_DispUsageStepMsgsnd64
	LL_DispUsageStepMsgrcv64
	LL_DispUsageStepNsignals64
	LL_DispUsageStepNvcsw64
	LL_DispUsageStepNivcsw64
	LL_DispUsageStarterUserTime64
	LL_DispUsageStarterSystemTime64
	LL_DispUsageStarterMaxrss64
	LL_DispUsageStarterIxrss64
	LL_DispUsageStarterIdrss64
	LL_DispUsageStarterIsrss64
	LL_DispUsageStarterMinflt64
	LL_DispUsageStarterMajflt64
	LL_DispUsageStarterNswap64
	LL_DispUsageStarterInblock64
	LL_DispUsageStarterOublock64
	LL_DispUsageStarterMsgsnd64
	LL_DispUsageStarterMsgrcv64
	LL_DispUsageStarterNsignals64
	LL_DispUsageStarterNvcsw64
	LL_DispUsageStarterNivcsw64

	LL_EventUsageEventID 
	LL_EventUsageEventName
	LL_EventUsageEventTimestamp
	LL_EventUsageStepUserTime64
	LL_EventUsageStepSystemTime64
	LL_EventUsageStepMaxrss64
	LL_EventUsageStepIxrss64
	LL_EventUsageStepIdrss64
	LL_EventUsageStepIsrss64
	LL_EventUsageStepMinflt64
	LL_EventUsageStepMajflt64
	LL_EventUsageStepNswap64
	LL_EventUsageStepInblock64
	LL_EventUsageStepOublock64
	LL_EventUsageStepMsgsnd64
	LL_EventUsageStepMsgrcv64
	LL_EventUsageStepNsignals64
	LL_EventUsageStepNvcsw64
	LL_EventUsageStepNivcsw64
	LL_EventUsageStarterUserTime64
	LL_EventUsageStarterSystemTime64
	LL_EventUsageStarterMaxrss64
	LL_EventUsageStarterIxrss64
	LL_EventUsageStarterIdrss64
	LL_EventUsageStarterIsrss64
	LL_EventUsageStarterMinflt64
	LL_EventUsageStarterMajflt64
	LL_EventUsageStarterNswap64
	LL_EventUsageStarterInblock64
	LL_EventUsageStarterOublock64
	LL_EventUsageStarterMsgsnd64
	LL_EventUsageStarterMsgrcv64
	LL_EventUsageStarterNsignals64
	LL_EventUsageStarterNvcsw64

	LL_StepState
	LL_CredentialUserName
	LL_StepWallClockUsed
	LL_StepID
        LL_StepPriority
        LL_StepJobClass
        LL_StepGetFirstMachine
	LL_MachineName
	LL_JobGetNextStep
);
our $VERSION = '0.07';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "& not defined" if $constname eq 'constant';
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/ || $!{EINVAL}) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
	    croak "Your vendor has not defined LoadLeveler macro $constname";
	}
    }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
	if ($] >= 5.00561) {
	    *$AUTOLOAD = sub () { $val };
	}
	else {
	    *$AUTOLOAD = sub { $val };
	}
    }
    goto &$AUTOLOAD;
}

bootstrap IBM::LoadLeveler $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

IBM::LoadLeveler - Perl Access to IBM LoadLeveler API

=head1 SYNOPSIS

  use IBM::LoadLeveler;

  $version = ll_version();

  # Workload Management API

  $rc=ll_control($control_op,\@host_list,\@user_list,\@job_list,\@class_list,$priority);

  $rc=llctl(LL_CONTROL_START|LL_CONTROL_STOP|LL_CONTROL_RECYCLE|LL_CONTROL_RECONFIG|LL_CONTROL_DRAIN|LL_CONTROL_DRAIN_SCHEDD|LL_CONTROL_DRAIN_STARTD|LL_CONTROL_FLUSH|LL_CONTROL_PURGE_SCHEDD|LL_CONTROL_SUSPEND|LL_CONTROL_RESUME|LL_CONTROL_RESUME_STARTD|LL_CONTROL_RESUME_SCHEDD,\@host_list,\@class_list);

  $rc=llfavorjob(LL_CONTROL_FAVOR_JOB|LL_CONTROL_UNFAVOR_JOB,\@job_list);

  $rc=llfavorjob(LL_CONTROL_FAVOR_USER|LL_CONTROL_UNFAVOR_USER,\@user_list);

  $rc=llhold(LL_CONTROL_HOLD_USER|LL_CONTROL_HOLD_SYSTEM|LL_CONTROL_HOLD_RELEASE,\@host_list,\@user_list,\@job_list);

  rc=llprio(LL_CONTROL_PRIO_ABS|LL_CONTROL_PRIO_ADJ,\@job_list,$priority);

  $rc=ll_start_job($cluster,$proc,$from_host,\@node_list);
  $rc=ll_terminate_job($cluster,$proc,$from_host,$msg);
  ($rc,$errObj)=ll_preempt($job_step_id, PREEMPT_STEP|RESUME_STEP);

  # Error API

  ll_error($errObj,1 | 2 );

  # Submit API function

  ($job_name,$owner,$groupname,$uid,$gid,$submit_host,$numsteps,$ref)=llsubmit($job_cmd_file,$monitor_program,$monitor_args);

  # Data Access API functions

  $query = ll_query( JOBS|MACHINES|CLUSTER|WLMSTAT|MATRIX );

  $return = ll_set_request( $query,QUERY_ALL|QUERY_JOBID|QUERY_STEPID|QUERY_GROUP|QUERY_CLASS|QUERY_HOST|QUERY_STARTDATE|QUERY_ENDDATE, \@filter,ALL_DATA|Q_LINE|STATUS_LINE );

  $object = ll_get_objs( $query, LL_STARTED|LL_SCHED|LL_CM|LL_MASTER|LL_STARTER|LL_HISTORY_FILE, $hostname, $number_of_objs, $error_code);

  $return = ll_reset_request( $object );

  $next_object = ll_next_obj ( $object );

  $return = ll_free_objs ( $object );

  $return = ll_deallocate ( $object );

  $result = ll_get_data( $object, $LLAPI_Specification );

  # Query API functions ( deprecated )

  my ($version_num,$numnodes,$noderef)=ll_get_nodes();

  my ($version_num,$numjobs,$ref)=ll_get_jobs();

=head1 DESCRIPTION

This module provides access to the APIs of the IBM LoadLeveler Workload Management System.  The APIs currently implemented are:

=over 4

=item * L<Data Access|Data Access API>

=item * L<Query|Query API>

=item * L<Submit|Submit API>

=item * Error Handling

=item * L<Workload Management (Partial)|Workload Management API>

=back

This version has only been tested with LoadLeveler 3.1.0 under AIX 5.1.

This module is not for the faint hearted.  The LoadLeveler API returns a huge amount of information, the ll_get_data call has over 300 different specifications that can be supplied.  To use this module you really need a copy of the the IBM documentation on using LoadLeveler and maybe a copy of the llapi.h header file.

=head2 Data Access API

The Data Access API has the following functions:

=over 4

=item * ll_query

=item * ll_set_request

=item * ll_reset_request

=item * ll_get_objs

=item * ll_get_data

=item * ll_next_obj

=item * ll_free_objs

=item * ll_deallocate

=back

A minimal example of using the Data Access API is:

	use IBM::LoadLeveler;

	# Query Job information
	$query = ll_query(JOBS);

	# Ask for all data on all jobs
	$return=ll_set_request($query,QUERY_ALL,undef,ALL_DATA);
	if ($return != 0 )
	{
	    print STDERR "ll_set_request failed Return = $return\n";
	}

	# Query the scheduler for information
	# $number will contain the number of objects returned

	$job=ll_get_objs($query,LL_CM,NULL,$number,$err);

	while ( $job)
	{
		# Get the Job submit time
		$SubmitTime=ll_get_data($job,LL_JobSubmitTime);
		$job=ll_next_obj($query);
	}
	# Free up space allocated by LoadLeveler to hold the job object
	ll_free_objs($job);

	# Free up space used by the Query Object
	ll_deallocate($query);

=over 4

=item ll_query

	$query = ll_query( JOBS | MACHINES | CLUSTER | WLMSTAT | MATRIX );

ll_query is the first call you make to access the API it establishes the type of information you receive.

=item ll_set_request

	$return=ll_set_request($query,$QueryFlags,$ObjectFilter, $DataFilter);

ll_set_request is used to determine the range of data returned by ll_get_objs.


B<Parameters>


=over 4

=item 1 $query

The return from L<ll_query>

=item 2 $QueryFlags

The permissable Query Flags depends on the type of query being made.  The flags are:

=over 4

=item * QUERY_ALL
: Query all jobs.

=item * QUERY_JOBID
: Query by job ID.

=item * QUERY_STEPID
: Query by step ID.

=item * QUERY_USER
: Query by user ID.

=item * QUERY_GROUP
: Query by LoadLeveler group.

=item * QUERY_CLASS
: Query by LoadLeveler class.

=item * QUERY_HOST
: Query by machine name.

=item * QUERY_STARTDATE
: Query by job start dates

=item * QUERY_ENDDATE
: Query by job end dates.

=back

They can be used with the following query types:

=begin text
	Query Type	Permitted Flags
	-------------------------------
	JOBS		QUERY_ALL QUERY_JOBID QUERY_STEPID QUERY_USER QUERY_GROUP QUERY_CLASS QUERY_HOST QUERY_STARTDATE QUERY_ENDDATE
	MACHINES	QUERY_ALL QUERY_HOST
	CLUSTER		QUERY_ALL
	WLMSTAT		QUERY_STEPID
	MATRIX		QUERY_ALL QUERY_HOST

=end text

=begin html
<table border="1">
<tr>
<th>	Query Type</th><th>	Permitted Flags</th>
</tr>
<tr>
<td>	JOBS</td><td>		QUERY_ALL QUERY_JOBID QUERY_STEPID QUERY_USER QUERY_GROUP QUERY_CLASS QUERY_HOST QUERY_STARTDATE QUERY_ENDDATE</td>
</tr>
<tr>
<td>		MACHINES	</td><td>QUERY_ALL QUERY_HOST</td>
</tr>
<tr>
<td>	CLUSTER		</td><td>QUERY_ALL</td>
</tr>
<tr>
<td>	WLMSTAT		</td><td>QUERY_STEPID</td>
</tr>
<tr>
<td>	MATRIX		</td><td>QUERY_ALL QUERY_HOST</td>
</tr>
</table>
<br>

=end html


=item 3 $ObjectFilter


Specifies the search criteria:

=begin text
	Query Flag	Filter
	---------------------------------------
	QUERY_ALL	undef
	QUERY_JOBID	Array reference of job IDs eg ["host.jobid1", "host.jobid2"]
	QUERY_STEPID	Array reference of step IDs eg ["host.jobid.stepid"]
	QUERY_USER	Array reference of user IDs eg ["fred", "mark", "mary"]
	QUERY_CLASS     Array reference of LoadLeveler class names.
	QUERY_GROUP	Array reference of LoadLeveler group names.
	QUERY_HOST	Array reference of LoadLeveler host names.
	QUERY_STARTDATE or QUERY_ENDDATE two start dates or two end dates having the format MM/DD/YYYY eg ["01/14/2003", "02/23/2003"].

=end text

=begin html
<table border="1">
<tr>
<th>	Query Flag</th><th>	Filter</th>
</tr>
<tr>
<td>	QUERY_ALL</td><td>	undef</td>
</tr>
<tr>
<td>	QUERY_JOBID</td><td>	Array reference of job IDs eg ["host.jobid1", "host.jobid2"]</td>
</tr>
<tr>
<td>	QUERY_STEPID</td><td>	Array reference of step IDs eg ["host.jobid.stepid"]</td>
</tr>
<tr>
<td>	QUERY_USER</td><td>	Array reference of user IDs eg ["fred", "mark", "mary"]</td>
</tr>
<tr>
<td>	QUERY_CLASS</td><td>     Array reference of LoadLeveler class names.</td>
</tr>
<tr>
<td>	QUERY_GROUP</td><td>	Array reference of LoadLeveler group names.</td>
</tr>
<tr>
<td>	QUERY_HOST</td><td>	Array reference of LoadLeveler host names.</td>
</tr>
<tr>
<td>	QUERY_STARTDATE or QUERY_ENDDATE</td><td> two start dates or two end dates having the format MM/DD/YYYY eg ["01/14/2003", "02/23/2003"].</td>
</tr>
</table>

=end html

=item 4 $DataFilter

Filters the amount of data you get back from the query. Permitted values are:

=over  4

=item * ALL_DATA

=item * Q_LINE

Valid only for a JOBS query, not using the history file, returns the same data as B<llq -f>

=item * STATUS_LINE

Valid only for a MACHINES query, returns the same data as B<llstatus -f>

=back

=back

=item ll_reset_request


	$return=ll_reset_request($query);

This is used to reset the request (surprise!) associated with a query object, you use it if you want to do another L<ll_set_request> using different parameters.

=item ll_get_objs

	$data=ll_get_objs($query,$query_daemon,$host,$number,$err);

Sends a query request to LoadLeveler

B<Parameters>

=over 4

=item 1 $query

Data from ll_query

=item 2 $query_daemon

The LoadLeveler Daemon you want to query, permitted values are:

=over 4

=item * LL_STARTD

=item * LL_SCHEDD

=item * LL_CM (negotiator)

=item * LL_MASTER

=item * LL_STARTER

=item * LL_HISTORY_FILE

=back

=item 3 $host

Should be NULL unless you are querying LL_STARTD or LL_SCHED and want to query a machine other than the localhost. If you are querying LL_HISTORY_FILE then this should be the name of the history file.

=item 4 $number

The number of query objects returned.

=item 5 $error

If there is an error this is it. Possible values are:


=over 4

=item -1 query_element not valid

=item -2 query_daemon not valid

=item -3 Cannot resolve hostname

=item -4 Request type for specified daemon not valid

=item -5 System error

=item -6 No valid objects meet the request

=item -7 Configuration error

=item -9 Connection to daemon failed

=item -10 Error processing history file (LL_HISTORY_FILE query only)

=item -11 History file must be specified in the hostname argument (LL_HISTORY_FILE query only)

=item -12 Unable to access the history file (LL_HISTORY_FILE query only)

=item -13 DCE identity of calling program can not be established

=item -14 No DCE credentials

=item -15 DCE credentials within 300 secs of expiration

=item -16 64-bit API is not supported when DCE is enabled

=back

=back

=item ll_get_data

	$data=ll_get_data($element,$specification);

This call differs from the IBM documentation, the data you request is returned as the return value and not as a third parameter eg

	$lav=ll_get_data($machine,LL_MachineLoadAverage);	# Returns a double

	@msl=ll_get_data($machine,LL_MachineStepList);		# Returns an array of strings.

To know what you are getting you really need to know about the LoadLeveler Job Object Model.  All of this is in the I<IBM LoadLeveler for AIX 5L: Using and Administering> book and html. Sorry for not including it here, but there is an awful lot of it.


B<enum types>

Returns from some query types may be, in C terms, enumerated types.  In perl these all return as SCALAR Integers.  Return values are shown below:

=over 4

=item LL_AdapterReqUsage

    SHARED, NOT_SHARED, SLICE_NOT_SHARED

=item LL_StepHoldType

    NO_HOLD, HOLDTYPE_USER, HOLDTYPE_SYSTEM, HOLDTYPE_USERSYS

=item LL_StepNodeUsage

    SHARED, NOT_SHARED, SLICE_NOT_SHARED

=item LL_StepState

    STATE_IDLE, STATE_PENDING, STATE_STARTING, STATE_RUNNING,
    STATE_COMPLETE_PENDING, STATE_REJECT_PENDING, STATE_REMOVE_PENDING,
    STATE_VACATE_PENDING, STATE_COMPLETED, STATE_REJECTED, STATE_REMOVED,
    STATE_VACATED, STATE_CANCELED, STATE_NOTRUN, STATE_TERMINATED,
    STATE_UNEXPANDED, STATE_SUBMISSION_ERR, STATE_HOLD, STATE_DEFERRED,
    STATE_NOTQUEUED, STATE_PREEMPTED, STATE_PREEMPT_PENDING, 
    STATE_RESUME_PENDING

=back

=item ll_next_obj

	$job=ll_next_obj($query);

This returns the next object from the query object.

=item ll_free_objs

	$return=ll_free_objs($query);

This frees up the the space taken by the ll_get_objs routine for the LoadLeveler Data.  Since there is probably an awful lot of this this is a very important call.

=item ll_deallocate

	$return=ll_deallocate($query);

Frees the query object itself, this is the last LoadLeveler action.

=back

=head2 Submit API

The Submit API has one function:

=over 4

=item * llsubmit

=back

On successful submission this function returns a `perlised' version of the LL_job structure. See the llsubmit example and the LoadLeveler API header file llapi.h for full information on how to use it.  Currently the following LL_job_step structure members are not returned:

	usage_info64
	adapter_req

llfree_job_info is not implemented because it is done by in the llsubmit call after the data has been transfered to Perl.

A minimal example of using the Submit API is:

	use IBM::LoadLeveler;

	my ($job_name,$owner,$group,$uid,$gid,$host,$steps,$job_step)=llsubmit("/home/gmhk/test_job/test_job.cmd",NULL,NULL);

	print "Job Name   = $job_name\n";
	print "Owner      = $owner\n";
	print "Group      = $group\n";
	print "UID        = $uid\n";
	print "GID        = $gid\n";
	print "HOST       = $host\n";
	print "STEPS      = $steps\n";
	print "JOB_STEP   = $job_step\n";
	@steps=@{$job_step};
	print "JOB_STEP   = $#{$job_step}\n";
	foreach $stepref  (@steps)
	{
		%step=%{$stepref};
		print "STEP_NAME      = $step{'step_name'}\n";
		print "REQUIREMENTS   = $step{'requirements'}\n";
		%usage_info = %{$step{'usage_info'}};
		print "USAGE INFO     = --------------------\n";
		print "	STARTER_RUSAGE = $usage_info{'starter_rusage'}\n";
		%rusage=%{$usage_info{'starter_rusage'}};
		print "		RU_UTIME  = $rusage{'ru_utime'}\n";
		print "		RU_MAXRSS = $rusage{'ru_maxrss'}\n";
		print "	STEP_RUSAGE    = $usage_info{'step_rusage'}\n";
		print "	MACH_USAGE ITEMS = $#{$usage_info{'mach_usage'}}\n";
	}

=over 4

=item llsubmit

	($job_name,$owner,$groupname,$uid,$gid,$submit_host,$numsteps,$ref)=llsubmit($job_cmd_file,$monitor_program,$monitor_args);

B<Parameters>

=over 4

=item * $job_cmd_file

A string containing the name of the Job Command File

=item * $monitor_program

Is a pointer to a string containing the name of the monitor program to be invoked when the state of the job is changed. Set to NULL if a monitoring program is not provided.

=item * $monitor_args

Is a pointer to a string which is stored in the job object and is passed to the monitor program. The maximum length of the string is 1023 bytes. If the length exceeds this value, it is truncated to 1023 bytes. Set to NULL if an argument is not provided.

=back

B<Return>

=over 4

=item * $job_name

=item * $owner

=item * $groupname

=item * $uid

=item * $gid

=item * $submit_host

=item * $numsteps

=item * $ref

$ref is a reference to an array of job step information, each job step is a hash, the key is the name of the element in the LL_job_step structure, eg:

	@steps = @{$ref};
	foreach $stepref ( @steps )
	{
		%step=%{stepref};
		print "STEP_NAME      = $step{'step_name'}\n";
		print "REQUIREMENTS   = $step{'requirements'}\n";
		print "PREFERENCES    = $step{'preferences'}\n";
	}

=back

=back

=head2 Query API

B<The Query API has been deprecated by IBM.>

The Query API has the following functions:

=over 4

=item ll_get_jobs

=item ll_get_nodes

=back

=over 4

=item ll_get_jobs

The return from ll_get_jobs is a perlized version of the LL_job structure.  In perl terms it is a horror, this is how to decode the infoirmation for one step.

	# -*- Perl -*-

	# Use ll_get_jobs to print out information about one job

	use IBM::LoadLeveler;

	my ($version_num,$numjobs,$ref)=ll_get_jobs();

	print "Version           : $version_num\n";
	print "Number of Jobs    : $numjobs\n";
	print "----------------------------------------\n";

	@jobs=@{$ref};

	# Get The reference to the first Job

	$job=pop @jobs;

	# Get The Job information
	my($job_name,$owner,$groupname,$uid,$gid,$submit_host,$job_steps,$job_step)=@{$job};

	print "Job Name          : $job_name\n";
	print "Owner             : $owner\n";
	print "Group Name        : $groupname\n";
	print "UID               : $uid\n";
	print "GID               : $gid\n";
	print "Submit Host       : $submit_host\n";
	print "Number of Steps   : $job_steps\n";
	print "----------------------------------------\n";

	# Print Information about first Job Step

	$ref = pop @{$job_step};
	%step= %{$ref};

	print "Step Name         : $step{'step_name'}\n";
	print "Requirements      : $step{'requirements'}\n";
	print "Preferences       : $step{'preferences'}\n";
	print "User Step Pri     : $step{'prio'}\n";
	print "Step Dependency   : $step{'dependency'}\n";
	print "Group Name        : $step{'group_name'}\n";
	print "Step Class        : $step{'stepclass'}\n";
	print "Start Date        : ", scalar localtime($step{'start_date'}),"\n";
	print "Step Flags        : $step{'flags'}\n";
	print "Minimum # Procs   : $step{'min_processors'}\n";
	print "Maximum # Procs   : $step{'max_processors'}\n";
	print "Account Number    : $step{'account_no'}\n";
	print "User Comment      : $step{'comment'}\n";
	print "Step ID           : @{$step{'id'}}\n";
	print "Submit Date       : ", scalar localtime($step{'q_date'}),"\n";
	print "Status            : $step{'status'}\n";
	print "Actual # Procs    : $step{'num_processors'}\n";
	print "Assigned Procs    : @{$step{'processor_list'}}\n";
	print "Command           : $step{'cmd'}\n";
	print "Arguments         : $step{'args'}\n";
	print "Environment       : $step{'env'}\n";
	print "stdin             : $step{'in'}\n";
	print "stdout            : $step{'out'}\n";
	print "stderr            : $step{'err'}\n";
	print "Initial Dir       : $step{'iwd'}\n";
	print "Notify User       : $step{'notify_user'}\n";
	print "Shell             : $step{'shell'}\n";
	print "Command           : $step{'cmd'}\n";
	print "User Tracker Exit : $step{'tracker'}\n";
	print "Tracker Args      : $step{'tracker_arg'}\n";
	print "Notification      : $step{'notification'}\n";
	print "Image Size        : $step{'image_size'}\n";
	print "Executable Size   : $step{'exec_size'}\n";
	print "Step Res Limits   : @{$step{'limits'}}\n";
	print "NQS Info          : @{$step{'nqs_info'}}\n";
	print "Dispatch Date     : ", scalar localtime($step{'dispatch_time'}),"\n";
	print "Start Time        : $step{'start_time'}\n";
	print "Completion Code   : $step{'completion_code'}\n";
	print "Completion Date   : ", scalar localtime($step{'completion_date'}),"\n";
	print "Start Count       : $step{'start_count'}\n";
	%usage_info = %{$step{'usage_info'}};
	print "Starter rusage  ru_utime    : @{$usage_info{'starter_rusage'}{'ru_utime'}}\n";
	print "Starter rusage  ru_stime    : @{$usage_info{'starter_rusage'}{'ru_stime'}}\n";
	print "Starter rusage  ru_maxrss   : $usage_info{'starter_rusage'}{'ru_maxrss'}\n";
	print "Starter rusage  ru_ixrss    : $usage_info{'starter_rusage'}{'ru_ixrss'}\n";
	print "Starter rusage  ru_majflt   : $usage_info{'starter_rusage'}{'ru_majflt'}\n";
	print "Starter rusage  ru_nswap    : $usage_info{'starter_rusage'}{'ru_nswap'}\n";
	print "Starter rusage  ru_maxrss   : $usage_info{'starter_rusage'}{'ru_maxrss'}\n";
	print "Starter rusage  ru_inblock  : $usage_info{'starter_rusage'}{'ru_inblock'}\n";
	print "Starter rusage  ru_oublock  : $usage_info{'starter_rusage'}{'ru_oublock'}\n";
	print "Starter rusage  ru_msgsnd   : $usage_info{'starter_rusage'}{'ru_msgsnd'}\n";
	print "Starter rusage  ru_msgrcv   : $usage_info{'starter_rusage'}{'ru_msgrcv'}\n";
	print "Starter rusage  ru_nsignals : $usage_info{'starter_rusage'}{'ru_nsignals'}\n";
	print "Starter rusage  ru_nvcsw    : $usage_info{'starter_rusage'}{'ru_nvcsw'}\n";
	print "Starter rusage  ru_nivcsw   : $usage_info{'starter_rusage'}{'ru_nivcsw'}\n";
	print "Step rusage  ru_utime       : @{$usage_info{'step_rusage'}{'ru_utime'}}\n";
	print "Step rusage  ru_stime       : @{$usage_info{'step_rusage'}{'ru_stime'}}\n";
	print "Step rusage  ru_maxrss      : $usage_info{'step_rusage'}{'ru_maxrss'}\n";
	print "Step rusage  ru_ixrss       : $usage_info{'step_rusage'}{'ru_ixrss'}\n";
	print "Step rusage  ru_majflt      : $usage_info{'step_rusage'}{'ru_majflt'}\n";
	print "Step rusage  ru_nswap       : $usage_info{'step_rusage'}{'ru_nswap'}\n";
	print "Step rusage  ru_maxrss      : $usage_info{'step_rusage'}{'ru_maxrss'}\n";
	print "Step rusage  ru_inblock     : $usage_info{'step_rusage'}{'ru_inblock'}\n";
	print "Step rusage  ru_oublock     : $usage_info{'step_rusage'}{'ru_oublock'}\n";
	print "Step rusage  ru_msgsnd      : $usage_info{'step_rusage'}{'ru_msgsnd'}\n";
	print "Step rusage  ru_msgrcv      : $usage_info{'step_rusage'}{'ru_msgrcv'}\n";
	print "Step rusage  ru_nsignals    : $usage_info{'step_rusage'}{'ru_nsignals'}\n";
	print "Step rusage  ru_nvcsw       : $usage_info{'step_rusage'}{'ru_nvcsw'}\n";
	print "Step rusage  ru_nivcsw      : $usage_info{'step_rusage'}{'ru_nivcsw'}\n";
	$first_mach_usage_info = $#{$usage_info{'mach_usage'}};
	print "Step machine Usage          : $first_mach_usage_info\n";

	print "User System Prio  : $step{'user_sysprio'}\n";
	print "Group System Prio : $step{'group_sysprio'}\n";
	print "Class System Prio : $step{'class_sysprio'}\n";
	print "User Number       : $step{'number'}\n";
	print "CPUS requested    : $step{'cpus_requested'}\n";
	print "Virutal Mem Req   : $step{'virtual_memory_requested'}\n";
	print "Memory Requested  : $step{'memory_requested'}\n";
	print "Adapter Used mem  : $step{'adapter_used_memory'}\n";
	print "Adapter Reg count : $step{'adapter_req_count'}\n";

	print "Image Size        : $step{'image_size64'}\n";
	print "Executable Size   : $step{'exec_size64'}\n";
	print "Step Res Limits   : @{$step{'limits64'}}\n";
	print "Virutal Mem Req   : $step{'virtual_memory_requested64'}\n";
	print "Memory Requested  : $step{'memory_requested64'}\n";

	print "Last Checkpoint   : $step{'good_ckpt_start_time'}\n";
	print "Time Spent ckpting: $step{'accum_ckpt_time'}\n";
	print "Checkpoint Dir    : $step{'ckpt_dir'}\n";
	print "Checkpoint File   : $step{'ckpt_file'}\n";
	print "Large Page Req    : $step{'large_page'}\n";

=item ll_get_nodes

ll_get_nodes is almost as bad as ll_get_jobs.  The following is an example of decoding the data returned:

	# -*- Perl -*-

	use IBM::LoadLeveler;

	# Use the deprecated ll_get_nodes call to find information on all nodes in the system
	# similar to llstatus -l

	my ($version_num,$numnodes,$ref)=ll_get_nodes();

	print "LoadLeveler Version  : $version_num\n";
	print "Number of Nodes      : $numnodes\n";

	@nodes=@{$ref};

	foreach $node (@nodes)
	{
	    my($node_name,$version,$configtimestamp,$timestamp,$vmem,$memory,$disk,$loadavg,$speed,$max_starters,$pool,$cpus,$state,$keywordidle,$totaljobs,$arch,$opsys,$adapters,$feature,$job_class,$initiators,$steplist,$vmem64,$memory64,$disk64)=@{$node};
	    print "----------------------------------------\n";
	    print "Node Name            : $node_name\n";
	    print "Proc Version         : $version\n";
	    print "Date of reconfig     : ",scalar localtime $configtimestamp,"\n";
	    print "Data timestamp       : ",scalar localtime $timestamp,"\n";
	    print "Virtual Memory (KB)  : $vmem\n";
	    print "Physical Memory (KB) : $memory\n";
	    print "Avail Disk Space (KB): $disk\n";
	    print "Load Avgerage        : $loadavg\n";
	    print "Node Speed           : $speed\n";
	    print "Max Jobs allowed     : $max_starters\n";
	    print "Pool Number          : $pool\n";
	    print "Number of CPUs       : $cpus\n";
	    print "Startd state         : $state\n";
	    print "Since keyboard active: $keywordidle\n";
	    print "Total jobs           : $totaljobs\n";
	    print "Hardware Architecture: $arch\n";
	    print "Operating System     : $opsys\n";
	    print "Available Adapters   : @{$adapters}\n";
	    print "Available Features   : @{$feature}\n";

	    %classes=();
	    foreach $class (  @{$job_class} )
	    {
	        $classes{$class}++;
	    }
	    print "Job Classes Allowed  : ";
	    foreach $class ( keys %classes )
	    {
	        print "$class\($classes{$class}\) ";
	    }
	    print "\n";

	    %classes=();
	    foreach $class (  @{$initiators} )
	    {
	        $classes{$class}++;
	    }
	    print "Initiators Available : ";
	    foreach $class ( keys %classes )
	    {
	        print "$class\($classes{$class}\) ";
	    }
	    print "\n";
	
	    @steps=@{$steplist};
	    print "Steps Allocated      : ";
	    if ( $#steps < 0 )
	    {
	        print "None.";
	    }
	    else
	    {
	        foreach $step ( @steps )
	        {
	            @id=@{$step};
	            print "$id[2].$id[0].$id[1] ";
	        }
	    }
	    print "\n";
	    print "Virtual Memory (KB)  : $vmem64\n";
	    print "Physical Memory (KB) : $memory64\n";
	    print "Avail Disk Space (KB): $disk64\n";
	}

=back

=head2 WorkLoad Management API

The Workload Management API has the following functions:

=over 4

=item ll_control

=item llctl

=item llfavorjob

=item llfavoruser

=item llhold

=item llprio

=item ll_preempt

=item ll_start_job

=item ll_terminate_job

The C<llctl, llfavorjob, llfavoruser, llhold & llprio> functions are all really wrappers for ll_control.

B<The functions ll_start_job & ll_trermiate_job are designed for people wanting to produce an external scheduler, they are totally untested in this module.>

=back


=head2 64 bit types and 32 bit perl

B<ll_get_data> has a whole set of 64 bit return types, this poses a problem for perl when it is compiled in 32 bit mode.  This module will return correct values if the value is than 2^31 otherwise the value will be truncated to 2^31..

=head2 Build/Installation

The module currently relies on the llapi.h file supplied with LoadLeveler for definitions of constants.  The make file automatically processes the llapi.h file into a llapi.ph file and installs it as part of the build process.

You will probably need to edit Makefile.PL to change the value of $LoadL to point to where LoadLeveler is installed

Standard build/installation supported by ExtUtils::MakeMaker(3)...

        perl Makefile.PL
        make
        make test
        make install

To convert the pod documentation (what there is of it) to html:

	make html

=head1 Known Problems

=head2 Large History files

This module has been observed to crash when given a history file of >92MB and <132MB ( the killer value is probably 128MB ).

B<Workaround>

The solution is to increase the bmaxdata value of the Perl executable. If you are using the installp version of perl it is recommended to copy the executable to another directory, and modify using ldedit to increase the number of data
segments.

        cp /usr/opt/perl/bin/perl /global/bin/llperl
        /usr/bin/ldedit -o bmaxdata:0x20000000 /global/bin/llperl

Then modify any scripts that have exhibited this behaviour to use the new
executable. If this fails then increase the bmaxdata value until successful.

=head1 AUTHOR

Mike Hawkins <Mike.Hawkins@awe.co.uk>

=head1 SEE ALSO

L<perl>.
IBM LoadLeveler for AIX 5L: Using and Administering

=cut

sub llctl()
{
    my ($operation,$class_list_ref,$host_list_ref)=@_;

    if ( $operation != LL_CONTROL_START &&
	 $operation != LL_CONTROL_STOP &&
	 $operation != LL_CONTROL_RECYCLE &&
	 $operation != LL_CONTROL_RECONFIG &&
	 $operation != LL_CONTROL_DRAIN &&
	 $operation != LL_CONTROL_DRAIN_SCHEDD &&
	 $operation != LL_CONTROL_DRAIN_STARTD &&
	 $operation != LL_CONTROL_FLUSH &&
	 $operation != LL_CONTROL_PURGE_SCHEDD &&
	 $operation != LL_CONTROL_SUSPEND &&
	 $operation != LL_CONTROL_RESUME &&
	 $operation != LL_CONTROL_RESUME_STARTD &&
	 $operation != LL_CONTROL_RESUME_SCHEDD)
    {
	croak "unrecognized option for llctl";
	return undef;
    }
    else
    {
	return ll_control($operation,$host_list_ref,NULL,NULL,$host_list_ref,0);
    }
}

sub llfavorjob()
{
    my ($operation,$job_list_ref)=@_;

    if ( $operation != LL_CONTROL_FAVOR_JOB &&
	 $operation != LL_CONTROL_UNFAVOR_JOB)
    {
	croak "unrecognized option for llfavorjob";
	return undef;
    }
    else
    {
	return ll_control($operation,NULL,NULL,$job_list_ref,NULL,0);
    }
}
sub llfavoruser()
{
    my ($operation,$user_list_ref)=@_;

    if ( $operation != LL_CONTROL_FAVOR_USER &&
	 $operation != LL_CONTROL_UNFAVOR_USER)
    {
	croak "unrecognized option for llfavorjob";
	return undef;
    }
    else
    {
	return ll_control($operation,NULL,$user_list_ref,NULL,NULL,0);
    }
}

sub llhold()
{
    my ($operation,$host_list_ref,$user_list_ref,$job_list_ref)=@_;

    if ( $operation != LL_CONTROL_HOLD_USER &&
	 $operation != LL_CONTROL_HOLD_SYSTEM &&
	 $operation != LL_CONTROL_HOLD_RELEASE )
    {
	croak "unrecognized option for llhold";
	return undef;
    }
    else
    {
	return ll_control($operation,$host_list_ref,$user_list_ref,$job_list_ref,NULL,0);
    }
}

sub llprio()
{
    my ($operation,$job_list_ref,$priority)=@_;

    if ( $operation != LL_CONTROL_PRIO_ABS &&
	 $operation != LL_CONTROL_PRIO_ADJ )
    {
	croak "unrecognized option for llprio";
	return undef;
    }
    else
    {
	return ll_control($operation,NULL,NULL,$job_list_ref,NULL,$priority);
    }
}
