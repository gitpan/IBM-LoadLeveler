/* -*- C -*-  */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <llapi.h>

/* 
 * Macro to make code a bit more readable.
 * IV_MAX is the maximum that Perl can get into a scalar integer
 * This is basically checking a 64 bit value, and truncating it to 
 * 32 bits on a 32 bit compile.
 */

#define CHECK64(a)	a > IV_MAX ? (long)IV_MAX : (long)a

AV *
unpack_ll_step_id(id)
    LL_STEP_ID *id;
{
    AV *array;

    array=(AV *)sv_2mortal((SV *)newAV());
    av_push(array,newSViv((long)id->cluster));
    av_push(array,newSViv((long)id->proc));
    av_push(array,newSVpv(id->from_host,0));
    return(array);
}

/*
 * Convert an rusage struct into a hash
 *
 */

HV *
unpack_rusage(usage)
    struct rusage *usage;
{
    HV *hash;
    AV *timet;

    hash=(HV *)sv_2mortal((SV *)newHV());

    timet=(AV *)sv_2mortal((SV *)newAV());
    av_push(timet,newSViv((long)usage->ru_utime.tv_sec));
    av_push(timet,newSViv((long)usage->ru_utime.tv_usec));
    hv_store(hash,"ru_utime",strlen("ru_utime"),(newRV((SV*)timet)),0);

    timet=(AV *)sv_2mortal((SV *)newAV());
    av_push(timet,newSViv((long)usage->ru_stime.tv_sec));
    av_push(timet,newSViv((long)usage->ru_stime.tv_usec));
    hv_store(hash,"ru_stime",strlen("ru_stime"),(newRV((SV*)timet)),0);

    hv_store(hash,"ru_maxrss",strlen("ru_maxrss"),(newSViv((long)usage->ru_maxrss)),0);
    hv_store(hash,"ru_ixrss",strlen("ru_ixrss"),(newSViv((long)usage->ru_ixrss)),0);
    hv_store(hash,"ru_idrss",strlen("ru_idrss"),(newSViv((long)usage->ru_idrss)),0);
    hv_store(hash,"ru_isrss",strlen("ru_isrss"),(newSViv((long)usage->ru_isrss)),0);
    hv_store(hash,"ru_majflt",strlen("ru_majflt"),(newSViv((long)usage->ru_majflt)),0);
    hv_store(hash,"ru_nswap",strlen("ru_nswap"),(newSViv((long)usage->ru_nswap)),0);
    hv_store(hash,"ru_inblock",strlen("ru_inblock"),(newSViv((long)usage->ru_inblock)),0);
    hv_store(hash,"ru_oublock",strlen("ru_oublock"),(newSViv((long)usage->ru_oublock)),0);
    hv_store(hash,"ru_msgsnd",strlen("ru_msgsnd"),(newSViv((long)usage->ru_msgsnd)),0);
    hv_store(hash,"ru_msgrcv",strlen("ru_msgrcv"),(newSViv((long)usage->ru_msgrcv)),0);
    hv_store(hash,"ru_nsignals",strlen("ru_nsignals"),(newSViv((long)usage->ru_nsignals)),0);
    hv_store(hash,"ru_nvcsw",strlen("ru_nvcsw"),(newSViv((long)usage->ru_nvcsw)),0);
    hv_store(hash,"ru_nivcsw",strlen("ru_nvicsw"),(newSViv((long)usage->ru_nivcsw)),0);

    return(hash);
}

HV *
unpack_event_usage(event)
    LL_EVENT_USAGE *event;
{
    HV *hash;
    hash=(HV *)sv_2mortal((SV *)newHV());

    hv_store(hash,"event",strlen("event"),(newSViv((long)event->event)),0);
    hv_store(hash,"name",strlen("name"),(newSVpv(event->name,0)),0);
    hv_store(hash,"time",strlen("time"),(newSViv((long)event->time)),0);
    hv_store(hash,"starter_rusage",strlen("starter_rusage"),(newRV((SV *)unpack_rusage(&event->starter_rusage))),0);
    hv_store(hash,"step_rusage",strlen("step_rusage"),(newRV((SV *)unpack_rusage(&event->step_rusage))),0);
    return(hash);
}


HV *
unpack_dispatch_usage(dispatch)
    LL_DISPATCH_USAGE *dispatch;
{
    HV *hash;
    AV *array;
    int i;
    LL_EVENT_USAGE	*ptr;

    hash=(HV *)sv_2mortal((SV *)newHV());

    hv_store(hash,"dispatch_num",strlen("dispatch_num"),(newSViv((long)dispatch->dispatch_num)),0);
    hv_store(hash,"starter_rusage",strlen("starter_rusage"),(newRV((SV *)unpack_rusage(&dispatch->starter_rusage))),0);
    hv_store(hash,"step_rusage",strlen("step_rusage"),(newRV((SV *)unpack_rusage(&dispatch->step_rusage))),0);
    array=(AV *)sv_2mortal((SV *)newAV());
    i=0;
    ptr=dispatch->event_usage;
    while (ptr != NULL)
    {     
	av_push( array,newRV((SV *)unpack_event_usage(ptr)));
	ptr=ptr->next;
    }
    hv_store(hash,"event_usage",strlen("event_usage"),newRV((SV *)array),0);

    return(hash);

}

HV *
unpack_mach_usage(mach)
    LL_MACH_USAGE *mach;
{
    HV *hash;
    AV *array;
    int i;
    LL_DISPATCH_USAGE	*ptr;

    hash=(HV *)sv_2mortal((SV *)newHV());

    hv_store(hash,"name",strlen("name"),(newSVpv(mach->name,0)),0);
    hv_store(hash,"machine_speed",strlen("machine_speed"),(newSVnv((long)mach->machine_speed)),0);
    hv_store(hash,"dispatch_num",strlen("dispatch_num"),(newSViv((long)mach->dispatch_num)),0);
    array=(AV *)sv_2mortal((SV *)newAV());
    i=0;
    ptr=mach->dispatch_usage;
    while (ptr != NULL)
    {     
	av_push( array,newRV((SV *)unpack_dispatch_usage(ptr)));
	ptr=ptr->next;
    }
    hv_store(hash,"dispatch_usage",strlen("dispatch_usage"),newRV((SV *)array),0);
    return(hash);

}

HV *
unpack_ll_usage(usage)
    LL_USAGE *usage;
{
    HV *hash;
    AV *array;
    LL_MACH_USAGE	*ptr;

    hash=(HV *)sv_2mortal((SV *)newHV());

    hv_store(hash,"starter_rusage",strlen("starter_rusage"),(newRV((SV *)unpack_rusage(&usage->starter_rusage))),0);
    hv_store(hash,"step_rusage",strlen("step_rusage"),(newRV((SV *)unpack_rusage(&usage->step_rusage))),0);
    array=(AV *)sv_2mortal((SV *)newAV());
    ptr=usage->mach_usage;
    while (ptr != NULL)
    {     
	av_push( array,newRV((SV *)unpack_mach_usage(ptr)));
	ptr=ptr->next;
    }
    hv_store(hash,"mach_usage",strlen("mach_usage"),newRV((SV *)array),0);

    return(hash);

}

/*
 * Convert an LL_job_step structure into a perl hash.
 */

HV *
unpack_job_step( job_info )
LL_job_step	*job_info;

