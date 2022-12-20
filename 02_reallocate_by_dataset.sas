/* Re-allocate ethnicity using information from within individual datasets only */
/* That means we are not combining across datasets. */


/* Save results here */
libname ethpi "~\Ethnicity coding\Sensitive\pi";



/*count records by hes id and dataset*/
proc sql;

	create table ethpi.dsint as 
	select
		sum(count) as records
		, xhesid
		, dataset
	from ethpi.consistency2
	group by 
		xhesid
		, dataset

;
quit;

/* TOTALS */
proc sql;
/*	N.B. CS total people is wrong since there are all the people who we haven't linked to HES*/
	create table ethpi.patient_summary as 
	select 
		dataset
		, count(distinct xhesid) as people
		, sum(count) as records
	
/* below won't sum because these count any time this code is reported*/
		, sum(case when ethnos in ('A', 'B','C','D','E','F','G','H','J','K','L','M','N','P','R','S') then 1 else 0 end) as people_valid
		, sum(case when ethnos = 'U' then 1 else 0 end) as people_invalid
		, sum(case when ethnos = 'Z' then 1 else 0 end) as people_notstated
		, sum(case when ethnos = 'X' then 1 else 0 end) as people_unknown

		, sum(case when ethnos in ('A', 'B','C','D','E','F','G','H','J','K','L','M','N','P','R','S') then count else 0 end) as records_valid
		, sum(case when ethnos = 'U' then count else 0 end) as records_invalid
		, sum(case when ethnos = 'Z' then count else 0 end) as records_notstated
		, sum(case when ethnos = 'X' then count else 0 end) as records_unknown

	from ethpi.consistency2
	group by
		dataset
;
quit;


/* SINGLE RECORDS ONLY */
proc sql;
	create table ethpi.singlesids as 
	select xhesid, dataset
	from ethpi.dsint
	where records = 1
;
	create table ethpi.singles as
	select 
		a.xhesid
		, a.dataset
		, a.ethnos
		, a.count
	from
		ethpi.consistency2 a
		inner join ethpi.singlesids b on a.xhesid = b.xhesid and a.dataset = b.dataset
;

	create table ethpi.singlessummary as
	select
		dataset
		, count(*) as records
		, count(distinct xhesid) as people

/*should sum to total since there's only 1*/
		, sum(case when ethnos in ('A', 'B','C','D','E','F','G','H','J','K','L','M','N','P','R','S') then 1 else 0 end) as valid
		, sum(case when ethnos = 'U' then 1 else 0 end) as invalid
		, sum(case when ethnos = 'Z' then 1 else 0 end) as notstated
		, sum(case when ethnos = 'X' then 1 else 0 end) as unknown

	from ethpi.singles
	group by
		dataset
;
quit;

/* TWO PLUS RECORDS - ALWAYS MATCH */

proc sql;
/*	Who has had multiple records, by dataset?*/
	create table ethpi.id_ind_multi as /* individual datasets multiple ids  */
	select xhesid, dataset
	from ethpi.dsint
	where records > 1		
; 
/*	How many ethnicity codes have people had recorded?*/
	create table ethpi.ind_multi_count as
	select 
		a.xhesid
		, a.dataset
		, COUNT(*) as ethnos_count
	from
		ethpi.consistency2 a
		
	group by
		a.xhesid
		, a.dataset
		
;
	create table ethpi.ind_multi_match as
	select
		  a.xhesid
		, a.dataset
		, a.ethnos
		, a.count
	from
		ethpi.consistency2 a
		inner join ethpi.ind_multi_count b on a.xhesid = b.xhesid and a.dataset = b.dataset
	where b.ethnos_count = 1
;
	create table ethpi.ind_multi_match_summary as
	select
		dataset
		, sum(count) as records
		, count(distinct xhesid) as people

		, sum(case when ethnos in ('A', 'B','C','D','E','F','G','H','J','K','L','M','N','P','R','S') then 1 else 0 end) as people_valid
		, sum(case when ethnos = 'U' then 1 else 0 end) as people_invalid
		, sum(case when ethnos = 'Z' then 1 else 0 end) as people_notstated
		, sum(case when ethnos = 'X' then 1 else 0 end) as people_unknown

		, sum(case when ethnos in ('A', 'B','C','D','E','F','G','H','J','K','L','M','N','P','R','S') then count else 0 end) as records_valid
		, sum(case when ethnos = 'U' then count else 0 end) as records_invalid
		, sum(case when ethnos = 'Z' then count else 0 end) as records_notstated
		, sum(case when ethnos = 'X' then count else 0 end) as records_unknown

	from ethpi.ind_multi_match
	group by
		dataset
