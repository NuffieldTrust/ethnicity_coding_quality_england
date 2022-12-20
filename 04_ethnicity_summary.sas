/* Summarise variables by ethnicity */


libname eth "~\Ethnicity coding\Sensitive";-
libname ethpi "~\Ethnicity coding\Sensitive\pi";

libname twoway "~\Ethnicity coding\Sensitive\twoway";
libname outip  "~\Ethnicity coding\Sensitive\twoway\ip";
libname outae  "~\Ethnicity coding\Sensitive\twoway\ae";
libname outop  "~\Ethnicity coding\Sensitive\twoway\op";
libname outec  "~\Ethnicity coding\Sensitive\twoway\ec";
libname outcs  "~\Ethnicity coding\Sensitive\twoway\cs";


proc sql;
	create table eth.overview
		(
			dataset char(2),
			fyear num,
			ethnos_clean char(2),
			records num,
			people num
		)
;
	insert into eth.overview
	select
		'ip' as dataset
		, fyear
		, ethnos_clean 
		, count(*) as records
		, count(distinct xhesid) as people
	from eth.vw_ip
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201011 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op10
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201112 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op11
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201213 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op12
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201314 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op13
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201415 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op14
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201516 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op15
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201617 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op16
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201718 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op17
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201819 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op18
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 201920 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op19
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'op' as dataset, 202021 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op20m
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201011 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae10
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201112 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae11
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201213 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae12
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201314 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae13
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201415 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae14
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201516 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae15
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201617 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae16
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201718 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae17
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201819 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae18
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ae' as dataset, 201920 as fyear, ethnos_clean, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae19m
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ec' as dataset, 201920 as fyear, ethnos_clean, count(*) as records, count(distinct TOKEN_PERSON_ID) as people
	from eth.vw_ec19
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'ec' as dataset, 202021 as fyear, ethnos_clean, count(*) as records, count(distinct TOKEN_PERSON_ID) as people
	from eth.vw_ec20m
	group by 
		fyear
		, ethnos_clean 
;
	insert into eth.overview
	select 'cs' as dataset, 201920 as fyear, ethnos_clean, count(*) as records, count(distinct UniqueCYPHS_ID_Patient) as people
	from eth.vw_cs19
	group by 
		fyear
		, ethnos_clean 
;
quit;



/* Helper macros */


%macro ethnossummary (dslist, varlist, libout);
	/*A macro for two way frequency tables*/
	%do i=1 %to %sysfunc(countw(&varlist.)); * for each variable;
		%let var = %scan(&varlist., &i.);
		%do j=1 %to %sysfunc(countw(&dslist.)); * for each dataset;
			%let lds = %scan(&dslist., &j.);
			%let ds = %scan(&lds., countw(&lds., %str(.))); /* parse ds name from lib.ds */
				proc freq data = &lds. noprint;
					tables &var.* ethnos_clean * fyear /out=&libout..&ds.&var. ;
				run;
			%end;
	%end;
%mend ethnossummary;


/*do proc freq for each dataset in list*/
/*combine for each year*/

/*do that for each variable*/



%macro ethnostwoway (lib, ds, libout, var);
	/*A macro for two way frequency tables*/
	proc freq data = &lib..&ds. noprint;
		tables &var.* ethnos * fyear /out=&libout..&ds.&var. ;
	run;

%mend ethnostwoway;

%macro ethnostwowaydrive (lib, ds, libout, inputlist);
	%do i=1 %to %sysfunc(countw(&inputlist.));
		%let word = %scan(&inputlist., &i.);
		%ethnostwoway(&lib., &ds., &libout., &word.);
		%end;
%mend ethnostwowaydrive;


/* Multiple breakdowns*/

proc freq data = eth.ip (where = (classpat = 1 or classpat = 2)) noprint;
		tables sex * startage * ethnos * fyear /out=outip.sex_startage(drop=percent);
	run;

proc freq data = eth.ip (where = (classpat = 1 or classpat = 2)) noprint;
		tables is_nhs * admimeth * ethnos * fyear /out=outip.is_nhs_admimeth(drop=percent);
	run;


proc freq data = eth.vw_ip noprint;
		tables gender_age * ethnos * fyear /out=outip.gender_age(drop=percent);
	run;

proc freq data = eth.vw_ip noprint;
		tables is_nhs * admimeth * ethnos * fyear /out=outip.is_nhs_admimeth(drop=percent);
	run;


%macro ethnosae (libout, var);
	/*A macro for two way frequency tables*/
	proc freq data = eth.vw_ae10 noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae10&var.(drop=percent);
	run;
	proc freq data = eth.vw_ae11 noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae11&var.(drop=percent);
	run;
	proc freq data = eth.vw_ae12 noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae12&var.(drop=percent);
	run;
	proc freq data = eth.vw_ae13 noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae13&var.(drop=percent);
	run;
	proc freq data = eth.vw_ae14 noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae14&var.(drop=percent);
	run;
	proc freq data = eth.vw_ae15 noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae15&var.(drop=percent);
	run;
	proc freq data = eth.vw_ae16 noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae16&var.(drop=percent);
	run;
	proc freq data = eth.vw_ae17 noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae17&var.(drop=percent);
	run;
	proc freq data = eth.vw_ae18 noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae18&var.(drop=percent);
	run;
	proc freq data = eth.vw_ae19m noprint;
		tables &var.* ethnos_clean * fyear /out=work.ae19m&var.(drop=percent);
	run;

	%if &syserr>4 %then %return; /* stop executing macro if an error is found*/

	data &libout..&var.;
		set 
			work.ae10&var.
			work.ae11&var.
			work.ae12&var.
			work.ae13&var.
			work.ae14&var.
			work.ae15&var.
			work.ae16&var.
			work.ae17&var.
			work.ae18&var.
			work.ae19m&var.;
	run;
	proc datasets library = work;
		delete ae10&var.
			ae11&var.
			ae12&var.
			ae13&var.
			ae14&var.
			ae15&var.
			ae16&var.
			ae17&var.
			ae18&var.
			ae19m&var.;
	run;