{
    HV *step;
    AV *nqs_info,*limits,*processor_list,*limits64;
    int t;

    step=(HV *)sv_2mortal((SV *)newHV());
    hv_store(step,"step_name",strlen("step_name"),(newSVpv(job_info->step_name,0)),0);
    hv_store(step,"requirements",strlen("requirements"),(newSVpv(job_info->requirements,0)),0);
    hv_store(step,"preferences",strlen("preferences"),(newSVpv(job_info->preferences,0)),0);
    hv_store(step,"prio",strlen("prio"),(newSViv((long)job_info->prio)),0);
    hv_store(step,"dependency",strlen("dependency"),(newSVpv(job_info->dependency,0)),0);
    hv_store(step,"group_name",strlen("group_name"),(newSVpv(job_info->group_name,0)),0);
    hv_store(step,"stepclass",strlen("stepclass"),(newSVpv(job_info->stepclass,0)),0);
    hv_store(step,"start_date",strlen("start_date"),(newSViv((long)job_info->start_date)),0);
    hv_store(step,"flags",strlen("flags"),(newSViv((long)job_info->flags)),0);
    hv_store(step,"min_processors",strlen("min_processors"),(newSViv((long)job_info->min_processors)),0);
    hv_store(step,"max_processors",strlen("max_processors"),(newSViv((long)job_info->max_processors)),0);
    hv_store(step,"account_no",strlen("account_no"),(newSVpv(job_info->account_no,0)),0);
    hv_store(step,"comment",strlen("comment"),(newSVpv(job_info->comment,0)),0);
    
    hv_store(step,"id",strlen("id"),newRV((SV *)unpack_ll_step_id(&job_info->id)),0);
    
    hv_store(step,"q_date",strlen("q_date"),(newSViv((long)job_info->q_date)),0);
    hv_store(step,"status",strlen("status"),(newSViv((long)job_info->status)),0);
    hv_store(step,"num_processors",strlen("num_processors"),(newSViv((long)job_info->num_processors)),0);
    
    processor_list=(AV *)sv_2mortal((SV *)newAV());
    for(t=0;t!=job_info->num_processors;t++)
	{     
	    av_push( processor_list, newSVpv( job_info->processor_list[t], 0 ) );
	}
    hv_store(step,"processor_list",strlen("processor_list"),newRV((SV *)processor_list),0);
    
    hv_store(step,"cmd",strlen("cmd"),(newSVpv(job_info->cmd,0)),0);
    hv_store(step,"args",strlen("args"),(newSVpv(job_info->args,0)),0);
    hv_store(step,"env",strlen("env"),(newSVpv(job_info->env,0)),0);
    hv_store(step,"in",strlen("in"),(newSVpv(job_info->in,0)),0);
    hv_store(step,"out",strlen("out"),(newSVpv(job_info->out,0)),0);
    hv_store(step,"err",strlen("err"),(newSVpv(job_info->err,0)),0);
    hv_store(step,"iwd",strlen("iwd"),(newSVpv(job_info->iwd,0)),0);
    hv_store(step,"notify_user",strlen("notify_user"),(newSVpv(job_info->notify_user,0)),0);
    hv_store(step,"shell",strlen("shell"),(newSVpv(job_info->shell,0)),0);
    hv_store(step,"tracker",strlen("tracker"),(newSVpv(job_info->tracker,0)),0);
    hv_store(step,"tracker_arg",strlen("tracker_arg"),(newSVpv(job_info->tracker_arg,0)),0);
    hv_store(step,"notification",strlen("notification"),(newSViv((long)job_info->notification)),0);
    hv_store(step,"image_size",strlen("image_size"),(newSViv((long)job_info->image_size)),0);
    hv_store(step,"exec_size",strlen("exec_size"),(newSViv((long)job_info->exec_size)),0);
    
    limits=(AV *)sv_2mortal((SV *)newAV());
    av_push(limits,newSViv((long)job_info->limits.cpu_hard_limit));
    av_push(limits,newSViv((long)job_info->limits.cpu_soft_limit));
    av_push(limits,newSViv((long)job_info->limits.data_hard_limit));
    av_push(limits,newSViv((long)job_info->limits.data_soft_limit));
    av_push(limits,newSViv((long)job_info->limits.core_hard_limit));
    av_push(limits,newSViv((long)job_info->limits.core_soft_limit));
    av_push(limits,newSViv((long)job_info->limits.file_hard_limit));
    av_push(limits,newSViv((long)job_info->limits.file_soft_limit));
    av_push(limits,newSViv((long)job_info->limits.rss_hard_limit));
    av_push(limits,newSViv((long)job_info->limits.rss_soft_limit));
    av_push(limits,newSViv((long)job_info->limits.stack_hard_limit));
    av_push(limits,newSViv((long)job_info->limits.stack_soft_limit));
    av_push(limits,newSViv((long)job_info->limits.hard_cpu_step_limit));
    av_push(limits,newSViv((long)job_info->limits.soft_cpu_step_limit));
    av_push(limits,newSViv((long)job_info->limits.hard_wall_clock_limit));
    av_push(limits,newSViv((long)job_info->limits.soft_wall_clock_limit));
    av_push(limits,newSViv((long)job_info->limits.ckpt_time_hard_limit));
    av_push(limits,newSViv((long)job_info->limits.ckpt_time_soft_limit));
    hv_store(step,"limits",strlen("limits"),newRV((SV *)limits),0);
    
    nqs_info=(AV *)sv_2mortal((SV *)newAV());
    av_push(nqs_info,newSViv((long)job_info->nqs_info.nqs_flags));
    av_push(nqs_info,newSVpv(job_info->nqs_info.nqs_submit,0));
    av_push(nqs_info,newSVpv(job_info->nqs_info.nqs_query,0));
    av_push(nqs_info,newSVpv(job_info->nqs_info.umask,0));
    hv_store(step,"nqs_info",strlen("nqs_info"),newRV((SV *)nqs_info),0);
    
    hv_store(step,"dispatch_time",strlen("dispatch_time"),(newSViv((long)job_info->dispatch_time)),0);
    hv_store(step,"start_time",strlen("start_time"),(newSViv((long)job_info->start_time)),0);
    hv_store(step,"completion_code",strlen("completion_code"),(newSViv((long)job_info->completion_code)),0);
    hv_store(step,"completion_date",strlen("completion_date"),(newSViv((long)job_info->completion_date)),0);
    hv_store(step,"start_count",strlen("start_count"),(newSViv((long)job_info->start_count)),0);
    hv_store(step,"usage_info",strlen("usage_info"),(newRV((SV *)unpack_ll_usage(&job_info->usage_info))),0);
    hv_store(step,"user_sysprio",strlen("user_sysprio"),(newSViv((long)job_info->user_sysprio)),0);
    hv_store(step,"group_sysprio",strlen("group_sysprio"),(newSViv((long)job_info->group_sysprio)),0);
    hv_store(step,"class_sysprio",strlen("class_sysprio"),(newSViv((long)job_info->class_sysprio)),0);
    hv_store(step,"number",strlen("number"),(newSViv((long)job_info->number)),0);
    hv_store(step,"cpus_requested",strlen("cpus_requested"),(newSViv((long)job_info->cpus_requested)),0);
    hv_store(step,"virtual_memory_requested",strlen("virtual_memory_requested"),(newSViv((long)job_info->virtual_memory_requested)),0);
    hv_store(step,"memory_requested",strlen("memory_requested"),(newSViv((long)job_info->memory_requested)),0);
    hv_store(step,"adapter_used_memory",strlen("adapter_used_memory"),(newSViv((long)job_info->adapter_used_memory)),0);
    hv_store(step,"adapter_req_count",strlen("adapter_req_count"),(newSViv((long)job_info->adapter_req_count)),0);
/*  void  **adapter_req;  adapter requirements - step->getFirstAdapterReq() ...  */
    
 
    hv_store(step,"image_size64",strlen("image_size64"),(newSViv(CHECK64(job_info->image_size64))),0);
    hv_store(step,"exec_size64",strlen("exec_size64"),(newSViv(CHECK64(job_info->exec_size64))),0);
    hv_store(step,"virtual_memory_requested64",strlen("virtual_memory_requested64"),(newSViv(CHECK64(job_info->virtual_memory_requested64))),0);
    hv_store(step,"memory_requested64",strlen("memory_requested64"),(newSViv(CHECK64(job_info->memory_requested64))),0);
    limits64=(AV *)sv_2mortal((SV *)newAV());
    av_push(limits64,newSViv(CHECK64(job_info->limits64.cpu_hard_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.cpu_soft_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.data_hard_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.data_soft_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.core_hard_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.core_soft_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.file_hard_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.file_soft_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.rss_hard_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.rss_soft_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.stack_hard_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.stack_soft_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.hard_cpu_step_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.soft_cpu_step_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.hard_wall_clock_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.soft_wall_clock_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.ckpt_time_hard_limit)));
    av_push(limits64,newSViv(CHECK64(job_info->limits64.ckpt_time_soft_limit)));
    hv_store(step,"limits64",strlen("limits64"),newRV((SV *)limits64),0);
    
    hv_store(step,"good_ckpt_start_time",strlen("good_ckpt_start_time"),(newSViv((long)job_info->good_ckpt_start_time)),0);
    hv_store(step,"accum_ckpt_time",strlen("accum_ckpt_time"),(newSViv((long)job_info->accum_ckpt_time)),0);
    hv_store(step,"ckpt_dir",strlen("ckpt_dir"),(newSVpv(job_info->ckpt_dir,0)),0);
    hv_store(step,"ckpt_file",strlen("ckpt_file"),(newSVpv(job_info->ckpt_file,0)),0);
    hv_store(step,"large_page",strlen("large_page"),(newSVpv(job_info->large_page,0)),0);
    return(step);
}


AV *
unpack_ll_job(job)
LL_job    *job;
{
    AV *array,*steps;
    int i;

    array=(AV *)sv_2mortal((SV *)newAV());


    av_push(array,newSVpv(job->job_name, 0));
    av_push(array,newSVpv(job->owner, 0));
    av_push(array,newSVpv(job->groupname, 0));
    av_push(array,newSViv((long)job->uid));
    av_push(array,newSViv((long)job->gid));
    av_push(array,newSVpv(job->submit_host, 0));
    av_push(array,newSViv((long)job->steps));
    steps=(AV *)sv_2mortal((SV *)newAV());
    for(i=0;i!=job->steps;i++)
	{
	    HV *step;
	    
	    step=unpack_job_step(job->step_list[i]);
	    av_push(steps,newRV((SV *)step));
	}	
    av_push(array,newRV((SV *)steps));
    return(array);
}


AV *
unpack_ll_node(node)
LL_node    *node;
{
    AV *array,*list;
    int i;
    char *ptr;
    LL_STEP_ID *idptr;

    array=(AV *)sv_2mortal((SV *)newAV());

    av_push(array,newSVpv(node->nodename, 0));
    av_push(array,newSViv((long)node->version_num));
    av_push(array,newSViv((long)node->configtimestamp));
    av_push(array,newSViv((long)node->time_stamp));
    av_push(array,newSViv((long)node->virtual_memory));
    av_push(array,newSViv((long)node->memory));
    av_push(array,newSViv((long)node->disk));
    av_push(array,newSVnv(node->loadavg));
    av_push(array,newSViv(node->speed));
    av_push(array,newSViv((long)node->max_starters));
    av_push(array,newSViv((long)node->pool));
    av_push(array,newSViv((long)node->cpus));
    av_push(array,newSVpv(node->state, 0));
    av_push(array,newSViv((long)node->keywordidle));
    av_push(array,newSViv((long)node->totaljobs));
    av_push(array,newSVpv(node->arch, 0));
    av_push(array,newSVpv(node->opsys, 0));

    list=(AV *)sv_2mortal((SV *)newAV());
    ptr=node->adapter[0];
    i=0;
    while(ptr!=NULL)
    {     
	av_push( list, newSVpv( ptr, 0 ) );
	i++;
	ptr=node->adapter[i];
    }
    av_push(array,newRV((SV *)list));

    list=(AV *)sv_2mortal((SV *)newAV());
    ptr=node->feature[0];
    i=0;
    while(ptr!=NULL)
    {     
	av_push( list, newSVpv( ptr, 0 ) );
	i++;
	ptr=node->feature[i];
    }
    av_push(array,newRV((SV *)list));

    list=(AV *)sv_2mortal((SV *)newAV());
    ptr=node->job_class[0];
    i=0;
    while(ptr!=NULL)
    {     
	av_push( list, newSVpv( ptr, 0 ) );
	i++;
	ptr=node->job_class[i];

    }
    av_push(array,newRV((SV *)list));

    list=(AV *)sv_2mortal((SV *)newAV());
    ptr=node->initiators[0];
    i=0;
    while(ptr!=NULL)
    {     
	av_push( list, newSVpv( ptr, 0 ) );
	i++;
	ptr=node->initiators[i];
    }
    av_push(array,newRV((SV *)list));

/* LL_STEP_ID */
    list=(AV *)sv_2mortal((SV *)newAV());
    idptr=node->steplist;
    while (idptr->from_host != NULL )
    {
	av_push(list,newRV((SV *)unpack_ll_step_id(idptr)));
	idptr++;
    }
    av_push(array,newRV((SV *)list));

    av_push(array,newSViv(CHECK64(node->virtual_memory64)));
    av_push(array,newSViv(CHECK64(node->memory64)));
    av_push(array,newSViv(CHECK64(node->disk64)));
    return(array);
}

/* 
 * Convert a perl array ( assumed to be of strings ) into a C char ** array.
 * To do this we iterate over the array, malloc storage for the data and copy it into the C array
 * This Code is from the XS Cookbooks by Dead Roehrich ( CPAN authors/DEAN_Roehrich).
 */

