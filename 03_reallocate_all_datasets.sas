/* Re-allocate ethnicity using information from across HES datasets */
/* That means we combine information across datasets. */


/* Save results here */
libname ethpi "~\Ethnicity coding\Sensitive\pi";

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
	create table ethpi.realloc_age as 
	select r.*, ip.startage, ip.sex 
	from ethpi.reallocfinal r 
		inner join (
			SELECT xhesid, max(startage) as startage, min(sex) as sex
			FROM eth.vw_ip
			WHERE fyear = 201819
			GROUP BY xhesid
			) ip on r.xhesid = ip.xhesid
	where r.dataset = 'ip'
;
quit;

proc sql;
	create table ethpi.reallocafter_age as
	select
		case 
			when startage < 120 then startage 
			when startage > 7000 then 0
			else .
			end as age_clean
		, sex
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
	from ethpi.realloc_age
	group by
		age_clean
		, sex
;
quit;
