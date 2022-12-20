/* Data pre-processing */


/* This script:
/* - loads HES data
/* - processes inpatient data (removes duplicates and converts to inpatient spells)
/* - creates some views and tables of interest for all

/* Load data 



options obs=max mlogic symbolgen mprint;

%global startyear endyear;

%let startyear = 2010;     
%let endyear = 2021;

libname eth "~\Ethnicity coding\Sensitive";-
libname ethpi "~\Ethnicity coding\Sensitive\pi";

libname twoway "~\Ethnicity coding\Sensitive\twoway";
libname outip  "~\Ethnicity coding\Sensitive\twoway\ip";
libname outae  "~\Ethnicity coding\Sensitive\twoway\ae";
libname outop  "~\Ethnicity coding\Sensitive\twoway\op";
libname outec  "~\Ethnicity coding\Sensitive\twoway\ec";
libname outcs  "~\Ethnicity coding\Sensitive\twoway\cs";


libname hes "~DATA\HES datasets";

/* The latest date we had available at the time */
libname hesnew "~DATA\hes data Y2021 M10 - received 20210315\Formatted";
libname ae "~DATA\hes data Y1920 M10 - received 20200317\Formatted";

libname ec "~\ECDS";
libname ecnew "~\ECDS\20210315 transfer\Formatted";

libname csds19 "~\DATA\CSDS\20200714 transfer\Formatted";
libname csds1718 "~DATA\CSDS\20191021 transfer\Formatted";

libname hescs18 "~\HES_CSDS_Bridge_File\20200622 transfer\Formatted";
libname hescs19 "~\HES_CSDS_Bridge_File\20200807 transfer\Formatted";




/*Reading all lines of HES*/

%macro FileReadLoop;
    %global i iplus ifile ilib admitext k;
    %let k = 0;

    %Do i=&startyear-2000 %to &endyear-2000;

        %if &i lt 20 %then %do; /* If it's not the most recent data*/
            %let k = %eval(&k+1);
            %put &i;
        %if &i lt 10 %then %let iplus=0&i;
            %else %let iplus=&i;
            %let LibChoice = hes;
        %end;
        %else %do;
            %let iplus = 20m;
            %let LibChoice = hesnew;
        %end;

        %if &i lt 16 %then %do;
            %let lsoa = soal;
        %end;
        %else %do;
            %let lsoa = lsoa01;
        %end;

		%if &i lt 14 %then %do;
            %let ccg  = PCTCODE06;
        %end;
        %else %do;
            %let ccg = CCG_RESPONSIBILITY;
        %end;

        Data temp;
            rename &lsoa.=lsoa;
            length &lsoa. $10.;
			rename &ccg. = CCG_RESPONSIBILITY;
            set &libchoice..ip&iplus /*(where = (&selection_criteria.))*/;

            keep admidate admimeth diag_01--diag_20 disdate dismeth bedyear spelbgin classpat gortreat ethnos rururb_ind disdest gpprac nhsnoind
                epiend epistart speldur spelend epidur epiorder epistat epitype sitetret resladst procode3 procodet
                procode endage startage sex imd04 imd04rk xhesid &lsoa. sushrg tretspef admisorc mainspef Pconsult
                opertn_01--opertn_24 opdate_01 &ccg. epikey
				;
        run;

        Data hes_all;
            %if &k=1 %then %do;
                set temp;
            %end;
            %else %do;
                set hes_all temp;
            %end;
        Run;

    %end;
	
	proc datasets library = work;
		delete temp;
	run;
	
%mend FileReadLoop;

%FileReadLoop;


Proc means data=hes_all min max noprint;
    var epistart;
    output out=dates min=min max=max;
    format min date9. max date9.;
run;


Data hes_all_temp_1;
    set hes_all;
    Code1 = xhesid;
    Code2 = year(admidate) * 10000 + month(admidate) * 100 + day(admidate);
    Code2_str = put(Code2, 8.);
    Code3 = procode3;
    Code4 = admimeth;
    SpellID = Cat(Code1, Code2_str, Code3, Code4);
    Dummy=1;
run;

Proc sort data=hes_all_temp_1;
    by spellid epistart epiend admimeth diag_01 DIAG_02 DIAG_03 DIAG_04 admisorc mainspef tretspef pconsult sushrg;
run;