;
quit;

/* TWO PLUS RECORDS 
	- 0 VALID PLUS UNKNOWN / NOT STATED / INVALID 
	- 1 VALID PLUS UNKNOWN / NOT STATED / INVALID 
	- 2+ VALID PLUS UNKNOWN / NOT STATED / INVALID */

proc sql;
	/* Who has multiple ethnic codes for the same person and dataset? */

	create table ethpi.ind_multi_nomatch as
	select
		  a.xhesid
		, a.dataset
		, a.ethnos
		, a.count
	from
		ethpi.consistency2 a
		inner join ethpi.ind_multi_count b on a.xhesid = b.xhesid and a.dataset = b.dataset
	where b.ethnos_count > 1


/*create table ethpi.ind_multi_nomatch as */
/*	select distinct*/
/*		a.xhesid*/
/*		, a.dataset*/
/*	from ethpi.consistency2 a*/
/*		inner join ethpi.ind_multi_count b on a.xhesid = b.xhesid and a.dataset = b.dataset*/
/*	where b.ethnos_count > 1 /* multiple codes*/

;
	/* How many valid codes do people with multiple ethnic codes have? */
	create table ethpi.ind_multi_nomatch_valid as
	select
		a.xhesid
		, a.dataset
		, sum(case when ethnos in ('A', 'B','C','D','E','F','G','H','J','K','L','M','N','P','R','S') then 1 else 0 end) as ethnos_valid_count
	from ethpi.ind_multi_nomatch a
	group by
		a.xhesid
		, a.dataset
;
	create table ethpi.ind_multi_nomatch_valid2 as
	select
		a.xhesid
		, a.dataset
		, a.ethnos
		, a.count
		, case 
			when b.ethnos_valid_count > 1 then 2
			else b.ethnos_valid_count
			end as ethnos_valid_count_group
		
	from ethpi.ind_multi_nomatch a 
		inner join ethpi.ind_multi_nomatch_valid b 
			on a.xhesid = b.xhesid and a.dataset = b.dataset
;
	create table ethpi.ind_multi_nomatch_summary as
	select
		dataset
		, ethnos_valid_count_group 

		, sum(count) as records
		, count(*) as people_count
		, count(distinct xhesid) as people_distinct

		, sum(case when ethnos in ('A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S') then 1 else 0 end) as people_valid
		, sum(case when ethnos = 'U' then 1 else 0 end) as people_invalid
		, sum(case when ethnos = 'Z' then 1 else 0 end) as people_notstated
		, sum(case when ethnos = 'X' then 1 else 0 end) as people_unknown

		, sum(case when ethnos in ('A', 'B','C','D','E','F','G','H','J','K','L','M','N','P','R','S') then count else 0 end) as records_valid
		, sum(case when ethnos = 'U' then count else 0 end) as records_invalid
		, sum(case when ethnos = 'Z' then count else 0 end) as records_notstated
		, sum(case when ethnos = 'X' then count else 0 end) as records_unknown

	from ethpi.ind_multi_nomatch_valid2
	group by
		dataset
		, ethnos_valid_count_group

;
	create table ethpi.ind_multi_valid_combi as 
	select
		  a.xhesid
		, a.dataset
        , case when a.A > 0 then 1 else 0 end as A
        , case when a.B > 0 then 1 else 0 end as B
        , case when a.C > 0 then 1 else 0 end as C
        , case when a.D > 0 then 1 else 0 end as D
        , case when a.E > 0 then 1 else 0 end as E
        , case when a.F > 0 then 1 else 0 end as F
        , case when a.G > 0 then 1 else 0 end as G
        , case when a.H > 0 then 1 else 0 end as H
        , case when a.J > 0 then 1 else 0 end as J
        , case when a.K > 0 then 1 else 0 end as K
        , case when a.L > 0 then 1 else 0 end as L
        , case when a.M > 0 then 1 else 0 end as M
        , case when a.N > 0 then 1 else 0 end as N
        , case when a.P > 0 then 1 else 0 end as P
        , case when a.R > 0 then 1 else 0 end as R
        , case when a.S > 0 then 1 else 0 end as S
        , case when a.U > 0 then 1 else 0 end as U
        , case when a.X > 0 then 1 else 0 end as X
        , case when a.Z > 0 then 1 else 0 end as Z
	from ethpi.consistency4 a
		inner join ethpi.ind_multi_nomatch_valid b
			on a.xhesid = b.xhesid and a.dataset = b.dataset
	where b.ethnos_valid_count > 1

