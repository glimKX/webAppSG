//////////////////////////////////////////////////////////////////////////////////////////////////
//	cron.q script which loads up with all tick templates											//
//	q script will define functions in .z.ts						//
//////////////////////////////////////////////////////////////////////////////////////////////////

\d .cron

/init job schema
jobs:1!flip `function`args`freq`stime`etime`enabled!"S*FZZB"$\:();

/define analytics for running cron
runJob:{.log.out "Running cronJob --- ",.Q.s1 (x`function;x`args);
	$[1=count x`args;
		@[{x[0] @ x[1]};(x`function;x`args);{.log.err "Unable to run cronJob due to ",.Q.s x}];
		@[{x[0] . x[1]};(x`function;x`args);{.log.err "Unable to run cronJob due to ",.Q.s x}]
	];
	update stime:.z.Z+freq from `.cron.jobs where function = x`function;
	if[first exec stime>etime from .cron.jobs where function = x`function;
		.log.out .Q.s1[x`function]," Function has stime>etime, no longer needed";
		.cron.removeJob x`function;
	];
	.log.out "Finished running cronJob";
 }

/define analytics to add job to cron
addJob:{[function;freq;args;stime;etime;enabled]
	//freq is in terms of day
	if[stime=-0wz;stime:.z.Z];
	.log.out "Adding cronJob --- ",.Q.s1 `function`args`freq`stime`etime`enabled!(function;args;freq;stime;etime;enabled);
	@[{`.cron.jobs upsert x};
		`function`args`freq`stime`etime`enabled!(function;args;freq;stime;etime;enabled);
		{.log.err "Unable to add to cronJob due to ",.Q.s x}]
 }

/define analytics to remove job from cron
removeJob:{[func]
	.log.out "Removing cronJob --- ",.Q.s1 func;
	//protected eval
	delete from `.cron.jobs where function = func;
 }

/define analytic to switch on/off job in cron
switchJob:{[func]
	.log.out "Switch cronJob --- ",.Q.s1 func;
	//protected eval
	update not enabled from `.cron.jobs where function = func;
	-1 .Q.s1[func]," was switched off";
 }

/define analytic to find jobs to run
findJob:{jobs:0!select from .cron.jobs where .z.P within (stime;etime),enabled=1b;
	if[count jobs;
		.cron.runJob each jobs
	];
 }

addJob[`keepType;0f;(::);-0wz;0wz;0b];

.z.ts:{findJob[]}
\d .
\t 1