Data dup_flag;
    set hes_all_temp_1;
    retain oldspellid oldepistart oldepiend oldadmimeth olddiag_01 olddiag_02 olddiag_03 olddiag_04 oldadmisorc oldmainspef oldtretspef oldpconsult oldsushrg;
    by spellid epistart epiend admimeth diag_01 diag_02 diag_03 diag_04 admisorc mainspef tretspef pconsult sushrg;
    if first.spellid=0 then do;
        if spellid=oldspellid and epistart=oldepistart and epiend=oldepiend and admimeth=oldadmimeth and diag_01=olddiag_01 and
            diag_02=olddiag_02 AND diag_03=olddiag_03 and diag_04=olddiag_04 and
            admisorc=oldadmisorc and mainspef=oldmainspef and tretspef=oldtretspef and pconsult=oldpconsult and sushrg=oldsushrg then Dup=1;
        Else Dup=0;
    end;
    else Dup=0;
    oldspellid=spellid;
    oldepistart=epistart;
    oldepiend=epiend;
    oldadmimeth=admimeth;
    olddiag_01=diag_01;
    olddiag_02=diag_02;
    olddiag_03=diag_03;
    olddiag_04=diag_04;
    oldadmisorc=admisorc;
    oldmainspef=mainspef;
    oldtretspef=tretspef;
    oldpconsult=pconsult;
    oldsushrg=sushrg;

run;


proc freq data=dup_flag;
    table dup;
run;

data ip_dup_free;
	set dup_flag;
	where dup = 0;
	keep spellid admidate admimeth diag_01--diag_20 disdate dismeth bedyear spelbgin classpat gortreat ethnos rururb_ind disdest gpprac nhsnoind
                epiend epistart speldur spelend epidur epiorder epistat epitype sitetret resladst procode3 procodet
                procode endage startage sex imd04 imd04rk xhesid lsoa sushrg tretspef admisorc mainspef Pconsult
                opertn_01--opertn_24 opdate_01 CCG_RESPONSIBILITY epikey;

run;



/* Ordering criteria: */
/* Two episodes starting on same day - the one with the earlier end date comes 
first (requires epistart=epiend for the first episodes) */
/* Two starting and ending on same day - if one is flagged with spelend="Y" 
then this comes second. */

Proc sort data=ip_dup_free;
	by spellid epistart epiend spelend;
run;

/* Create new epiorder variable and spell start and end flags. */
/* Spells that remain incomplete are not flagged as having finished. */
/* LOS calculated when a spell has finished */

Data NoDups3;
	set ip_dup_free;
	Retain Choose_patient NT_epiorder;
	by spellid epistart epiend spelend;
	if first.spellid = 1 then do;
		NT_epiorder=1;
		if epistart=admidate then do;
			Choose_patient="Y";
			NT_spell_begin="Y";
		end;
		Else do;
			Choose_patient="N";
			NT_spell_begin="N";
		End;
	End;
	Else do;
		NT_spell_begin="N";
		NT_epiorder=NT_epiorder+1;
	End;
	if last.spellid = 1 and disdate ge admidate then do;
		NT_spell_end="Y";
		LOS = disdate - admidate;
	End;
	Else NT_spell_end="N";
	Diag_01_4char = substr(diag_01,1,4);
run;

/*Do some checking here of epiorders*/

proc freq data=nodups3;
	where epiorder le 5 and NT_epiorder le 5;
	tables epiorder*NT_epiorder /nopercent nocol norow;
Run;

Data nodups3;
	set nodups3;
	if choose_patient = "N" then delete;
run;

/*Create spell order*/

Proc sort data=nodups3;
	by spellid NT_epiorder disdate;
Run;

Data nodups4;
	set nodups3;
	retain spellorder oldhesid;
	by spellid NT_epiorder disdate;
	if _n_ = 1 then do;
 		SpellOrder = 1;
	end;
	else if first.spellid = 1 and xhesid = oldhesid then do;
		spellorder = spellorder + 1;
	end;
	else if first.spellid = 1 and xhesid ne oldhesid then do;
		spellorder = 1;
	end;
	
	oldhesid = xhesid;
run;

/*Find out what spells to include*/

Data FirstEps;
	set nodups4;
	where NT_epiorder = 1; * and Hospital ne "Other";
	keep spellid;
Run;