;
	create table ethpi.ind_multi_valid_combi_summary as 
	select
		  a.dataset
		, a.A
		, a.B
        , a.C
        , a.D
        , a.E
        , a.F
        , a.G
        , a.H
        , a.J
        , a.K
        , a.L
        , a.M
        , a.N
        , a.P
        , a.R
        , a.S
		, a.U
		, a.X
		, a.Z
		, count(*) as people_count
		, count(distinct a.xhesid) as people_distinct

	from ethpi.ind_multi_valid_combi a
		
	group by
		  a.dataset
		, a.A
		, a.B
        , a.C
        , a.D
        , a.E
        , a.F
        , a.G
        , a.H
        , a.J
        , a.K
        , a.L
        , a.M
        , a.N
        , a.P
        , a.R
        , a.S
		, a.U
		, a.X
		, a.Z
;
quit;


/* Check how often people with multiple ethnicities*/

proc sql;
	create table ethpi.checkmultiple1 as
	select 
		dataset
		, ethnos
		, count(distinct xhesid) as people
	 	, sum(count) as records
	from ethpi.ind_multi_nomatch_valid2
	where ethnos_valid_count_group = 2
	group by
		dataset
		, ethnos
;
	create table ethpi.checkmultiple2 as 
	select
		dataset
		, ethnos
		, count(distinct xhesid) as total_people
	 	, sum(count) as total_records

	from ethpi.consistency2
	
	group by
		dataset
		, ethnos
;
	create table ethpi.checkmultiple3 as
	select
		a.dataset
		, a.ethnos
		, a.people
		, b.total_people
		, a.people / b.total_people as people_pcent
		, a.records
		, b.total_records
		, a.records / b.total_records as records_pcent
	from 
		ethpi.checkmultiple1 a 
			left join ethpi.checkmultiple2 b on a.dataset = b.dataset and a.ethnos = b.ethnos
;

quit;




/*Do the same for the three datasets together*/
/*In combined_analysis.sas*/




























/* Check multiples */
















proc sql;
	create table ethpi.realloc1 as 
	select 
		 a.xhesid
		, a.dataset
		, a.A
		, a.B
        , a.C
        , a.D
        , a.E
        , a.F
        , a.G
        , a.H
        , a.J
        , a.K
        , a.L
        , a.M
        , a.N
        , a.P
        , a.R
        , a.S
		, a.U
		, a.X
		, a.Z
		, case when a.A > 0 then 1 else 0 end +
        	case when a.B > 0 then 1 else 0 end +
        	case when a.C > 0 then 1 else 0 end +
        	case when a.D > 0 then 1 else 0 end +
        	case when a.E > 0 then 1 else 0 end +
        	case when a.F > 0 then 1 else 0 end +
        	case when a.G > 0 then 1 else 0 end +
        	case when a.H > 0 then 1 else 0 end +
        	case when a.J > 0 then 1 else 0 end +
        	case when a.K > 0 then 1 else 0 end +
        	case when a.L > 0 then 1 else 0 end +
        	case when a.M > 0 then 1 else 0 end +
        	case when a.N > 0 then 1 else 0 end +
        	case when a.P > 0 then 1 else 0 end +
        	case when a.R > 0 then 1 else 0 end +
        	case when a.S > 0 then 1 else 0 end as groups_notUXZ
        , case when a.A > 0 then 1 else 0 end as Abool
        , case when a.B > 0 then 1 else 0 end as Bbool
        , case when a.C > 0 then 1 else 0 end as Cbool
        , case when a.D > 0 then 1 else 0 end as Dbool
        , case when a.E > 0 then 1 else 0 end as Ebool
        , case when a.F > 0 then 1 else 0 end as Fbool
        , case when a.G > 0 then 1 else 0 end as Gbool
        , case when a.H > 0 then 1 else 0 end as Hbool
        , case when a.J > 0 then 1 else 0 end as Jbool
        , case when a.K > 0 then 1 else 0 end as Kbool
        , case when a.L > 0 then 1 else 0 end as Lbool
        , case when a.M > 0 then 1 else 0 end as Mbool
        , case when a.N > 0 then 1 else 0 end as Nbool
        , case when a.P > 0 then 1 else 0 end as Pbool
        , case when a.R > 0 then 1 else 0 end as Rbool
        , case when a.S > 0 then 1 else 0 end as Sbool
        , case when a.U > 0 then 1 else 0 end as Ubool
        , case when a.X > 0 then 1 else 0 end as Xbool
        , case when a.Z > 0 then 1 else 0 end as Zbool


	from ethpi.consistency4 a