%mend ethnosae;

%ethnosae(outae, aedepttype);

%macro ethnosop (libout, var);
/*A macro for two way frequency tables*/
  proc freq data = eth.vw_op10 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op10&var.(drop=percent);
  run;
  proc freq data = eth.vw_op11 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op11&var.(drop=percent);
  run;
  proc freq data = eth.vw_op12 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op12&var.(drop=percent);
  run;
  proc freq data = eth.vw_op13 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op13&var.(drop=percent);
  run;
  proc freq data = eth.vw_op14 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op14&var.(drop=percent);
  run;
  proc freq data = eth.vw_op15 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op15&var.(drop=percent);
  run;
  proc freq data = eth.vw_op16 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op16&var.(drop=percent);
  run;
  proc freq data = eth.vw_op17 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op17&var.(drop=percent);
  run;
  proc freq data = eth.vw_op18 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op18&var.(drop=percent);
  run;
  proc freq data = eth.vw_op19 noprint;
  tables &var.* ethnos_clean * fyear /out=work.op19&var.(drop=percent);
  run;
  proc freq data = eth.vw_op20m noprint;
  tables &var.* ethnos_clean * fyear /out=work.op20m&var.(drop=percent);
  run;

  %if &syserr>4 %then %return; /* stop executing macro if an error is found*/

  data &libout..op&var.;
  set 
	  work.op10&var.
	  work.op11&var.
	  work.op12&var.
	  work.op13&var.
	  work.op14&var.
	  work.op15&var.
	  work.op16&var.
	  work.op17&var.
	  work.op18&var.
	  work.op19&var.
	  work.op20m&var.;
  run;

	proc datasets library = work;
		delete op10&var.
			op11&var.
			op12&var.
			op13&var.
			op14&var.
			op15&var.
			op16&var.
			op17&var.
			op18&var.
			op19&var.
			op20m&var.;
	run;

%mend ethnosop;

%macro ethnosip (libout, var);
/*A macro for two way frequency tables*/
  proc freq data = eth.vw_ip noprint;
  tables &var.* ethnos_clean * fyear /out=&libout..&var.(drop=percent);
  run;
 
%mend ethnosip;


%macro ethnosaedrive (libout, inputlist);
	%do i=1 %to %sysfunc(countw(&inputlist.));
		%let word = %scan(&inputlist., &i.);
		%ethnosae(&libout., &word.);
		%end;
%mend ethnosaedrive;

%macro ethnosopdrive (libout, inputlist);
	%do i=1 %to %sysfunc(countw(&inputlist.));
		%let word = %scan(&inputlist., &i.);
		%ethnosop(&libout., &word.);
		%end;
%mend ethnosopdrive;

%macro ethnosipdrive (libout, inputlist);
	%do i=1 %to %sysfunc(countw(&inputlist.));
		%let word = %scan(&inputlist., &i.);
		%ethnosip(&libout., &word.);
		%end;
%mend ethnosipdrive;


%macro ethnostwowaydrive (lib, ds, libout, inputlist);
	%do i=1 %to %sysfunc(countw(&inputlist.));
		%let word = %scan(&inputlist., &i.);
		%ethnostwoway(&lib., &ds., &libout., &word.);
		%end;
%mend ethnostwowaydrive;




/* IP */
%ethnosipdrive(outip,
	admidate admimeth admisorc bedyear classpat diag_01
	disdate disdest dismeth gender_age gortreat gpprac imd_decile 
	los mainspef nhsnoind opertn_01 procode3 
	rururb_ind sex startage sushrg tretspef
);

  proc freq data = eth.vw_ip noprint;
  	tables los * is_nhs * ethnos_clean * fyear /out=outip.los_is_nhs(drop=percent);
  run;
  proc freq data = eth.vw_ip noprint;
  	tables sex * startage * ethnos_clean * fyear /out=outip.sex_startage(drop=percent);
  run;

  proc freq data = eth.vw_ip noprint;
  	tables CCG_Responsibility * ethnos_clean * fyear /out=outip.ccg_responsibility(drop=percent);
  run;

proc sql;
	create table outip.ccg_responsibility2 as
	select CCG_RESPONSIBILITY
		, ethnos_clean, fyear
		, count(*) as records
		, count(distinct xhesid) as people
	from eth.vw_ip
	group by
		CCG_RESPONSIBILITY
		, ethnos_clean, fyear
;
quit;




/* AE */
%ethnosaedrive(outae,
	 aearrivalmode aedepttype activage aeattendcat aeattenddisp aeincloctype 
	 aepatgroup aerefsource arrivaltime arrivalage carersi concltime 
	 depdur diag2_1 diaga_1 domproc gender_age gortreat gpprac imd04_decile imd04c 
	 imd04ed imd04em imd04hd imd04hs imd04i imd04ia imd04ic imd04le invest_1 
	 nhsnoind procode3 rururb_ind sex sushrg treat2_1
);

/* OP */
%ethnosopdrive(outop,
	admincat apptage atentype attended carersi diag_01 firstatt gender_age
	gortreat gpprac hatreat imd_decile imd04 imd04c imd04ed imd04em imd04hd 
	imd04hs imd04i imd04ia imd04ic imd04le mainspef nhsnoind 
	operstat opertn_01 outcome pcfound priority procode3 protype 
	refsourc rururb_ind servtype sex stafftyp sushrg tretspef wait_ind waiting
);