Data LastEps;	
	set nodups4;
	where NT_spell_end = "Y";
	keep spellid;
Run;

Proc sort data=FirstEps;
	by spellid;
Run;

Proc sort data=LastEps;
	by spellid;
Run;


data nodups5;
	set nodups4;
	where NT_spell_end = "Y";
	if month(disdate) <= 3 then
		do;
			fyear = (year(disdate) - 1) * 100 + year(disdate) - 2000;
		end;
	else
		do;
			fyear = year(disdate) * 100 + year(disdate) - 1999;
		end;
run;

data ip;
	set nodups5;
	where year(fyear) >= &startyear;
run;

data eth.ipotherclasspat;
	set ip(where=(classpat ne 1 and classpat ne 2 and classpat ne 5));
run;

data eth.ip;
	set ip(where=(classpat = 1 or classpat = 2 or classpat = 5));
	is_nhs = substr(procode3,1,1) in ('R', 'T', '5');
run;


/* Now create views */
proc sql;
	create view eth.vw_ip as
	select *
		, 'ip' as dataset
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when startage < 5 then '00to04'
						when startage < 18 then '05to17'
						when startage < 65 then '18to64'
						when startage < 80 then '65to79'
						when startage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age

		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
		, catx(''
			, case 
				when is_nhs = 1 then 'NHS'
				else 'Independent'
				end
			, case 
				when admimeth like '1%' then 'Elective'
				else 'Other'
				end) as is_nhs_admimeth
		, case 
			when startage < 120 then startage 
			when startage > 7000 then 0
			else .
			end as age_clean
		, case 
			when admimeth like '1%' then 'Elective'
			when admimeth like '2%' then 'Emergency'
			when admimeth like '3%' then 'Maternity'
			else 'Other'
			end as admimeth_clean
		, case when dismeth = 4 then 1 else 0 end as died
		, case when ethnos in ('X', '99') then 1 else 0 end as ethnos_not_known		
		, case when ethnos in ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'R', 'S') then 1 else 0 end as ethnos_known
        , case when ethnos = 'Z' then 1 else 0 end as ethnos_not_stated	
        , case when ethnos = 'S' then 1 else 0 end as ethnos_any_other	
		, case when ethnos in ('C', 'G', 'L', 'P', 'S') then 1 else 0 end as ethnos_all_other
		, catx(' ', case 
			when admimeth like '1%' then 'Elective'
			when admimeth like '2%' then 'Emergency'
			when admimeth like '3%' then 'Maternity'
			else 'Other'
			end
			, case 
				when los = 0 then "0 days"
				when los = 1 then "1 day"
				when los ge 2 and los le 7 then "2-7 days"
				when los ge 8 and los le 14 then "8-14 days"
				when los ge 15 and los le 21 then "15-21 days"
				when los ge 22 and los le 28 then "22-27 days"
				when los gt 28 then "More than 28 days"
				else "Unknown" end) as admimeth_los
    
	from eth.ip
;
quit;

* ECDS;
proc sql;
	create view eth.vw_ec19 as
	select *, 'ec' as dataset, 201920 as fyear
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when STATED_GENDER = '1' then 'M' 
					when STATED_GENDER = '2' then 'F'
					else 'U'
					end
				, case when AGE_AT_CDS_ACTIVITY_DATE < 5 then '00to04'
						when AGE_AT_CDS_ACTIVITY_DATE < 18 then '05to17'
						when AGE_AT_CDS_ACTIVITY_DATE < 65 then '18to64'
						when AGE_AT_CDS_ACTIVITY_DATE < 80 then '65to79'
						when AGE_AT_CDS_ACTIVITY_DATE >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
	from ec.ec19 
;
	create view eth.vw_ec20m as
	select *, 'ec' as dataset, 202021 as fyear
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when STATED_GENDER = '1' then 'M' 
					when STATED_GENDER = '2' then 'F'
					else 'U'
					end
				, case when AGE_AT_CDS_ACTIVITY_DATE < 5 then '00to04'
						when AGE_AT_CDS_ACTIVITY_DATE < 18 then '05to17'
						when AGE_AT_CDS_ACTIVITY_DATE < 65 then '18to64'
						when AGE_AT_CDS_ACTIVITY_DATE < 80 then '65to79'
						when AGE_AT_CDS_ACTIVITY_DATE >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
	from ecnew.ec20m