;
	create table ethpi.realloc2 as
	select *
	from ethpi.realloc1
	where groups_notUXZ = 0
;
	create table ethpi.realloc3 as
	select
		xhesid
		, dataset
		, case when A > 0 then A + U + X + Z else A end as A
		, case when B > 0 then B + U + X + Z else B end as B
		, case when C > 0 then C + U + X + Z else C end as C
		, case when D > 0 then D + U + X + Z else D end as D
		, case when E > 0 then E + U + X + Z else E end as E
		, case when F > 0 then F + U + X + Z else F end as F
		, case when G > 0 then G + U + X + Z else G end as G
		, case when H > 0 then H + U + X + Z else H end as H
		, case when J > 0 then J + U + X + Z else J end as J
		, case when K > 0 then K + U + X + Z else K end as K
		, case when L > 0 then L + U + X + Z else L end as L
		, case when M > 0 then M + U + X + Z else M end as M
		, case when N > 0 then N + U + X + Z else N end as N
		, case when P > 0 then P + U + X + Z else P end as P
		, case when R > 0 then R + U + X + Z else R end as R
		, case when S > 0 then S + U + X + Z else S end as S
		, 0 as U
		, 0 as X
		, 0 as Z
		, groups_notUXZ
		, Abool
		, Bbool
		, Cbool
		, Dbool
		, Ebool
		, Fbool
		, Gbool
		, Hbool
		, Jbool
		, Kbool
		, Lbool
		, Mbool
		, Nbool
		, Pbool
		, Rbool
		, Sbool
		, 0 as Ubool
		, 0 as Xbool
		, 0 as Zbool
	from ethpi.realloc1
	where 
		groups_notUXZ = 1
;
	create table ethpi.realloc4 as
	select
		xhesid
		, dataset
		, case when A > 0 then A + S else A end as A
		, case when B > 0 then B + S else B end as B
		, case when C > 0 then C + S else C end as C
		, case when D > 0 then D + S else D end as D
		, case when E > 0 then E + S else E end as E
		, case when F > 0 then F + S else F end as F
		, case when G > 0 then G + S else G end as G
		, case when H > 0 then H + S else H end as H
		, case when J > 0 then J + S else J end as J
		, case when K > 0 then K + S else K end as K
		, case when L > 0 then L + S else L end as L
		, case when M > 0 then M + S else M end as M
		, case when N > 0 then N + S else N end as N
		, case when P > 0 then P + S else P end as P
		, case when R > 0 then R + S else R end as R
        , 0 as S
        , U
        , X
        , Z
        , groups_notUXZ - 1 as groups_notUXZ
        , Abool
        , Bbool
        , Cbool
        , Dbool
        , Ebool
        , Fbool
        , Gbool
        , Hbool
        , Jbool
        , Kbool
        , Lbool
        , Mbool
        , Nbool
        , Pbool
        , Rbool
        , 0 as Sbool
        , Ubool
        , Xbool
        , Zbool

	from ethpi.realloc1
	where groups_notUXZ = 2 and Sbool = 1
;
	create table ethpi.realloc5 as
	select
		xhesid
		, dataset
		, case when A > 0 then A + C else A end as A
		, case when B > 0 then B + C else B end as B
		, 0 as C
        , D
        , E
        , F
        , G
        , H
        , J
        , K
        , L
        , M
        , N
        , P
        , R
        , S
        , U
        , X
        , Z
		, groups_notUXZ - 1 as groups_notUXZ
        , Abool
        , Bbool
        , 0 as Cbool
        , Dbool
        , Ebool
        , Fbool
        , Gbool
        , Hbool
        , Jbool
        , Kbool
        , Lbool
        , Mbool
        , Nbool
        , Pbool
        , Rbool
        , Sbool
        , Ubool
        , Xbool
        , Zbool
	from ethpi.realloc1
	where groups_notUXZ = 2 and Cbool = 1 and (Abool = 1 or Bbool = 1)