char **
XS_unpack_charPtrPtr( rv )
SV *rv;
{
	AV *av;
	SV **ssv;
	char **s;
	int avlen;
	int x;
	unsigned long na;

	if ( ! SvOK( rv ) )
		return( (char**)NULL );

	if( SvROK( rv ) && (SvTYPE(SvRV(rv)) == SVt_PVAV) )
		av = (AV*)SvRV(rv);
	else {
		warn("XS_unpack_charPtrPtr: rv was not an AV ref");
		return( (char**)NULL );
	}

	/* is it empty? */
	avlen = av_len(av);
	if( avlen < 0 ){
		warn("XS_unpack_charPtrPtr: array was empty");
		return( (char**)NULL );
	}

	/* av_len+2 == number of strings, plus 1 for an end-of-array sentinel.
	 */
	s = (char **)safemalloc( sizeof(char*) * (avlen + 2) );
	if( s == NULL ){
		warn("XS_unpack_charPtrPtr: unable to malloc char**");
		return( (char**)NULL );
	}
	for( x = 0; x <= avlen; ++x ){
		ssv = av_fetch( av, x, 0 );
		if( ssv != NULL ){
			if( SvPOK( *ssv ) ){
				s[x] = (char *)safemalloc( SvCUR(*ssv) + 1 );
				if( s[x] == NULL )
					warn("XS_unpack_charPtrPtr: unable to malloc char*");
				else
					strcpy( s[x], SvPV( *ssv, na ) );
			}
			else
				warn("XS_unpack_charPtrPtr: array elem %d was not a string.", x );
		}
		else
			s[x] = (char*)NULL;
	}
	s[x] = (char*)NULL; /* sentinel */
	return( s );
}

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static double
constant_PARALLEL_N(char *name, int len, int arg)
{
    if (10 + 6 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[10 + 6]) {
    case 'C':
	if (strEQ(name + 10, "O_DCE_CRED")) {	/* PARALLEL_N removed */
#ifdef PARALLEL_NO_DCE_CRED
	    return PARALLEL_NO_DCE_CRED;
#else
	    goto not_there;
#endif
	}
    case 'I':
	if (strEQ(name + 10, "O_DCE_ID")) {	/* PARALLEL_N removed */
#ifdef PARALLEL_NO_DCE_ID
	    return PARALLEL_NO_DCE_ID;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_PARALLEL_CANT_G(char *name, int len, int arg)
{
    if (15 + 7 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[15 + 7]) {
    case 'L':
	if (strEQ(name + 15, "ET_HOSTLIST")) {	/* PARALLEL_CANT_G removed */
#ifdef PARALLEL_CANT_GET_HOSTLIST
	    return PARALLEL_CANT_GET_HOSTLIST;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (strEQ(name + 15, "ET_HOSTNAME")) {	/* PARALLEL_CANT_G removed */
#ifdef PARALLEL_CANT_GET_HOSTNAME
	    return PARALLEL_CANT_GET_HOSTNAME;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_PARALLEL_C(char *name, int len, int arg)
{
    if (10 + 4 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[10 + 4]) {
    case 'C':
	if (strEQ(name + 10, "ANT_CONNECT")) {	/* PARALLEL_C removed */
#ifdef PARALLEL_CANT_CONNECT
	    return PARALLEL_CANT_CONNECT;
#else
	    goto not_there;
#endif
	}
    case 'F':
	if (strEQ(name + 10, "ANT_FORK")) {	/* PARALLEL_C removed */
#ifdef PARALLEL_CANT_FORK
	    return PARALLEL_CANT_FORK;
#else
	    goto not_there;
#endif
	}
    case 'G':
	if (!strnEQ(name + 10,"ANT_", 4))
	    break;
	return constant_PARALLEL_CANT_G(name, len, arg);
    case 'M':
	if (strEQ(name + 10, "ANT_MAKE_SOCKET")) {	/* PARALLEL_C removed */
#ifdef PARALLEL_CANT_MAKE_SOCKET
	    return PARALLEL_CANT_MAKE_SOCKET;
#else
	    goto not_there;
#endif
	}
    case 'P':
	if (strEQ(name + 10, "ANT_PASS_SOCKET")) {	/* PARALLEL_C removed */
#ifdef PARALLEL_CANT_PASS_SOCKET
	    return PARALLEL_CANT_PASS_SOCKET;
#else
	    goto not_there;
#endif
	}
    case 'R':
	if (strEQ(name + 10, "ANT_RESOLVE_HOST")) {	/* PARALLEL_C removed */
#ifdef PARALLEL_CANT_RESOLVE_HOST
	    return PARALLEL_CANT_RESOLVE_HOST;
#else
	    goto not_there;
#endif
	}
    case 'S':
	if (strEQ(name + 10, "ANT_START_CMD")) {	/* PARALLEL_C removed */
#ifdef PARALLEL_CANT_START_CMD
	    return PARALLEL_CANT_START_CMD;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_P(char *name, int len, int arg)
{
    if (1 + 8 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[1 + 8]) {
    case '6':
	if (strEQ(name + 1, "ARALLEL_64BIT_DCE_ERR")) {	/* P removed */
#ifdef PARALLEL_64BIT_DCE_ERR
	    return PARALLEL_64BIT_DCE_ERR;
#else
	    goto not_there;
#endif
	}
    case 'B':
	if (strEQ(name + 1, "ARALLEL_BAD_ENVIRONMENT")) {	/* P removed */
#ifdef PARALLEL_BAD_ENVIRONMENT
	    return PARALLEL_BAD_ENVIRONMENT;
#else
	    goto not_there;
#endif
	}
    case 'C':
	if (!strnEQ(name + 1,"ARALLEL_", 8))
	    break;
	return constant_PARALLEL_C(name, len, arg);
    case 'I':
	if (strEQ(name + 1, "ARALLEL_INSUFFICIENT_DCE_CRED")) {	/* P removed */
#ifdef PARALLEL_INSUFFICIENT_DCE_CRED
	    return PARALLEL_INSUFFICIENT_DCE_CRED;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (!strnEQ(name + 1,"ARALLEL_", 8))
	    break;
	return constant_PARALLEL_N(name, len, arg);
    case 'O':
	if (strEQ(name + 1, "ARALLEL_OK")) {	/* P removed */
#ifdef PARALLEL_OK
	    return PARALLEL_OK;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_API_N(char *name, int len, int arg)
{
    if (5 + 6 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[5 + 6]) {
    case 'C':
	if (strEQ(name + 5, "O_DCE_CRED")) {	/* API_N removed */
#ifdef API_NO_DCE_CRED
	    return API_NO_DCE_CRED;
#else
	    goto not_there;
#endif
	}
    case 'I':
	if (strEQ(name + 5, "O_DCE_ID")) {	/* API_N removed */
#ifdef API_NO_DCE_ID
	    return API_NO_DCE_ID;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_API_CANT_F(char *name, int len, int arg)
{
    if (10 + 4 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[10 + 4]) {
    case 'P':
	if (strEQ(name + 10, "IND_PROC")) {	/* API_CANT_F removed */
#ifdef API_CANT_FIND_PROC
	    return API_CANT_FIND_PROC;
#else
	    goto not_there;
#endif
	}
    case 'R':
	if (strEQ(name + 10, "IND_RUNCLASS")) {	/* API_CANT_F removed */
#ifdef API_CANT_FIND_RUNCLASS
	    return API_CANT_FIND_RUNCLASS;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_API_CA(char *name, int len, int arg)
{
    if (6 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[6 + 3]) {
    case 'A':
	if (strEQ(name + 6, "NT_AUTH")) {	/* API_CA removed */
#ifdef API_CANT_AUTH
	    return API_CANT_AUTH;
#else
	    goto not_there;
#endif
	}
    case 'C':
	if (strEQ(name + 6, "NT_CONNECT")) {	/* API_CA removed */
#ifdef API_CANT_CONNECT
	    return API_CANT_CONNECT;
#else
	    goto not_there;
#endif
	}
    case 'F':
	if (!strnEQ(name + 6,"NT_", 3))
	    break;
	return constant_API_CANT_F(name, len, arg);
    case 'M':
	if (strEQ(name + 6, "NT_MALLOC")) {	/* API_CA removed */
#ifdef API_CANT_MALLOC
	    return API_CANT_MALLOC;
#else
	    goto not_there;
#endif
	}
    case 'T':
	if (strEQ(name + 6, "NT_TRANSMIT")) {	/* API_CA removed */
#ifdef API_CANT_TRANSMIT
	    return API_CANT_TRANSMIT;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_API_C(char *name, int len, int arg)
{
    switch (name[5 + 0]) {
    case 'A':
	return constant_API_CA(name, len, arg);
    case 'O':
	if (strEQ(name + 5, "ONFIG_ERR")) {	/* API_C removed */
#ifdef API_CONFIG_ERR
	    return API_CONFIG_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_API_WRNG_P(char *name, int len, int arg)
{
    if (10 + 4 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[10 + 4]) {
    case 'S':
	if (strEQ(name + 10, "ROC_STATE")) {	/* API_WRNG_P removed */
#ifdef API_WRNG_PROC_STATE
	    return API_WRNG_PROC_STATE;
#else
	    goto not_there;
#endif
	}
    case 'V':
	if (strEQ(name + 10, "ROC_VERSION")) {	/* API_WRNG_P removed */
#ifdef API_WRNG_PROC_VERSION
	    return API_WRNG_PROC_VERSION;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_API_W(char *name, int len, int arg)
{
    if (5 + 4 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[5 + 4]) {
    case 'M':
	if (strEQ(name + 5, "RNG_MACH_NO")) {	/* API_W removed */
#ifdef API_WRNG_MACH_NO
	    return API_WRNG_MACH_NO;
#else
	    goto not_there;
#endif
	}
    case 'P':
	if (!strnEQ(name + 5,"RNG_", 4))
	    break;
	return constant_API_WRNG_P(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_API_I(char *name, int len, int arg)
{
    if (5 + 1 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[5 + 1]) {
    case 'S':
	if (strEQ(name + 5, "NSUFFICIENT_DCE_CRED")) {	/* API_I removed */
#ifdef API_INSUFFICIENT_DCE_CRED
	    return API_INSUFFICIENT_DCE_CRED;
#else
	    goto not_there;
#endif
	}
    case 'V':
	if (strEQ(name + 5, "NVALID_INPUT")) {	/* API_I removed */
#ifdef API_INVALID_INPUT
	    return API_INVALID_INPUT;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_API_M(char *name, int len, int arg)
{
    if (5 + 4 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[5 + 4]) {
    case 'D':
	if (strEQ(name + 5, "ACH_DUP")) {	/* API_M removed */
#ifdef API_MACH_DUP
	    return API_MACH_DUP;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (strEQ(name + 5, "ACH_NOT_AVAIL")) {	/* API_M removed */
#ifdef API_MACH_NOT_AVAIL
	    return API_MACH_NOT_AVAIL;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_A(char *name, int len, int arg)
{
    if (1 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[1 + 3]) {
    case '6':
	if (strEQ(name + 1, "PI_64BIT_DCE_ERR")) {	/* A removed */
#ifdef API_64BIT_DCE_ERR
	    return API_64BIT_DCE_ERR;
#else
	    goto not_there;
#endif
	}
    case 'C':
	if (!strnEQ(name + 1,"PI_", 3))
	    break;
	return constant_API_C(name, len, arg);
    case 'I':
	if (!strnEQ(name + 1,"PI_", 3))
	    break;
	return constant_API_I(name, len, arg);
    case 'L':
	if (strEQ(name + 1, "PI_LL_SCH_ON")) {	/* A removed */
#ifdef API_LL_SCH_ON
	    return API_LL_SCH_ON;
#else
	    goto not_there;
#endif
	}
    case 'M':
	if (!strnEQ(name + 1,"PI_", 3))
	    break;
	return constant_API_M(name, len, arg);
    case 'N':
	if (!strnEQ(name + 1,"PI_", 3))
	    break;
	return constant_API_N(name, len, arg);
    case 'O':
	if (strEQ(name + 1, "PI_OK")) {	/* A removed */
#ifdef API_OK
	    return API_OK;
#else
	    goto not_there;
#endif
	}
    case 'R':
	if (strEQ(name + 1, "PI_REQ_NOT_MET")) {	/* A removed */
#ifdef API_REQ_NOT_MET
	    return API_REQ_NOT_MET;
#else
	    goto not_there;
#endif
	}
    case 'W':
	if (!strnEQ(name + 1,"PI_", 3))
	    break;
	return constant_API_W(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_NO_(char *name, int len, int arg)
{
    switch (name[6 + 0]) {
    case 'A':
	if (strEQ(name + 6, "ALLOCATE")) {	/* LL_NO_ removed */
#ifdef LL_NO_ALLOCATE
	    return LL_NO_ALLOCATE;
#else
	    goto not_there;
#endif
	}
    case 'S':
	if (strEQ(name + 6, "STORAGE")) {	/* LL_NO_ removed */
#ifdef LL_NO_STORAGE
	    return LL_NO_STORAGE;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_NOTI(char *name, int len, int arg)
{
    if (7 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[7 + 3]) {
    case 'A':
	if (strEQ(name + 7, "FY_ALWAYS")) {	/* LL_NOTI removed */
#ifdef LL_NOTIFY_ALWAYS
	    return LL_NOTIFY_ALWAYS;
#else
	    goto not_there;
#endif
	}
    case 'C':
	if (strEQ(name + 7, "FY_COMPLETE")) {	/* LL_NOTI removed */
#ifdef LL_NOTIFY_COMPLETE
	    return LL_NOTIFY_COMPLETE;
#else
	    goto not_there;
#endif
	}
    case 'E':
	if (strEQ(name + 7, "FY_ERROR")) {	/* LL_NOTI removed */
#ifdef LL_NOTIFY_ERROR
	    return LL_NOTIFY_ERROR;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (strEQ(name + 7, "FY_NEVER")) {	/* LL_NOTI removed */
#ifdef LL_NOTIFY_NEVER
	    return LL_NOTIFY_NEVER;
#else
	    goto not_there;
#endif
	}
    case 'S':
	if (strEQ(name + 7, "FY_START")) {	/* LL_NOTI removed */
#ifdef LL_NOTIFY_START
	    return LL_NOTIFY_START;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_NOT(char *name, int len, int arg)
{
    switch (name[6 + 0]) {
    case 'I':
	return constant_LL_NOTI(name, len, arg);
    case 'Q':
	if (strEQ(name + 6, "QUEUED")) {	/* LL_NOT removed */
#ifdef LL_NOTQUEUED
	    return LL_NOTQUEUED;
#else
	    goto not_there;
#endif
	}
    case 'R':
	if (strEQ(name + 6, "RUN")) {	/* LL_NOT removed */
#ifdef LL_NOTRUN
	    return LL_NOTRUN;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_NO(char *name, int len, int arg)
{
    switch (name[5 + 0]) {
    case 'D':
	if (strEQ(name + 5, "DE_USAGE_NOT_SHARED")) {	/* LL_NO removed */
#ifdef LL_NODE_USAGE_NOT_SHARED
	    return LL_NODE_USAGE_NOT_SHARED;
#else
	    goto not_there;
#endif
	}
    case 'T':
	return constant_LL_NOT(name, len, arg);
    case '_':
	return constant_LL_NO_(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_N(char *name, int len, int arg)
{
    switch (name[4 + 0]) {
    case 'O':
	return constant_LL_NO(name, len, arg);
    case 'Q':
	if (strEQ(name + 4, "QS_STEP")) {	/* LL_N removed */
#ifdef LL_NQS_STEP
	    return LL_NQS_STEP;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_A(char *name, int len, int arg)
{
    if (4 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[4 + 3]) {
    case 'A':
	if (strEQ(name + 4, "PI_ACTIVE")) {	/* LL_A removed */
#ifdef LL_API_ACTIVE
	    return LL_API_ACTIVE;
#else
	    goto not_there;
#endif
	}
    case 'S':
	if (strEQ(name + 4, "PI_SYNC_START")) {	/* LL_A removed */
#ifdef LL_API_SYNC_START
	    return LL_API_SYNC_START;
#else
	    goto not_there;
#endif
	}
    case 'V':
	if (strEQ(name + 4, "PI_VERSION")) {	/* LL_A removed */
#ifdef LL_API_VERSION
	    return LL_API_VERSION;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_RESTART_(char *name, int len, int arg)
{
    switch (name[11 + 0]) {
    case 'F':
	if (strEQ(name + 11, "FROM_CKPT")) {	/* LL_RESTART_ removed */
#ifdef LL_RESTART_FROM_CKPT
	    return LL_RESTART_FROM_CKPT;
#else
	    goto not_there;
#endif
	}
    case 'S':
	if (strEQ(name + 11, "SAME_NODES")) {	/* LL_RESTART_ removed */
#ifdef LL_RESTART_SAME_NODES
	    return LL_RESTART_SAME_NODES;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_RES(char *name, int len, int arg)
{
    if (6 + 4 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[6 + 4]) {
    case '\0':
	if (strEQ(name + 6, "TART")) {	/* LL_RES removed */
#ifdef LL_RESTART
	    return LL_RESTART;
#else
	    goto not_there;
#endif
	}
    case '_':
	if (!strnEQ(name + 6,"TART", 4))
	    break;
	return constant_LL_RESTART_(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_RE(char *name, int len, int arg)
{
    switch (name[5 + 0]) {
    case 'M':
	if (strEQ(name + 5, "MOVED")) {	/* LL_RE removed */
#ifdef LL_REMOVED
	    return LL_REMOVED;
#else
	    goto not_there;
#endif
	}
    case 'S':
	return constant_LL_RES(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_R(char *name, int len, int arg)
{
    switch (name[4 + 0]) {
    case 'E':
	return constant_LL_RE(name, len, arg);
    case 'S':
	if (strEQ(name + 4, "SS_LIMIT_USER")) {	/* LL_R removed */
#ifdef LL_RSS_LIMIT_USER
	    return LL_RSS_LIMIT_USER;
#else
	    goto not_there;
#endif
	}
    case 'U':
	if (strEQ(name + 4, "UNNING")) {	/* LL_R removed */
#ifdef LL_RUNNING
	    return LL_RUNNING;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_BAD_P(char *name, int len, int arg)
{
    if (8 + 1 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[8 + 1]) {
    case 'E':
	if (strEQ(name + 8, "REFERENCES")) {	/* LL_BAD_P removed */
#ifdef LL_BAD_PREFERENCES
	    return LL_BAD_PREFERENCES;
#else
	    goto not_there;
#endif
	}
    case 'I':
	if (strEQ(name + 8, "RIO")) {	/* LL_BAD_P removed */
#ifdef LL_BAD_PRIO
	    return LL_BAD_PRIO;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_BAD_CL(char *name, int len, int arg)
{
    if (9 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[9 + 3]) {
    case '\0':
	if (strEQ(name + 9, "ASS")) {	/* LL_BAD_CL removed */
#ifdef LL_BAD_CLASS
	    return LL_BAD_CLASS;
#else
	    goto not_there;
#endif
	}
    case '_':
	if (strEQ(name + 9, "ASS_CONFIG")) {	/* LL_BAD_CL removed */
#ifdef LL_BAD_CLASS_CONFIG
	    return LL_BAD_CLASS_CONFIG;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_BAD_C(char *name, int len, int arg)
{
    switch (name[8 + 0]) {
    case 'L':
	return constant_LL_BAD_CL(name, len, arg);
    case 'M':
	if (strEQ(name + 8, "MD")) {	/* LL_BAD_C removed */
#ifdef LL_BAD_CMD
	    return LL_BAD_CMD;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_BAD_G(char *name, int len, int arg)
{
    if (8 + 5 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[8 + 5]) {
    case 'C':
	if (strEQ(name + 8, "ROUP_CONFIG")) {	/* LL_BAD_G removed */
#ifdef LL_BAD_GROUP_CONFIG
	    return LL_BAD_GROUP_CONFIG;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (strEQ(name + 8, "ROUP_NAME")) {	/* LL_BAD_G removed */
#ifdef LL_BAD_GROUP_NAME
	    return LL_BAD_GROUP_NAME;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_B(char *name, int len, int arg)
{
    if (4 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[4 + 3]) {
    case 'A':
	if (strEQ(name + 4, "AD_ACCOUNT_NO")) {	/* LL_B removed */
#ifdef LL_BAD_ACCOUNT_NO
	    return LL_BAD_ACCOUNT_NO;
#else
	    goto not_there;
#endif
	}
    case 'C':
	if (!strnEQ(name + 4,"AD_", 3))
	    break;
	return constant_LL_BAD_C(name, len, arg);
    case 'D':
	if (strEQ(name + 4, "AD_DEPENDENCY")) {	/* LL_B removed */
#ifdef LL_BAD_DEPENDENCY
	    return LL_BAD_DEPENDENCY;
#else
	    goto not_there;
#endif
	}
    case 'E':
	if (strEQ(name + 4, "AD_EXEC")) {	/* LL_B removed */
#ifdef LL_BAD_EXEC
	    return LL_BAD_EXEC;
#else
	    goto not_there;
#endif
	}
    case 'G':
	if (!strnEQ(name + 4,"AD_", 3))
	    break;
	return constant_LL_BAD_G(name, len, arg);
    case 'N':
	if (strEQ(name + 4, "AD_NOTIFY")) {	/* LL_B removed */
#ifdef LL_BAD_NOTIFY
	    return LL_BAD_NOTIFY;
#else
	    goto not_there;
#endif
	}
    case 'P':
	if (!strnEQ(name + 4,"AD_", 3))
	    break;
	return constant_LL_BAD_P(name, len, arg);
    case 'R':
	if (strEQ(name + 4, "AD_REQUIREMENTS")) {	/* LL_B removed */
#ifdef LL_BAD_REQUIREMENTS
	    return LL_BAD_REQUIREMENTS;
#else
	    goto not_there;
#endif
	}
    case 'S':
	if (strEQ(name + 4, "AD_STATUS")) {	/* LL_B removed */
#ifdef LL_BAD_STATUS
	    return LL_BAD_STATUS;
#else
	    goto not_there;
#endif
	}
    case 'T':
	if (strEQ(name + 4, "AD_TRANSMIT")) {	/* LL_B removed */
#ifdef LL_BAD_TRANSMIT
	    return LL_BAD_TRANSMIT;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_STA(char *name, int len, int arg)
{
    switch (name[6 + 0]) {
    case 'C':
	if (strEQ(name + 6, "CK_LIMIT_USER")) {	/* LL_STA removed */
#ifdef LL_STACK_LIMIT_USER
	    return LL_STACK_LIMIT_USER;
#else
	    goto not_there;
#endif
	}
    case 'R':
	if (strEQ(name + 6, "RTING")) {	/* LL_STA removed */
#ifdef LL_STARTING
	    return LL_STARTING;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_STE(char *name, int len, int arg)
{
    if (6 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[6 + 3]) {
    case 'A':
	if (strEQ(name + 6, "P_PARALLEL")) {	/* LL_STE removed */
#ifdef LL_STEP_PARALLEL
	    return LL_STEP_PARALLEL;
#else
	    goto not_there;
#endif
	}
    case 'V':
	if (strEQ(name + 6, "P_PVM3")) {	/* LL_STE removed */
#ifdef LL_STEP_PVM3
	    return LL_STEP_PVM3;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_ST(char *name, int len, int arg)
{
    switch (name[5 + 0]) {
    case 'A':
	return constant_LL_STA(name, len, arg);
    case 'E':
	return constant_LL_STE(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_S(char *name, int len, int arg)
{
    switch (name[4 + 0]) {
    case 'T':
	return constant_LL_ST(name, len, arg);
    case 'U':
	if (strEQ(name + 4, "UBMISSION_ERR")) {	/* LL_S removed */
#ifdef LL_SUBMISSION_ERR
	    return LL_SUBMISSION_ERR;
#else
	    goto not_there;
#endif
	}
    case 'Y':
	if (strEQ(name + 4, "YSTEM_HOLD")) {	/* LL_S removed */
#ifdef LL_SYSTEM_HOLD
	    return LL_SYSTEM_HOLD;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_N(char *name, int len, int arg)
{
    if (12 + 6 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[12 + 6]) {
    case 'C':
	if (strEQ(name + 12, "O_DCE_CRED")) {	/* LL_CONTROL_N removed */
#ifdef LL_CONTROL_NO_DCE_CRED
	    return LL_CONTROL_NO_DCE_CRED;
#else
	    goto not_there;
#endif
	}
    case 'I':
	if (strEQ(name + 12, "O_DCE_ID")) {	/* LL_CONTROL_N removed */
#ifdef LL_CONTROL_NO_DCE_ID
	    return LL_CONTROL_NO_DCE_ID;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_P(char *name, int len, int arg)
{
    switch (name[12 + 0]) {
    case 'R':
	if (strEQ(name + 12, "RIO_ERR")) {	/* LL_CONTROL_P removed */
#ifdef LL_CONTROL_PRIO_ERR
	    return LL_CONTROL_PRIO_ERR;
#else
	    goto not_there;
#endif
	}
    case 'U':
	if (strEQ(name + 12, "URGE_SCHEDD_ERR")) {	/* LL_CONTROL_P removed */
#ifdef LL_CONTROL_PURGE_SCHEDD_ERR
	    return LL_CONTROL_PURGE_SCHEDD_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_SY(char *name, int len, int arg)
{
    if (13 + 1 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[13 + 1]) {
    case 'T':
	if (strEQ(name + 13, "STEM_ERR")) {	/* LL_CONTROL_SY removed */
#ifdef LL_CONTROL_SYSTEM_ERR
	    return LL_CONTROL_SYSTEM_ERR;
#else
	    goto not_there;
#endif
	}
    case '_':
	if (strEQ(name + 13, "S_ERR")) {	/* LL_CONTROL_SY removed */
#ifdef LL_CONTROL_SYS_ERR
	    return LL_CONTROL_SYS_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_S(char *name, int len, int arg)
{
    switch (name[12 + 0]) {
    case 'T':
	if (strEQ(name + 12, "TART_ERR")) {	/* LL_CONTROL_S removed */
#ifdef LL_CONTROL_START_ERR
	    return LL_CONTROL_START_ERR;
#else
	    goto not_there;
#endif
	}
    case 'Y':
	return constant_LL_CONTROL_SY(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_C(char *name, int len, int arg)
{
    switch (name[12 + 0]) {
    case 'L':
	if (strEQ(name + 12, "LASS_ERR")) {	/* LL_CONTROL_C removed */
#ifdef LL_CONTROL_CLASS_ERR
	    return LL_CONTROL_CLASS_ERR;
#else
	    goto not_there;
#endif
	}
    case 'M':
	if (strEQ(name + 12, "M_ERR")) {	/* LL_CONTROL_C removed */
#ifdef LL_CONTROL_CM_ERR
	    return LL_CONTROL_CM_ERR;
#else
	    goto not_there;
#endif
	}
    case 'O':
	if (strEQ(name + 12, "ONFIG_ERR")) {	/* LL_CONTROL_C removed */
#ifdef LL_CONTROL_CONFIG_ERR
	    return LL_CONTROL_CONFIG_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_VERSION_(char *name, int len, int arg)
{
    switch (name[19 + 0]) {
    case '2':
	if (strEQ(name + 19, "22")) {	/* LL_CONTROL_VERSION_ removed */
#ifdef LL_CONTROL_VERSION_22
	    return LL_CONTROL_VERSION_22;
#else
	    goto not_there;
#endif
	}
    case '3':
	if (strEQ(name + 19, "310")) {	/* LL_CONTROL_VERSION_ removed */
#ifdef LL_CONTROL_VERSION_310
	    return LL_CONTROL_VERSION_310;
#else
	    goto not_there;
#endif
	}
    case 'E':
	if (strEQ(name + 19, "ERR")) {	/* LL_CONTROL_VERSION_ removed */
#ifdef LL_CONTROL_VERSION_ERR
	    return LL_CONTROL_VERSION_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_V(char *name, int len, int arg)
{
    if (12 + 6 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[12 + 6]) {
    case '\0':
	if (strEQ(name + 12, "ERSION")) {	/* LL_CONTROL_V removed */
#ifdef LL_CONTROL_VERSION
	    return LL_CONTROL_VERSION;
#else
	    goto not_there;
#endif
	}
    case '_':
	if (!strnEQ(name + 12,"ERSION", 6))
	    break;
	return constant_LL_CONTROL_VERSION_(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_F(char *name, int len, int arg)
{
    if (12 + 4 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[12 + 4]) {
    case 'J':
	if (strEQ(name + 12, "AVORJOB_ERR")) {	/* LL_CONTROL_F removed */
#ifdef LL_CONTROL_FAVORJOB_ERR
	    return LL_CONTROL_FAVORJOB_ERR;
#else
	    goto not_there;
#endif
	}
    case 'U':
	if (strEQ(name + 12, "AVORUSER_ERR")) {	/* LL_CONTROL_F removed */
#ifdef LL_CONTROL_FAVORUSER_ERR
	    return LL_CONTROL_FAVORUSER_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_H(char *name, int len, int arg)
{
    if (12 + 1 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[12 + 1]) {
    case 'L':
	if (strEQ(name + 12, "OLD_ERR")) {	/* LL_CONTROL_H removed */
#ifdef LL_CONTROL_HOLD_ERR
	    return LL_CONTROL_HOLD_ERR;
#else
	    goto not_there;
#endif
	}
    case 'S':
	if (strEQ(name + 12, "OST_LIST_ERR")) {	/* LL_CONTROL_H removed */
#ifdef LL_CONTROL_HOST_LIST_ERR
	    return LL_CONTROL_HOST_LIST_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_I(char *name, int len, int arg)
{
    if (12 + 1 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[12 + 1]) {
    case 'S':
	if (strEQ(name + 12, "NSUFFICIENT_DCE_CRED")) {	/* LL_CONTROL_I removed */
#ifdef LL_CONTROL_INSUFFICIENT_DCE_CRED
	    return LL_CONTROL_INSUFFICIENT_DCE_CRED;
#else
	    goto not_there;
#endif
	}
    case 'V':
	if (strEQ(name + 12, "NVALID_OP_ERR")) {	/* LL_CONTROL_I removed */
#ifdef LL_CONTROL_INVALID_OP_ERR
	    return LL_CONTROL_INVALID_OP_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONTROL_M(char *name, int len, int arg)
{
    if (12 + 1 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[12 + 1]) {
    case 'L':
	if (strEQ(name + 12, "ALLOC_ERR")) {	/* LL_CONTROL_M removed */
#ifdef LL_CONTROL_MALLOC_ERR
	    return LL_CONTROL_MALLOC_ERR;
#else
	    goto not_there;
#endif
	}
    case 'S':
	if (strEQ(name + 12, "ASTER_ERR")) {	/* LL_CONTROL_M removed */
#ifdef LL_CONTROL_MASTER_ERR
	    return LL_CONTROL_MASTER_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CONT(char *name, int len, int arg)
{
    if (7 + 4 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[7 + 4]) {
    case '6':
	if (strEQ(name + 7, "ROL_64BIT_DCE_ERR")) {	/* LL_CONT removed */
#ifdef LL_CONTROL_64BIT_DCE_ERR
	    return LL_CONTROL_64BIT_DCE_ERR;
#else
	    goto not_there;
#endif
	}
    case 'A':
	if (strEQ(name + 7, "ROL_AUTH_ERR")) {	/* LL_CONT removed */
#ifdef LL_CONTROL_AUTH_ERR
	    return LL_CONTROL_AUTH_ERR;
#else
	    goto not_there;
#endif
	}
    case 'C':
	if (!strnEQ(name + 7,"ROL_", 4))
	    break;
	return constant_LL_CONTROL_C(name, len, arg);
    case 'E':
	if (strEQ(name + 7, "ROL_ERR")) {	/* LL_CONT removed */
#ifdef LL_CONTROL_ERR
	    return LL_CONTROL_ERR;
#else
	    goto not_there;
#endif
	}
    case 'F':
	if (!strnEQ(name + 7,"ROL_", 4))
	    break;
	return constant_LL_CONTROL_F(name, len, arg);
    case 'H':
	if (!strnEQ(name + 7,"ROL_", 4))
	    break;
	return constant_LL_CONTROL_H(name, len, arg);
    case 'I':
	if (!strnEQ(name + 7,"ROL_", 4))
	    break;
	return constant_LL_CONTROL_I(name, len, arg);
    case 'J':
	if (strEQ(name + 7, "ROL_JOB_LIST_ERR")) {	/* LL_CONT removed */
#ifdef LL_CONTROL_JOB_LIST_ERR
	    return LL_CONTROL_JOB_LIST_ERR;
#else
	    goto not_there;
#endif
	}
    case 'M':
	if (!strnEQ(name + 7,"ROL_", 4))
	    break;
	return constant_LL_CONTROL_M(name, len, arg);
    case 'N':
	if (!strnEQ(name + 7,"ROL_", 4))
	    break;
	return constant_LL_CONTROL_N(name, len, arg);
    case 'O':
	if (strEQ(name + 7, "ROL_OK")) {	/* LL_CONT removed */
#ifdef LL_CONTROL_OK
	    return LL_CONTROL_OK;
#else
	    goto not_there;
#endif
	}
    case 'P':
	if (!strnEQ(name + 7,"ROL_", 4))
	    break;
	return constant_LL_CONTROL_P(name, len, arg);
    case 'S':
	if (!strnEQ(name + 7,"ROL_", 4))
	    break;
	return constant_LL_CONTROL_S(name, len, arg);
    case 'T':
	if (strEQ(name + 7, "ROL_TMP_ERR")) {	/* LL_CONT removed */
#ifdef LL_CONTROL_TMP_ERR
	    return LL_CONTROL_TMP_ERR;
#else
	    goto not_there;
#endif
	}
    case 'U':
	if (strEQ(name + 7, "ROL_USER_LIST_ERR")) {	/* LL_CONT removed */
#ifdef LL_CONTROL_USER_LIST_ERR
	    return LL_CONTROL_USER_LIST_ERR;
#else
	    goto not_there;
#endif
	}
    case 'V':
	if (!strnEQ(name + 7,"ROL_", 4))
	    break;
	return constant_LL_CONTROL_V(name, len, arg);
    case 'X':
	if (strEQ(name + 7, "ROL_XMIT_ERR")) {	/* LL_CONT removed */
#ifdef LL_CONTROL_XMIT_ERR
	    return LL_CONTROL_XMIT_ERR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CON(char *name, int len, int arg)
{
    switch (name[6 + 0]) {
    case 'F':
	if (strEQ(name + 6, "FIG_NOT_FOUND")) {	/* LL_CON removed */
#ifdef LL_CONFIG_NOT_FOUND
	    return LL_CONFIG_NOT_FOUND;
#else
	    goto not_there;
#endif
	}
    case 'T':
	return constant_LL_CONT(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CO(char *name, int len, int arg)
{
    switch (name[5 + 0]) {
    case 'M':
	if (strEQ(name + 5, "MPLETED")) {	/* LL_CO removed */
#ifdef LL_COMPLETED
	    return LL_COMPLETED;
#else
	    goto not_there;
#endif
	}
    case 'N':
	return constant_LL_CON(name, len, arg);
    case 'R':
	if (strEQ(name + 5, "RE_LIMIT_USER")) {	/* LL_CO removed */
#ifdef LL_CORE_LIMIT_USER
	    return LL_CORE_LIMIT_USER;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_CH(char *name, int len, int arg)
{
    if (5 + 8 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[5 + 8]) {
    case '\0':
	if (strEQ(name + 5, "ECKPOINT")) {	/* LL_CH removed */
#ifdef LL_CHECKPOINT
	    return LL_CHECKPOINT;
#else
	    goto not_there;
#endif
	}
    case '_':
	if (strEQ(name + 5, "ECKPOINT_INTERVAL")) {	/* LL_CH removed */
#ifdef LL_CHECKPOINT_INTERVAL
	    return LL_CHECKPOINT_INTERVAL;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_C(char *name, int len, int arg)
{
    switch (name[4 + 0]) {
    case 'A':
	if (strEQ(name + 4, "ANNOT_CONTACT_DAEMON")) {	/* LL_C removed */
#ifdef LL_CANNOT_CONTACT_DAEMON
	    return LL_CANNOT_CONTACT_DAEMON;
#else
	    goto not_there;
#endif
	}
    case 'H':
	return constant_LL_CH(name, len, arg);
    case 'O':
	return constant_LL_CO(name, len, arg);
    case 'P':
	if (strEQ(name + 4, "PU_LIMIT_USER")) {	/* LL_C removed */
#ifdef LL_CPU_LIMIT_USER
	    return LL_CPU_LIMIT_USER;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_DAT(char *name, int len, int arg)
{
    if (6 + 2 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[6 + 2]) {
    case 'L':
	if (strEQ(name + 6, "A_LIMIT_USER")) {	/* LL_DAT removed */
#ifdef LL_DATA_LIMIT_USER
	    return LL_DATA_LIMIT_USER;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (strEQ(name + 6, "A_NOT_RECEIVED")) {	/* LL_DAT removed */
#ifdef LL_DATA_NOT_RECEIVED
	    return LL_DATA_NOT_RECEIVED;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_DA(char *name, int len, int arg)
{
    switch (name[5 + 0]) {
    case 'E':
	if (strEQ(name + 5, "EMON_NOT_CONFIG")) {	/* LL_DA removed */
#ifdef LL_DAEMON_NOT_CONFIG
	    return LL_DAEMON_NOT_CONFIG;
#else
	    goto not_there;
#endif
	}
    case 'T':
	return constant_LL_DAT(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_D(char *name, int len, int arg)
{
    switch (name[4 + 0]) {
    case 'A':
	return constant_LL_DA(name, len, arg);
    case 'E':
	if (strEQ(name + 4, "EFERRED")) {	/* LL_D removed */
#ifdef LL_DEFERRED
	    return LL_DEFERRED;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_H(char *name, int len, int arg)
{
    if (4 + 1 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[4 + 1]) {
    case 'L':
	if (strEQ(name + 4, "OLD")) {	/* LL_H removed */
#ifdef LL_HOLD
	    return LL_HOLD;
#else
	    goto not_there;
#endif
	}
    case 'S':
	if (strEQ(name + 4, "OST_NOT_CONFIG")) {	/* LL_H removed */
#ifdef LL_HOST_NOT_CONFIG
	    return LL_HOST_NOT_CONFIG;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_INV(char *name, int len, int arg)
{
    if (6 + 5 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[6 + 5]) {
    case 'D':
	if (strEQ(name + 6, "ALID_DAEMON_ID")) {	/* LL_INV removed */
#ifdef LL_INVALID_DAEMON_ID
	    return LL_INVALID_DAEMON_ID;
#else
	    goto not_there;
#endif
	}
    case 'F':
	if (strEQ(name + 6, "ALID_FIELD_ID")) {	/* LL_INV removed */
#ifdef LL_INVALID_FIELD_ID
	    return LL_INVALID_FIELD_ID;
#else
	    goto not_there;
#endif
	}
    case 'P':
	if (strEQ(name + 6, "ALID_PTR")) {	/* LL_INV removed */
#ifdef LL_INVALID_PTR
	    return LL_INVALID_PTR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_IN(char *name, int len, int arg)
{
    switch (name[5 + 0]) {
    case 'S':
	if (strEQ(name + 5, "STALLATION_EVENT")) {	/* LL_IN removed */
#ifdef LL_INSTALLATION_EVENT
	    return LL_INSTALLATION_EVENT;
#else
	    goto not_there;
#endif
	}
    case 'T':
	if (strEQ(name + 5, "TERACTIVE")) {	/* LL_IN removed */
#ifdef LL_INTERACTIVE
	    return LL_INTERACTIVE;
#else
	    goto not_there;
#endif
	}
    case 'V':
	return constant_LL_INV(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_I(char *name, int len, int arg)
{
    switch (name[4 + 0]) {
    case 'D':
	if (strEQ(name + 4, "DLE")) {	/* LL_I removed */
#ifdef LL_IDLE
	    return LL_IDLE;
#else
	    goto not_there;
#endif
	}
    case 'M':
	if (strEQ(name + 4, "MMEDIATE")) {	/* LL_I removed */
#ifdef LL_IMMEDIATE
	    return LL_IMMEDIATE;
#else
	    goto not_there;
#endif
	}
    case 'N':
	return constant_LL_IN(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_LL_J(char *name, int len, int arg)
{
    if (4 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[4 + 3]) {
    case 'P':
	if (strEQ(name + 4, "OB_PROC_VERSION")) {	/* LL_J removed */
#ifdef LL_JOB_PROC_VERSION
	    return LL_JOB_PROC_VERSION;
#else
	    goto not_there;
#endif
	}
    case 'V':
	if (strEQ(name + 4, "OB_VERSION")) {	/* LL_J removed */
#ifdef LL_JOB_VERSION
	    return LL_JOB_VERSION;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_L(char *name, int len, int arg)
{
    if (1 + 2 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[1 + 2]) {
    case 'A':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_A(name, len, arg);
    case 'B':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_B(name, len, arg);
    case 'C':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_C(name, len, arg);
    case 'D':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_D(name, len, arg);
    case 'F':
	if (strEQ(name + 1, "L_FILE_LIMIT_USER")) {	/* L removed */
#ifdef LL_FILE_LIMIT_USER
	    return LL_FILE_LIMIT_USER;
#else
	    goto not_there;
#endif
	}
    case 'H':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_H(name, len, arg);
    case 'I':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_I(name, len, arg);
    case 'J':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_J(name, len, arg);
    case 'L':
	if (strEQ(name + 1, "L_LOADL_EVENT")) {	/* L removed */
#ifdef LL_LOADL_EVENT
	    return LL_LOADL_EVENT;
#else
	    goto not_there;
#endif
	}
    case 'M':
	if (strEQ(name + 1, "L_MAX_STATUS")) {	/* L removed */
#ifdef LL_MAX_STATUS
	    return LL_MAX_STATUS;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_N(name, len, arg);
    case 'P':
	if (strEQ(name + 1, "L_PROC_VERSION")) {	/* L removed */
#ifdef LL_PROC_VERSION
	    return LL_PROC_VERSION;
#else
	    goto not_there;
#endif
	}
    case 'R':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_R(name, len, arg);
    case 'S':
	if (!strnEQ(name + 1,"L_", 2))
	    break;
	return constant_LL_S(name, len, arg);
    case 'U':
	if (strEQ(name + 1, "L_USER_HOLD")) {	/* L removed */
#ifdef LL_USER_HOLD
	    return LL_USER_HOLD;
#else
	    goto not_there;
#endif
	}
    case 'V':
	if (strEQ(name + 1, "L_VACATE")) {	/* L removed */
#ifdef LL_VACATE
	    return LL_VACATE;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_MODIFY_N(char *name, int len, int arg)
{
    if (8 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[8 + 3]) {
    case 'A':
	if (strEQ(name + 8, "OT_AUTH")) {	/* MODIFY_N removed */
#ifdef MODIFY_NOT_AUTH
	    return MODIFY_NOT_AUTH;
#else
	    goto not_there;
#endif
	}
    case 'I':
	if (strEQ(name + 8, "OT_IDLE")) {	/* MODIFY_N removed */
#ifdef MODIFY_NOT_IDLE
	    return MODIFY_NOT_IDLE;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_MODIFY_S(char *name, int len, int arg)
{
    switch (name[8 + 0]) {
    case 'U':
	if (strEQ(name + 8, "UCCESS")) {	/* MODIFY_S removed */
#ifdef MODIFY_SUCCESS
	    return MODIFY_SUCCESS;
#else
	    goto not_there;
#endif
	}
    case 'Y':
	if (strEQ(name + 8, "YSTEM_ERROR")) {	/* MODIFY_S removed */
#ifdef MODIFY_SYSTEM_ERROR
	    return MODIFY_SYSTEM_ERROR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_MODIFY_CA(char *name, int len, int arg)
{
    if (9 + 3 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[9 + 3]) {
    case 'C':
	if (strEQ(name + 9, "NT_CONNECT")) {	/* MODIFY_CA removed */
#ifdef MODIFY_CANT_CONNECT
	    return MODIFY_CANT_CONNECT;
#else
	    goto not_there;
#endif
	}
    case 'T':
	if (strEQ(name + 9, "NT_TRANSMIT")) {	/* MODIFY_CA removed */
#ifdef MODIFY_CANT_TRANSMIT
	    return MODIFY_CANT_TRANSMIT;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_MODIFY_C(char *name, int len, int arg)
{
    switch (name[8 + 0]) {
    case 'A':
	return constant_MODIFY_CA(name, len, arg);
    case 'O':
	if (strEQ(name + 8, "ONFIG_ERROR")) {	/* MODIFY_C removed */
#ifdef MODIFY_CONFIG_ERROR
	    return MODIFY_CONFIG_ERROR;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_MO(char *name, int len, int arg)
{
    if (2 + 5 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[2 + 5]) {
    case 'C':
	if (!strnEQ(name + 2,"DIFY_", 5))
	    break;
	return constant_MODIFY_C(name, len, arg);
    case 'I':
	if (strEQ(name + 2, "DIFY_INVALID_PARAM")) {	/* MO removed */
#ifdef MODIFY_INVALID_PARAM
	    return MODIFY_INVALID_PARAM;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (!strnEQ(name + 2,"DIFY_", 5))
	    break;
	return constant_MODIFY_N(name, len, arg);
    case 'S':
	if (!strnEQ(name + 2,"DIFY_", 5))
	    break;
	return constant_MODIFY_S(name, len, arg);
    case 'W':
	if (strEQ(name + 2, "DIFY_WRONG_STATE")) {	/* MO removed */
#ifdef MODIFY_WRONG_STATE
	    return MODIFY_WRONG_STATE;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_M(char *name, int len, int arg)
{
    switch (name[1 + 0]) {
    case 'A':
	if (strEQ(name + 1, "AXLEN_HOST")) {	/* M removed */
#ifdef MAXLEN_HOST
	    return MAXLEN_HOST;
#else
	    goto not_there;
#endif
	}
    case 'O':
	return constant_MO(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant(char *name, int len, int arg)
{
    errno = 0;
    switch (name[0 + 0]) {
    case 'A':
	return constant_A(name, len, arg);
    case 'F':
	if (strEQ(name + 0, "FALSE")) {	/*  removed */
#ifdef FALSE
	    return FALSE;
#else
	    goto not_there;
#endif
	}
    case 'L':
	return constant_L(name, len, arg);
    case 'M':
	return constant_M(name, len, arg);
    case 'P':
	return constant_P(name, len, arg);
    case 'T':
	if (strEQ(name + 0, "TRUE")) {	/*  removed */
#ifdef TRUE
	    return TRUE;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}


MODULE = IBM::LoadLeveler		PACKAGE = IBM::LoadLeveler

double
constant(sv,arg)
    PREINIT:
	STRLEN		len;
    INPUT:
	SV *		sv
	char *		s = SvPV(sv, len);
	int		arg
    CODE:
	RETVAL = constant(s,len,arg);
    OUTPUT:
	RETVAL


char *
ll_version()

LL_element *
ll_query(queryType)
	int queryType
	PROTOTYPE: $

int
ll_reset_request(object)	
	LL_element *object

LL_element *
ll_next_obj(object)	
	LL_element *object

int
ll_free_objs(object)
	LL_element *object

void
ll_deallocate(object)
	LL_element *object

int
ll_set_request(object,QueryFlags,ObjectFilter,DataFilter)
	LL_element *object
	int	QueryFlags
	char 	**ObjectFilter
	int	DataFilter

LL_element *
ll_get_objs(object,query_daemon,hostname,number,err)
	LL_element *object
	int	    query_daemon
	char	   *hostname
	int         number
	int         err
	PROTOTYPE: $$$$$
	CODE:
	{
	    RETVAL=ll_get_objs(object,query_daemon,hostname,&number,&err);
	}
	OUTPUT:
		number
		err
		RETVAL

void *
ll_get_data(object,Specification)
	LL_element *object
	int Specification       
	PROTOTYPE: $$
	PPCODE:
	{	switch (Specification)
		{
		case LL_JobManagementInteractiveClass:
		case LL_JobManagementAccountNo:
        	case LL_JobName:
        	case LL_JobSubmitHost:
        	case LL_StepAccountNumber:
        	case LL_StepComment:
        	case LL_StepEnvironment:
        	case LL_StepErrorFile:
        	case LL_StepHostName:
        	case LL_StepID:
        	case LL_StepInputFile:
        	case LL_StepIwd:
        	case LL_StepJobClass:
        	case LL_StepMessages:
        	case LL_StepName:
        	case LL_StepOutputFile:
        	case LL_StepShell:
        	case LL_StepHostList:
        	case LL_StepLoadLevelerGroup:
        	case LL_StepTaskGeometry:
        	case LL_StepTotalNodesRequested:
        	case LL_StepCkptFile:
        	case LL_StepLargePage:
		case LL_MachineArchitecture:
		case LL_MachineMachineMode:
		case LL_MachineName:
        	case LL_MachineOperatingSystem:
        	case LL_MachineStartdState:
		case LL_MachineStartExpr:
        	case LL_MachineSuspendExpr:
        	case LL_MachineContinueExpr:
        	case LL_MachineVacateExpr:
        	case LL_MachineKillExpr:
        	case LL_NodeRequirements:
        	case LL_NodeInitiatorCount:
        	case LL_TaskExecutable:
        	case LL_TaskExecutableArguments:
        	case LL_TaskInstanceMachineName:
        	case LL_AdapterInterfaceAddress:
        	case LL_AdapterName:
        	case LL_AdapterUsageProtocol:
        	case LL_AdapterCommInterface:
        	case LL_AdapterUsageMode:
        	case LL_AdapterUsageAddress:
       	 	case LL_CredentialGroupName:
        	case LL_CredentialUserName:
        	case LL_AdapterReqUsage:
		case LL_ClusterSchedulerType:
        	case LL_ResourceName:
        	case LL_ResourceRequirementName:
        	case LL_MachUsageMachineName:
        	case LL_EventUsageEventName:
		case LL_ColumnMachineName:
		    {
			char *pointer;
			int   rc;

		    	/* Char * data type */
		    	rc=ll_get_data(object,Specification,(void *)&pointer);
		    	/* printf("%d = %s\n",Specification,JobName); */
		    	if (rc >= 0)
			{
			    XPUSHs(sv_2mortal(newSVpv(pointer, 0)));
			    Safefree(pointer);
			    XSRETURN(1);
			}
			else
			    XSRETURN_UNDEF;
		    }
		    break ;
       		case LL_MachineAdapterList:
        	case LL_MachineAvailableClassList:
        	case LL_MachineFeatureList:
        	case LL_MachineConfiguredClassList:
        	case LL_MachineStepList:
        	case LL_MachineDrainingClassList:
        	case LL_MachineDrainClassList:
        	case LL_ClusterSchedulingResources:
        	case LL_ClusterDefinedResources:
        	case LL_ClusterEnforcedResources:
        	case LL_ColumnStepNames:
		    {
			char **array;
			char  *pointer;
			int    i;
			int    rc;

		    	/* array of char * data type */
			rc=ll_get_data(object,Specification,(void *)&array);
			if ( rc >= 0 )
			{
			    pointer=*array;
			    i=0;
			    while (pointer != NULL)
			    {
				/* printf("%d = %s\n",Specification,pointer); */
				XPUSHs(sv_2mortal(newSVpv(pointer, 0)));
				i++;
				Safefree(pointer);
				pointer=*(array+i);
			    }
			    XSRETURN(i);
			    Safefree(array);
			}
			else
			    XSRETURN_UNDEF;
		    }
		    break ;
	      case LL_MachinePoolList:
		    {
			int  **array;
			int   *pointer;
			int    i;
			int    rc;

		    	/* array of char * data type */
			rc=ll_get_data(object,Specification,(void *)&array);
			if ( rc >= 0 )
			{
			    i=0;
			    while (pointer != NULL)
			    {
				/* printf("%d = %s\n",Specification,pointer); */
		    		XPUSHs(sv_2mortal(newSViv((long)pointer)));
				i++;
				Safefree(pointer);
				pointer=*(array+i);
			    }	
			    Safefree(array);
			    XSRETURN(i);
			}
			else
			    XSRETURN_UNDEF;
			
		    }
		    break ;
		case LL_MachineLoadAverage:
        	case LL_MachineSpeed:
        	case LL_MachUsageMachineSpeed:
		    {
			double value;
			int rc;

		    	rc=ll_get_data(object,Specification,(void *)&value);
		    	/* printf("%d = %f\n",Specification,value); */
			if (rc >= 0)
			{
			    XPUSHs(sv_2mortal(newSVnv(value)));
			    XSRETURN(1);
			}
			else
			    XSRETURN_UNDEF;
		    }
		    break;
        	case LL_StepImageSize64:
		case LL_StepCpuLimitHard64:
		case LL_StepCpuLimitSoft64:
		case LL_StepCpuStepLimitHard64:
		case LL_StepCpuStepLimitSoft64:
		case LL_StepCoreLimitHard64:
		case LL_StepCoreLimitSoft64:
		case LL_StepDataLimitHard64:
		case LL_StepDataLimitSoft64:
		case LL_StepFileLimitHard64:
		case LL_StepFileLimitSoft64:
		case LL_StepRssLimitHard64:
		case LL_StepRssLimitSoft64:
		case LL_StepStackLimitHard64:
		case LL_StepStackLimitSoft64:
		case LL_StepWallClockLimitHard64:
		case LL_StepWallClockLimitSoft64:
		case LL_StepStepUserTime64:
		case LL_StepStepSystemTime64:
		case LL_StepStepMaxrss64:
		case LL_StepStepIxrss64:
		case LL_StepStepIdrss64:
		case LL_StepStepIsrss64:
		case LL_StepStepMinflt64:
		case LL_StepStepMajflt64:
		case LL_StepStepNswap64:
		case LL_StepStepInblock64:
		case LL_StepStepOublock64:
		case LL_StepStepMsgsnd64:
		case LL_StepStepMsgrcv64:
		case LL_StepStepNsignals64:
		case LL_StepStepNvcsw64:
		case LL_StepStepNivcsw64:
		case LL_StepStarterUserTime64:
		case LL_StepStarterSystemTime64:
		case LL_StepStarterMaxrss64:
		case LL_StepStarterIxrss64:
		case LL_StepStarterIdrss64:
		case LL_StepStarterIsrss64:
		case LL_StepStarterMinflt64:
		case LL_StepStarterMajflt64:
		case LL_StepStarterNswap64:
		case LL_StepStarterInblock64:
		case LL_StepStarterOublock64:
		case LL_StepStarterMsgsnd64:
		case LL_StepStarterMsgrcv64:
		case LL_StepStarterNsignals64:
		case LL_StepStarterNvcsw64:
		case LL_StepStarterNivcsw64:
		case LL_StepCkptTimeHardLimit64:
		case LL_StepCkptTimeSoftLimit64:
		case LL_MachineDisk64:
		case LL_MachineRealMemory64:
		case LL_MachineVirtualMemory64:
		case LL_MachineFreeRealMemory64:
		case LL_MachinePagesScanned64:
		case LL_MachinePagesFreed64:
		case LL_MachinePagesPagedIn64:
		case LL_MachinePagesPagedOut64:
		case LL_MachineLargePageSize64:
		case LL_MachineLargePageCount64:
		case LL_MachineLargePageFree64:
		case LL_ResourceInitialValue64:
		case LL_ResourceAvailableValue64:
		case LL_ResourceRequirementValue64:
		case LL_WlmStatCpuTotalUsage:
		case LL_WlmStatMemoryHighWater:
		case LL_DispUsageStepUserTime64:
		case LL_DispUsageStepSystemTime64:
		case LL_DispUsageStepMaxrss64:
		case LL_DispUsageStepIxrss64:
		case LL_DispUsageStepIdrss64:
		case LL_DispUsageStepIsrss64:
		case LL_DispUsageStepMinflt64:
		case LL_DispUsageStepMajflt64:
		case LL_DispUsageStepNswap64:
		case LL_DispUsageStepInblock64:
		case LL_DispUsageStepOublock64:
		case LL_DispUsageStepMsgsnd64:
		case LL_DispUsageStepMsgrcv64:
		case LL_DispUsageStepNsignals64:
		case LL_DispUsageStepNvcsw64:
		case LL_DispUsageStepNivcsw64:
		case LL_DispUsageStarterUserTime64:
		case LL_DispUsageStarterSystemTime64:
		case LL_DispUsageStarterMaxrss64:
		case LL_DispUsageStarterIxrss64:
		case LL_DispUsageStarterIdrss64:
		case LL_DispUsageStarterIsrss64:
		case LL_DispUsageStarterMinflt64:
		case LL_DispUsageStarterMajflt64:
		case LL_DispUsageStarterNswap64:
		case LL_DispUsageStarterInblock64:
		case LL_DispUsageStarterOublock64:
		case LL_DispUsageStarterMsgsnd64:
		case LL_DispUsageStarterMsgrcv64:
		case LL_DispUsageStarterNsignals64:
		case LL_DispUsageStarterNvcsw64:
		case LL_DispUsageStarterNivcsw64:
		case LL_EventUsageStepUserTime64:
		case LL_EventUsageStepSystemTime64:
		case LL_EventUsageStepMaxrss64:
		case LL_EventUsageStepIxrss64:
		case LL_EventUsageStepIdrss64:
		case LL_EventUsageStepIsrss64:
		case LL_EventUsageStepMinflt64:
		case LL_EventUsageStepMajflt64:
		case LL_EventUsageStepNswap64:
		case LL_EventUsageStepInblock64:
		case LL_EventUsageStepOublock64:
		case LL_EventUsageStepMsgsnd64:
		case LL_EventUsageStepMsgrcv64:
		case LL_EventUsageStepNsignals64:
		case LL_EventUsageStepNvcsw64:
		case LL_EventUsageStepNivcsw64:
		case LL_EventUsageStarterUserTime64:
		case LL_EventUsageStarterSystemTime64:
		case LL_EventUsageStarterMaxrss64:
		case LL_EventUsageStarterIxrss64:
		case LL_EventUsageStarterIdrss64:
		case LL_EventUsageStarterIsrss64:
		case LL_EventUsageStarterMinflt64:
		case LL_EventUsageStarterMajflt64:
		case LL_EventUsageStarterNswap64:
		case LL_EventUsageStarterInblock64:
		case LL_EventUsageStarterOublock64:
		case LL_EventUsageStarterMsgsnd64:
		case LL_EventUsageStarterMsgrcv64:
		case LL_EventUsageStarterNsignals64:
		case LL_EventUsageStarterNvcsw64:
		    {
			int64_t value;
			int     rc;

		    	rc=ll_get_data(object,Specification,&value);
		    	/* printf("%d = %lld\n",Specification,value); */
			if (rc >= 0)
			{
			    XPUSHs(sv_2mortal(newSViv(CHECK64(value))));
			    XSRETURN(1);
			}
			else
			    XSRETURN_UNDEF;
		    }
		    break ;

		default :
		    {
			void *pointer;
			int   rc;

		    	rc=ll_get_data(object,Specification,(void *)&pointer);
		    	/*printf("%d = %ld\n",Specification,pointer); */
			if (rc >= 0)
			{
			    XPUSHs(sv_2mortal(newSViv((long)pointer)));
			    XSRETURN(1);
			}
			else
			    XSRETURN_UNDEF;

		    }
		    break ;
		}
	}

void *
llsubmit(job_cmd_file, monitor_program,monitor_arg)
	char *job_cmd_file
	char *monitor_program
	char *monitor_arg

	PPCODE:
	{
	    LL_job	job_info;
	    int		 rc;
	    int		i;
	    AV		*steps;

	    rc=llsubmit(job_cmd_file,monitor_program,monitor_arg,&job_info,LL_JOB_VERSION);
	    if ( rc != 0 )
		XSRETURN_UNDEF;
	    else
	    {
		XPUSHs(sv_2mortal(newSVpv(job_info.job_name, 0)));
		XPUSHs(sv_2mortal(newSVpv(job_info.owner, 0)));
		XPUSHs(sv_2mortal(newSVpv(job_info.groupname, 0)));
		XPUSHs(sv_2mortal(newSViv((long)job_info.uid)));
		XPUSHs(sv_2mortal(newSViv((long)job_info.gid)));
		XPUSHs(sv_2mortal(newSVpv(job_info.submit_host, 0)));
		XPUSHs(sv_2mortal(newSViv((long)job_info.steps)));
		steps=(AV *)sv_2mortal((SV *)newAV());
		for(i=0;i!=job_info.steps;i++)
		{
		    HV *step;

		    step=unpack_job_step(job_info.step_list[i]);
		    av_push(steps,newRV((SV *)step));
		}	
		XPUSHs(sv_2mortal(newRV((SV *)steps)));
		/* All Data now in Perl structures free the LoadLeveler construct */
		llfree_job_info(&job_info,LL_JOB_VERSION);
	    }	    
	}

void *
ll_get_jobs()

	PPCODE:
	{
	    LL_get_jobs_info info;
	    int rc;
	    AV *jobs;
	    int i;

	    rc=ll_get_jobs(&info);
	    if (rc != 0 )
		XSRETURN_IV(rc);
	    else
	    {
		XPUSHs(sv_2mortal(newSViv((long)info.version_num)));
		XPUSHs(sv_2mortal(newSViv((long)info.numJobs)));
		jobs=(AV *)sv_2mortal((SV *)newAV());
		for(i=0;i!=info.numJobs;i++)
		{
		    AV *job;

		    job=unpack_ll_job(info.JobList[i]);
		    av_push(jobs,newRV((SV *)job));
		}	
		XPUSHs(sv_2mortal(newRV((SV *)jobs)));
		ll_free_jobs(&info);
	    }
	}	

void *
ll_get_nodes()

	PPCODE:
	{
	    LL_get_nodes_info info;
	    int rc;
	    AV *nodes;
	    int i;

	    rc=ll_get_nodes(&info);
	    if (rc != 0 )
		XSRETURN_IV(rc);
	    else
	    {
		XPUSHs(sv_2mortal(newSViv((long)info.version_num)));
		XPUSHs(sv_2mortal(newSViv((long)info.numNodes)));
		nodes=(AV *)sv_2mortal((SV *)newAV());
		for(i=0;i!=info.numNodes;i++)
		{
		    AV *node;

		    node=unpack_ll_node(info.NodeList[i]);
		    av_push(nodes,newRV((SV *)node));
		}	
		XPUSHs(sv_2mortal(newRV((SV *)nodes)));
		ll_free_nodes(&info);
	    }
	}	

int
ll_control(control_op,host_list,user_list,job_list, class_list,priority)
	int    control_op
	char **host_list
	char **user_list 
	char **job_list
	char **class_list
	int    priority

	CODE:
	{
	    RETVAL=ll_control(LL_CONTROL_VERSION,control_op,host_list,user_list,job_list, class_list,priority);
	}
	OUTPUT:

		RETVAL

void *
ll_preempt(job_step,type)
	char *job_step
        int    type


	PPCODE:
	{
	    LL_element *errObj = NULL;
	    int		rc;

	    rc=ll_preempt(LL_API_VERSION,&errObj,job_step,type);

	    if (rc == API_OK )
	    {
		XSRETURN_IV(rc);
	    }
	    else
	    {
		XPUSHs(sv_2mortal(newSViv((long)rc)));
		XPUSHs(sv_2mortal(newSViv((long)errObj)));
	    } 
	
	}

int
ll_start_job(cluster,proc,from_host,node_list)
        int    cluster
	int    proc
	char  *from_host
	char **node_list

	CODE:
	{
	    LL_start_job_info	job_info;

	    job_info.version_num=LL_PROC_VERSION;
	    job_info.nodeList=node_list;
	    job_info.StepId.cluster=cluster;
	    job_info.StepId.proc=proc;
	    job_info.StepId.from_host=from_host;
	    RETVAL=ll_start_job(&job_info);
	}		
	OUTPUT:
		RETVAL

int
ll_terminate_job(cluster,proc,from_host,msg)
        int    cluster
	int    proc
	char  *from_host
	char  *msg

	CODE:
	{
	    LL_terminate_job_info	job_info;

	    job_info.version_num=LL_PROC_VERSION;
	    job_info.msg=msg;
	    job_info.StepId.cluster=cluster;
	    job_info.StepId.proc=proc;
	    job_info.StepId.from_host=from_host;
	    RETVAL=ll_terminate_job(&job_info);
	}		
	OUTPUT:
		RETVAL

char *
ll_error(errObj,print_to)
	 LL_element *errObj
	 int	     print_to