;
quit;


*Community Services Data Set views;

proc sql;
	create view eth.vw_cs19 as
    select *, 201920 as fyear
		, case when ethniccat = 'X' then '99'
				when ethniccat not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethniccat 
			end as ethnos_clean
		, catx(''
				, case when Gender = '1' then 'M' 
					when Gender = '2' then 'F'
					else 'U'
					end
				, case when age_servicereferralreceiveddate_ < 5 then '00to04'
						when age_servicereferralreceiveddate_ < 18 then '05to17'
						when age_servicereferralreceiveddate_ < 65 then '18to64'
						when age_servicereferralreceiveddate_ < 80 then '65to79'
						when age_servicereferralreceiveddate_ >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
    from csds19.Demographicsandreferral19 
    where pseudo_uniqueservicereq_id ne "" and referraldate ge "01Apr15"d  
;

quit;




*Outpatients views;
proc sql;
	create view eth.vw_op10 as
	select 'op' as dataset, 201011 as fyear, * 
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
		
	from hes.op10 
	where attended in (5, 6)
;
	create view eth.vw_op11 as
	select 'op' as dataset, 201112 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.op11 
	where attended in (5, 6)
;
	create view eth.vw_op12 as
	select 'op' as dataset, 201213 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.op12 
	where attended in (5, 6)
;
	create view eth.vw_op13 as
	select 'op' as dataset, 201314 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.op13 
	where attended in (5, 6)
;
	create view eth.vw_op14 as
	select 'op' as dataset, 201415 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.op14 
	where attended in (5, 6)
;
	create view eth.vw_op15 as
	select 'op' as dataset, 201516 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.op15 
	where attended in (5, 6)
;
	create view eth.vw_op16 as
	select 'op' as dataset, 201617 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.op16 
	where attended in (5, 6)
;
	create view eth.vw_op17 as
	select 'op' as dataset, 201718 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.op17 
	where attended in (5, 6)
;
	create view eth.vw_op18 as
	select 'op' as dataset, 201819 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.op18 
	where attended in (5, 6)
;
	create view eth.vw_op19 as
	select 'op' as dataset, 201920 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.op19 
	where attended in (5, 6)
;
	create view eth.vw_op20m as
	select 'op' as dataset, 202021 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when apptage < 5 then '00to04'
						when apptage < 18 then '05to17'
						when apptage < 65 then '18to64'
						when apptage < 80 then '65to79'
						when apptage >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hesnew.op20m 
	where attended in (5, 6)
;
quit;

* A&E dataset views;
proc sql;
	create view eth.vw_ae10 as
	select 'ae' as dataset, 201011 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.ae10 
;
	create view eth.vw_ae11 as
	select 'ae' as dataset, 201112 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.ae11 
;
	create view eth.vw_ae12 as
	select 'ae' as dataset, 201213 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.ae12 
;
	create view eth.vw_ae13 as
	select 'ae' as dataset, 201314 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.ae13 
;
	create view eth.vw_ae14 as
	select 'ae' as dataset, 201415 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.ae14 
;
	create view eth.vw_ae15 as
	select 'ae' as dataset, 201516 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.ae15 
;
	create view eth.vw_ae16 as
	select 'ae' as dataset, 201617 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.ae16 
;
	create view eth.vw_ae17 as
	select 'ae' as dataset, 201718 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.ae17 
;
	create view eth.vw_ae18 as
	select 'ae' as dataset, 201819 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from hes.ae18 
;
	create view eth.vw_ae19m as
	select 'ae' as dataset, 201920 as fyear, *
		, case when ethnos = 'X' then '99'
				when ethnos not in ('A', 'B', 'C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z', '99') then 'U' 
				else ethnos 
			end as ethnos_clean
		, catx(''
				, case when sex = 1 then 'M' 
					when sex = 2 then 'F'
					else 'U'
					end
				, case when arrivalage  < 5 then '00to04'
						when arrivalage  < 18 then '05to17'
						when arrivalage  < 65 then '18to64'
						when arrivalage  < 80 then '65to79'
						when arrivalage  >= 80 then '80plus'
						else 'unknown'
						end) as gender_age
		, case 
			when imd04rk >= 1     and imd04rk <= 3248  then 1
			when imd04rk >= 3249  and imd04rk <= 6496  then 2
			when imd04rk >= 6497  and imd04rk <= 9745  then 3
			when imd04rk >= 9746  and imd04rk <= 12993 then 4
			when imd04rk >= 12994 and imd04rk <= 16241 then 5
			when imd04rk >= 16242 and imd04rk <= 19489 then 6
			when imd04rk >= 19490 and imd04rk <= 22737 then 7
			when imd04rk >= 22738 and imd04rk <= 25986 then 8
			when imd04rk >= 25987 and imd04rk <= 29234 then 9
			when imd04rk >= 29235 and imd04rk <= 32482 then 10
			else .
			end as imd_decile
	from ae.ae19m 
;
quit;



proc sql;
	create table eth.totals_check
		(
			dataset char(2),
			fyear num,
			records num,
			people num
		)
;
	insert into eth.totals_check
	select
		'ip' as dataset
		, fyear 
		, count(*) as records
		, count(distinct xhesid) as people
	from eth.vw_ip
	group by fyear
;
	insert into eth.totals_check
	select 'op' as dataset, 201011 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_.op10
;
	insert into eth.totals_check
	select 'op' as dataset, 201112 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op11
;
	insert into eth.totals_check
	select 'op' as dataset, 201213 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op12
;
	insert into eth.totals_check
	select 'op' as dataset, 201314 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op13
;
	insert into eth.totals_check
	select 'op' as dataset, 201415 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op14
;
	insert into eth.totals_check
	select 'op' as dataset, 201516 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op15
;
	insert into eth.totals_check
	select 'op' as dataset, 201617 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op16
;
	insert into eth.totals_check
	select 'op' as dataset, 201718 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op17
;
	insert into eth.totals_check
	select 'op' as dataset, 201819 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op18
;
	insert into eth.totals_check
	select 'op' as dataset, 201920 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op19
;
	insert into eth.totals_check
	select 'op' as dataset, 202021 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_op20m
;
	insert into eth.totals_check
	select 'ae' as dataset, 201011 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae10
;
	insert into eth.totals_check
	select 'ae' as dataset, 201112 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae11
;
	insert into eth.totals_check
	select 'ae' as dataset, 201213 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae12
;
	insert into eth.totals_check
	select 'ae' as dataset, 201314 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae13
;
	insert into eth.totals_check
	select 'ae' as dataset, 201415 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae14
;
	insert into eth.totals_check
	select 'ae' as dataset, 201516 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae15
;
	insert into eth.totals_check
	select 'ae' as dataset, 201617 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae16
;
	insert into eth.totals_check
	select 'ae' as dataset, 201718 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae17
;
	insert into eth.totals_check
	select 'ae' as dataset, 201819 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae18
;
	insert into eth.totals_check
	select 'ae' as dataset, 201920 as fyear, count(*) as records, count(distinct xhesid) as people
	from eth.vw_ae19m
;
	insert into eth.totals_check
	select 'ec' as dataset, 201920 as fyear, count(*) as records, count(distinct TOKEN_PERSON_ID) as people
	from eth.vw_ec19
;
	insert into eth.totals_check
	select 'ec' as dataset, 202021 as fyear, count(*) as records, count(distinct TOKEN_PERSON_ID) as people
	from eth.vw_ec20m
;
	insert into eth.totals_check
	select 'cs' as dataset, 201920 as fyear, count(*) as records, count(distinct UniqueCYPHS_ID_Patient) as people
	from eth.vw_cs19
;
quit;



/* Set up ready for reallocation */

Proc sql;
    create table ethpi.csds_ids_ethnos as
    select uniqueCYPHS_id_patient, month(referraldate) as month, min(referraldate) as referraldate format date9., ethniccat as ethnos, 201718 as fyear
    from CSDS1718.Demographicsandreferral17
    where referraldate ne .
    group by uniqueCYPHS_id_patient, calculated month, ethnos
    union all
    select uniqueCYPHS_id_patient, month(referraldate) as month, min(referraldate) as referraldate format date9., ethniccat as ethnos, 201819 as fyear
    from CSDS1718.Demographicsandreferral18
    where referraldate ne .
    group by uniqueCYPHS_id_patient, calculated month, ethnos
    union all
    select uniqueCYPHS_id_patient, month(referraldate) as month, min(referraldate) as referraldate format date9., ethniccat as ethnos, 201920 as fyear
    from CSDS19.Demographicsandreferral19
    where referraldate ne .
    group by uniqueCYPHS_id_patient, calculated month, ethnos
;
quit;

data bf_dup;
	set HESCS19.HES_CSDS_BF_19_Clean
		HESCS18.HES_CSDS_BF_18_Clean;
run;

Proc sort data = bf_dup nodupkey out = bf;
    by uniqueCYPHS_id_patient;
run;


Proc sql;
    create table ethpi.csds_hes as
	select b.xhesid, a.fyear, a.referraldate as date, a.ethnos, case when b.xhesid is null then a.uniqueCYPHS_id_patient else . end as match_flag
    from ethpi.csds_ids_ethnos as a
    	left join bf as b
    		on a.uniqueCYPHS_id_patient=b.uniqueCYPHS_id_patient
;
quit;


Options compress = yes;
proc sql;
  /* CSDS */
	create table ethpi.patientindex as
	select xhesid, 'cs' as dataset, fyear, date, ethnos   
	from ethpi.csds_hes 
	union all
	
	/* IP */
	select xhesid, 'ip' as dataset, fyear, disdate as date, ethnos
	from eth.ip 
	where fyear >= 201718 and fyear <= 201920 
	union all

  /* AE */
	select xhesid, 'ae' as dataset, 201920 as fyear, arrivaldate as date, ethnos
	from ae.ae19m 
	union all
	select xhesid, 'ae' as dataset, 201819 as fyear, arrivaldate as date, ethnos
	from hes.ae18 
	union all
	select xhesid, 'ae' as dataset, 201718 as fyear, arrivaldate as date, ethnos
	from hes.ae17 
	union all

  /* OP */
	select xhesid, 'op' as dataset, 201920 as fyear, apptdate as date, ethnos
	from hes.op19
	union all
	select xhesid, 'op' as dataset, 201819 as fyear, apptdate as date, ethnos
	from hes.op18
	union all
	select xhesid, 'op' as dataset, 201718 as fyear, apptdate as date, ethnos
	from hes.op17
	
;
quit;
options compress = no;

/*Take a look at the codes that are invalid*/
proc sql;
	create table ethpi.invalid_codes as
	select
		xhesid
		, dataset
		, ethnos 
		, count(*) as count
	from ethpi.patientindex
	where
		ethnos not in ('A', 'B','C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z','X')
	group by
		xhesid
		, dataset
		, ethnos
;
quit;

proc sql;
	create table ethpi.consistency as
	select
		xhesid
		, dataset
		, case 
			when ethnos = '99' then 'X'
			when ethnos = '' then 'U'
			else substring(ethnos from 1 for 1) end as ethnosb
	 , count(*) as count
	from ethpi.patientindex
	group by
		xhesid
		, dataset
		, ethnosb
;
quit;

proc sql;
	update ethpi.consistency
	set ethnosb = 'U' 
	where ethnosb not in ('A', 'B','C','D','E','F','G','H','J','K','L','M','N','P','R','S','Z','X')
;
quit; 

proc sql;
	create table ethpi.consistency2 as
	select xhesid, dataset, ethnosb as ethnos, sum(count) as count
	from ethpi.consistency
	group by xhesid, dataset, ethnos 
;
quit;

/*drop consistency*/
proc delete data=ethpi.consistency;
run; 


/*Quick checks*/
proc sql;
 create table ethpi.ethnos_summary as 
	select 
		dataset
		, ethnos
		, count(distinct xhesid) as people
		, sum(count) as records
	from
		ethpi.consistency2
	group by 
		dataset
		, ethnos
;
quit;

proc sql;
 create table ethpi.ind_people as 
 select 
	dataset,
	count(distinct xhesid) as people

from
		ethpi.consistency2

where
		dataset in ('ip', 'op', 'ae')
group by
		dataset
;
quit;




/*pivot results*/

proc sort data=ethpi.consistency2; 
	by xhesid dataset;
run;

proc transpose data=ethpi.consistency2 out=ethpi.consistency3(drop=_name_);
	by xhesid dataset;
	var count;
	id ethnos;
	idlabel ethnos;
run;

proc stdize data=ethpi.consistency3 reponly missing=0 out=ethpi.consistency4;
run;

proc delete data=ethpi.consistency3;
run; 