;
	create table ethpi.realloc6 as
	select
		xhesid
		, dataset
		, A
		, B
		, C
		, case when D > 0 then D + G else D end as D
		, case when E > 0 then E + G else E end as E
		, case when F > 0 then F + G else F end as F
        , 0 as G
        , H
        , J
        , K
        , L
        , M
        , N
        , P
        , R
        , S
        , U
        , X
        , Z
		, groups_notUXZ - 1 as groups_notUXZ
        , Abool
        , Bbool
        , Cbool
        , Dbool
        , Ebool
        , Fbool
        , 0 as Gbool
        , Hbool
        , Jbool
        , Kbool
        , Lbool
        , Mbool
        , Nbool
        , Pbool
        , Rbool
        , Sbool
        , Ubool
        , Xbool
        , Zbool
	from ethpi.realloc1
	where groups_notUXZ = 2 and Gbool = 1 and (Dbool = 1 or Ebool = 1 or Fbool = 1)
;
	create table ethpi.realloc7 as
	select
		xhesid
		, dataset
		, A
		, B
		, C
        , D
        , E
        , F
		, G
		, case when H > 0 then H + L else H end as H
		, case when J > 0 then J + L else J end as J
		, case when K > 0 then K + L else K end as K
        , 0 as L
        , M
        , N
        , P
        , R
        , S
        , U
        , X
        , Z
		, groups_notUXZ - 1 as groups_notUXZ
        , Abool
        , Bbool
        , Cbool
        , Dbool
        , Ebool
        , Fbool
        , Gbool
        , Hbool
        , Jbool
        , Kbool
        , 0 as Lbool
        , Mbool
        , Nbool
        , Pbool
        , Rbool
        , Sbool
        , Ubool
        , Xbool
        , Zbool
	from ethpi.realloc1
	where groups_notUXZ = 2 and Lbool = 1 and (Hbool = 1 or Jbool = 1 or Kbool = 1)
;	
	create table ethpi.realloc8 as
	select
		xhesid
		, dataset
		, A
		, B
		, C
        , D
        , E
        , F
        , G
        , H
        , J
        , K
        , L
		, case when M > 0 then M + P else M end as M
		, case when N > 0 then N + P else N end as N
        , 0 as P
        , R
        , S
        , U
        , X
        , Z
		, groups_notUXZ - 1 as groups_notUXZ
        , Abool
        , Bbool
        , Cbool
        , Dbool
        , Ebool
        , Fbool
        , Gbool
        , Hbool
        , Jbool
        , Kbool
        , Lbool
        , Mbool
        , Nbool
        , 0 as Pbool
        , Rbool
        , Sbool
        , Ubool
        , Xbool
        , Zbool
	from ethpi.realloc1
	where groups_notUXZ = 2 and Pbool = 1 and (Mbool = 1 or Nbool = 1)
;
	create table ethpi.realloctmp as
	select *
	from ethpi.realloc1
;
	delete from ethpi.realloctmp
	where groups_notUXZ = 0
;
	delete from ethpi.realloctmp
	where groups_notUXZ = 1
;
	delete from ethpi.realloctmp
	where groups_notUXZ = 2 and Sbool = 1
;
	delete from ethpi.realloctmp
	where groups_notUXZ = 2 and Cbool = 1 and (Abool = 1 or Bbool = 1)
;
	delete from ethpi.realloctmp
	where groups_notUXZ = 2 and Gbool = 1 and (Dbool = 1 or Ebool = 1 or Fbool = 1)
;
	delete from ethpi.realloctmp
	where groups_notUXZ = 2 and Lbool = 1 and (Hbool = 1 or Jbool = 1 or Kbool = 1)
;
	delete from ethpi.realloctmp
	where groups_notUXZ = 2 and Pbool = 1 and (Mbool = 1 or Nbool = 1)
;
	create table ethpi.reallocfinal as
	select * from ethpi.realloctmp union all
	select * from ethpi.realloc2 union all
	select * from ethpi.realloc3 union all
	select * from ethpi.realloc4 union all
	select * from ethpi.realloc5 union all
	select * from ethpi.realloc6 union all
	select * from ethpi.realloc7 union all
	select * from ethpi.realloc8
;
quit;



/*Check*/
proc sql;
	create table ethpi.realloc2_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from
		ethpi.realloc2
	group by 
		dataset	
;
	create table ethpi.alloc2_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from ethpi.realloc1
	where groups_notUXZ = 0
	group by 
		dataset	
;
	create table ethpi.realloc3_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from
		ethpi.realloc3
	group by 
		dataset	
;
	create table ethpi.alloc3_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from ethpi.realloc1
	where groups_notUXZ = 1
	group by 
		dataset	
;
	create table ethpi.realloc4_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from
		ethpi.realloc4
	group by 
		dataset	
