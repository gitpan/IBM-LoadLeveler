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

require 'IBM/llapi.ph';

our @EXPORT = qw(
	JOBS MACHINES PERF CLUSTERS WLMSTAT MATRIX CLASSES

	QUERY_ALL       QUERY_JOBID   QUERY_STEPID QUERY_USER
	QUERY_GROUP     QUERY_CLASS   QUERY_HOST   QUERY_PERF
	QUERY_STARTDATE QUERY_ENDDATE QUERY_PROCID

	ALL_DATA STATUS_LINE Q_LINE

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
	LL_CONTROL_START_DRAINED

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
	ll_modify
	llprio
	ll_preempt
	ll_start_job
	ll_terminate_job

	ll_error

	LL_ClassName
	LL_ClassPriority
	LL_ClassExcludeUsers
	LL_ClassIncludeUsers
	LL_ClassExcludeGroups
	LL_ClassIncludeGroups
	LL_ClassAdmin
	LL_ClassNqsClass
	LL_ClassNqsSubmit
	LL_ClassNqsQuery
	LL_ClassMaxProcessors
	LL_ClassMaxJobs
	LL_ClassGetFirstResourceRequirement
	LL_ClassGetNextResourceRequirement
	LL_ClassComment
	LL_ClassCkptDir
	LL_ClassCkptTimeHardLimit
	LL_ClassCkptTimeSoftLimit
	LL_ClassWallClockLimitHard
	LL_ClassWallClockLimitSoft
	LL_ClassCpuStepLimitHard
	LL_ClassCpuStepLimitSoft
	LL_ClassCpuLimitHard
	LL_ClassCpuLimitSoft
	LL_ClassDataLimitHard
	LL_ClassDataLimitSoft
	LL_ClassCoreLimitHard
	LL_ClassCoreLimitSoft
	LL_ClassFileLimitHard
	LL_ClassFileLimitSoft
	LL_ClassStackLimitHard
	LL_ClassStackLimitSoft
	LL_ClassRssLimitHard
	LL_ClassRssLimitSoft
	LL_ClassNice
	LL_ClassFreeSlots
	LL_ClassMaximumSlots
	LL_ClassConstraints
	LL_ClassExecutionFactor
	LL_ClassMaxTotalTasks
	LL_ClassPreemptClass
	LL_ClassStartClass
	LL_ClassMaxProtocolInstances

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
	LL_StepHostList
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
	LL_AdapterUsageDevice
	LL_AdapterUsageWindow
	LL_AdapterUsageProtocol
	LL_AdapterUsageTag
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
our $VERSION = '1.00';

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
	 $operation != LL_CONTROL_RESUME_SCHEDD &&
	 $operation != LL_CONTROL_START_DRAINED )
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