;
	create table ethpi.alloc4_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from ethpi.realloc1
	where groups_notUXZ = 2 and Sbool = 1
	group by 
		dataset	
;
	create table ethpi.realloc5_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from
		ethpi.realloc5
	group by 
		dataset	
;
	create table ethpi.alloc5_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from ethpi.realloc1
	where groups_notUXZ = 2 and Cbool = 1 and (Abool = 1 or Bbool = 1)
	group by 
		dataset	
;
	create table ethpi.realloc6_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from
		ethpi.realloc6
	group by 
		dataset	
;
	create table ethpi.alloc6_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from ethpi.realloc1
	where groups_notUXZ = 2 and Gbool = 1 and (Dbool = 1 or Ebool = 1 or Fbool = 1)
	group by 
		dataset	
;
	create table ethpi.realloc7_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from
		ethpi.realloc7
	group by 
		dataset	
;
	create table ethpi.alloc7_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from ethpi.realloc1
	where groups_notUXZ = 2 and Lbool = 1 and (Hbool = 1 or Jbool = 1 or Kbool = 1)
	group by 
		dataset	
;
	create table ethpi.realloc8_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from
		ethpi.realloc8
	group by 
		dataset	
;
	create table ethpi.alloc8_chk as
	select dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from ethpi.realloc1
	where groups_notUXZ = 2 and Pbool = 1 and (Mbool = 1 or Nbool = 1)
	group by 
		dataset	
;
quit;



proc sql;
	create table ethpi.reallocafter as
	select
		dataset
		, SUM(A) AS A
		, SUM(B) AS B
		, SUM(C) AS C
		, SUM(D) AS D
		, SUM(E) AS E
		, SUM(F) AS F
		, SUM(G) AS G
		, SUM(H) AS H
		, SUM(J) AS J
		, SUM(K) AS K
		, SUM(L) AS L
		, SUM(M) AS M
		, SUM(N) AS N
		, SUM(P) AS P
		, SUM(R) AS R
		, SUM(S) AS S
		, SUM(U) AS U
		, SUM(X) AS X
		, SUM(Z) AS Z
	from ethpi.reallocfinal
	group by
		dataset
;
quit;


proc freq data = ethpi.realloc1;
	tables groups_notUXZ;
run;

proc freq data = ethpi.realloc1;
	tables dataset * groups_notUXZ;
run;







proc sql;
 select count(*) as records, count(distinct xhesid) as people
from ethpi.ind_multi_nomatch 
where dataset ='ip'
;
quit;


proc sql;
/*	Number of people*/
	create table ethpi.ptnums as
	select 
		count(*) as people
		, dataset
	from ethpi.consistency4
	group by dataset
;

/* # with 1 record in dataset*/

	create table ethpi.dsint2 as
	select
		count(*) as people
		, dataset
	from ethpi.dsint
	where records = 1
	group by 
		dataset
;
/* # with 1 dataset*/
	create table ethpi.ptoneds_tmp as
	select 
		count(*) as datasets
		, xhesid
	from ethpi.dsint
	group by xhesid
;
	create table ethpi.ptoneds_tmp2 as
	select 
		datasets
		, records
		, a.xhesid
		, b.dataset
	from ethpi.ptoneds_tmp a
		left join ethpi.dsint b on a.xhesid = b.xhesid
;

quit;

proc sort data=ethpi.dsint; 
	by xhesid;
run;

proc transpose data=ethpi.dsint out=ethpi.dsintwidetmp(drop=_name_);
	by xhesid;
	var records;
	id dataset;
	idlabel dataset;
run;

proc stdize data=ethpi.dsintwidetmp reponly missing=0 out=ethpi.dsintwide;
run;

proc sql;
	create table ethpi.dsgroups as
	select
		count(*) as people
		, case when cs = 0 then 0 when cs = 1 then 1 when cs > 1 then 2 end as cs_grp
		, case when ip = 0 then 0 when ip = 1 then 1 when ip > 1 then 2 end as ip_grp
		, case when op = 0 then 0 when op = 1 then 1 when op > 1 then 2 end as op_grp
		, case when ae = 0 then 0 when ae = 1 then 1 when ae > 1 then 2 end as ae_grp
	from
		ethpi.dsintwide
	group by
		cs_grp
		, ip_grp
		, op_grp
		, ae_grp
;
quit;


proc freq data = ethpi.consistency;
	tables ethnos;
run;


proc contents data = ethpi.patientindex;
run;