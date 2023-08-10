/*CREATED LIBRARY FOR PROJECT*/;
LIBNAME SAStele 'C:\Users\shail\Desktop\Advance SAS project';

/*IMPORTED THE DATASET USING IMPORT DATA */;

PROC IMPORT OUT= sastele.NEW_WIRELESS_FIXED 
            DATAFILE= "C:\Users\shail\Desktop\Advance SAS project\New_Wireless_Fixed.txt"
            DBMS=TAB 
      REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 GuessingRows=1000;
RUN;
  
DATA sastele.NEW_WIRELESS_FIXED;
 INFILE "C:\Users\shail\Desktop\Advance SAS project\New_Wireless_Fixed.txt"  truncover;
 INPUT @1 Acctno $13. 
       @15 Actdt mmddyy10. 
       @26 Deactdt mmddyy10.
       @41 DeactReason $6.
       @53 GoodCredit $2. 
       @62 RatePlan 2. 
       @65 DealerType $2. 
       @73 Age 3. 
       @79 Province $3. 
       @84 Sales dollar8.2;
format Actdt mmddyy10. Deactdt mmddyy10. Sales dollar8.2;   
RUN;
/*Let's first take a look at the data we have.*/
TITLE "DATASET DETAILS";
proc contents data=sastele.NEW_WIRELESS_FIXED varnum;
run;
TITLE;

/*Acctno: account number.
Actdt: account activation date
Deactdt: account deactivation date
DeactReason: reason for deactivation.
GoodCredit: customer’s credit is good or not.
RatePlan: rate plan for the customer.
DealerType: dealer type.
Age: customer age.
Province: province.
Sales: the amount of sales to a customer.


***************************************************************************************
1.1  Explore and describe the dataset briefly.
Finding missing values
Handling missing values
******************************************************************************************/
* BROWSING THE DESCRIPTION PORTION ;


PROC CONTENTS DATA= sastele.NEW_WIRELESS_FIXED;
RUN;


PROC PRINT DATA=sastele.NEW_WIRELESS_FIXED(obs=10);
	FORMAT Actdt mmddyy10. Deactdt mmddyy10. Sales dollar8.2 ; 
RUN;

PROC MEANS  DATA=sastele.NEW_WIRELESS_FIXED min p1 p5 p95 p90 p99 max std nmiss n mode;
RUN;

/*One way to identify the outliers is to find the 99th percentile of data.*/;
proc means data=sastele.NEW_WIRELESS_FIXED p99;
run;

/*Now,systematically identify the extreme values for all of the numeric 
columns in our IMPORT data set.*/;
proc means data=sastele.NEW_WIRELESS_FIXED min p90 p95 p99 max; 
var _numeric_;
run;
/*Another thing we need to deal with is the missing values.

Let's look at which column has missing values:*/;
proc means data=sastele.NEW_WIRELESS_FIXED nmiss min mean max; 
var _numeric_;
run;
*DROP DUPLICATE OBSERVATION IF EXIST;
PROC SORT DATA=sastele.NEW_WIRELESS_FIXED  NODUPKEY;
 BY Acctno;
RUN;

/* REPLACING MISSING VALUES OF AGE  WITH MEDIAN */
PROC STDIZE DATA=sastele.NEW_WIRELESS_FIXED
	OUT=sastele.NEW_WIRELESS_FIXED 
	reponly method=median;
	VAR AGE ;
RUN;

/* REPLACING MISSING VALUES OF SALES  WITH MEAN */

PROC STDIZE DATA=sastele.NEW_WIRELESS_FIXED
	OUT=sastele.NEW_WIRELESS_FIXED 
	reponly method=median;
	VAR Sales ;
RUN;

/* REPLACING MISSING VALUES OF AGE  WITH MODE */
/*A) FIRST WE FIND THE NUMBER OF OCCURENCE OF PROVINCE */ 
PROC SQL;

CREATE TABLE sastele.temp as
 (select province, count(*) from sastele.new_wireless_fixed
 group by province);
QUIT;
/* B) WE HAVE 'ON' HAS MOST NUMBER OF OCCURENCE SO MISSING VALES WILL GET REPLACE BY 'ON'*/
PROC SQL;
	UPDATE sastele.NEW_WIRELESS_FIXED
	SET Province = 'ON'
	WHERE Province =' ';
QUIT;


/****************************************************************************
The UNIVARIATE Procedure

Fitted Normal Distribution for AGE

 ***************************************************************************/
TITLE "NORMALITY TEST FOR AGE";
 
PROC  UNIVARIATE DATA=sastele.NEW_WIRELESS_FIXED NORMAL PLOT;
    VAR AGE;
 
   /* HISTOGRAM AGE / NORMAL;*/

RUN;
PROC Sgplot DATA=sastele.NEW_WIRELESS_FIXED ;
   HISTOGRAM Age;
  DENSITY AGE;
  DENSITY AGE/type=kernel ;
     
  keylegend / location=inside position=topright;
  run;
/******SINCE P VALE IS GREATER THAN 0.05 SO WE ARE NOT REJECTING NULL HYPOTHESIS HERE
FROM THE HISTOGRAM WE CAN SEE THAT AGE HAS NORMAL DISTRIBUTION*/
/****************************************************************************
The UNIVARIATE Procedure

Fitted Normal Distribution for Sales

 ***************************************************************************/
TITLE "NORMALITY TEST FOR SALES";
PROC  UNIVARIATE DATA=sastele.NEW_WIRELESS_FIXED NORMAL PLOT;
    VAR SALES;
 
    HISTOGRAM SALES / NORMAL;
run;
TITLE;




 /* 0 observations with duplicate key values were deleted thus account number is unique and we have
102,255 total number of customers. But how many of them are active and how many deactive? */





TITLE "Total Number of Unique Accounts";
PROC SQL;
 CREATE TABLE sastele.Total_Accounts AS
 	SELECT COUNT(DISTINCT Acctno) AS UNI_ACC_COUNT format=comma10.
 	FROM sastele.NEW_WIRELESS_FIXED
 ;
 QUIT;
 TITLE;
title "Unique Accounts";
PROC SQL;
	CREATE TABLE sastele.UNIQUE_ACCOUNT AS
		SELECT DISTINCT(Acctno) as Unique_Acctno,Actdt,Deactdt
			FROM sastele.NEW_WIRELESS_FIXED
		ORDER BY Actdt,Deactdt DESC;
QUIT;
TITLE;



/*
Thus, we found total number of accounts, which is 102,255.
Total number of Active Accounts = 82,620
Total number of Inactive Accounts= 19,635
*/



/*Assigning status to Accounts -Activate and Deactivate*/

DATA sastele.Account_Status;
SET sastele.NEW_WIRELESS_FIXED;
	FORMAT Actdt mmddyy10. Deactdt mmddyy10. Status $20.;
	IF Deactdt = '.' THEN Status= 'Active';
	ELSE Status= 'Not_Active';
RUN;

proc print data= sastele.age_tenure_segmentation (obs=10);run;


/*
Analysis requests:
1.1  Explore and describe the dataset briefly. For example, is the acctno unique? What
is the number of accounts activated and deactivated? When is the earliest and
latest activation/deactivation dates available? 
2

/*1.4.3 No of Activated Accounts*/;

DATA sastele.Active sastele.Inactive;
SET sastele.Account_Status;
IF Status= 'Active' THEN OUTPUT sastele.Active;
ELSE OUTPUT sastele.Inactive;
run;



/******DESCRIPTIVE ANALYSIS***************/
*******************************************;

/*No of Activated Accounts with earliest and latest dates*/;
PROC SQL;
	CREATE TABLE sastele.ACTIVATED_ACCOUNTS_Earliest AS
		SELECT  min(Actdt) as Earliest_Act_Date format=mmddyy10.,
             max(Actdt) as Latest_Date format=mmddyy10. from sastele.New_Wireless_Fixed
			WHERE Deactdt is  null;
QUIT;

/*No of DeActivated Accounts with earliest or latest dates*/;
PROC SQL;
	CREATE TABLE sastele.ACTIVATED_ACCOUNTS_LatestDates AS
		SELECT  min(Deactdt) as Earliest_DeAct_Date format=mmddyy10.,
max(Deactdt) as Latest_DeAct_Date format=mmddyy10. 
from sastele.New_Wireless_Fixed
			WHERE Deactdt is  Not null;
QUIT;


/*********************************************************************
1.2  What is the age and province distributions of active and deactivated customers?
**********************************************************************/

ODS GRAPHICS ON / WIDTH =1000 IMAGEMAP=ON;
PROC ANOVA DATA=SASTELE.AGE_TENURE_SEGMENTATION  PLOTS(MAXPOINTS=NONE) ;
CLASS province;
MODEL age=province;
RUN;
ODS GRAPHICS ON / WIDTH =1000 IMAGEMAP=ON;
TITLE "Age and Province distributions of Active Customers";
proc freq DATA=sastele.Active;
table age Province;
run;
TITLE;

TITLE "Age and Province distributions of Deactive Customers";

PROC FREQ data=sastele.Inactive;
table age province;
run;
TITLE;
***************************;
TITLE "Age and Province distributions of Customers";

proc sgpanel data=sastele.new_wireless_fixed;
 panelby Province /
    uniscale=row;
 hline age;
run;
Title;
**************************************************************************
/*Horizontal Box Plot for Age and province Active customers */
*******************************************************************;
proc sgplot data=sastele.Active ;
 title "Age by Province Distribution";
 hbox age / category=province;
run;
title;
******************************************************;
title "Age and Sales of InActive Accounts by Province Distribution";

proc sgplot data=sastele.Inactive ;
 heatmap x=age y=province;
run;
title;

title "Age and Sales of Active Accounts by Province Distribution";

proc sgplot data=sastele.active ;
 heatmap x=age y=province;
run;
title;
PROC SGPANEL DATA=sastele.age_tenure_segmentation;
PANELBY Province;
VBAR AGE_group/RESPONSE=Age GROUPDISPLAY=CLUSTER CLUSTERWIDTH=0.5 stat=freq datalabel;
TITLE"ASSOCIATION BETWEEN Age,Province,AGE ";
RUN;

proc sgplot data=sastele.Inactive ;
title "Age and Sales of InActive Accounts by Province Distribution";
 scatter x=age y=sales
 / group=province;
run;
title;
/*HeatMap*/
proc sgplot data=sastele.Inactive ;
 heatmap x=age y=sales;
run;


proc sgplot data=SASTELE.Inactive;
 title "Distribution by Age and Province";
 hline age / response=province stat=mean markers group=Province;
run;
*********************************************************************;
/*By analysing proc freq for an age category , it is better to group age by 
category to get more useful information about it
so ill do all the segmentation in this step*/





 DATA sastele.Age_Tenure_Segmentation;
set sastele.New_Wireless_Fixed;
 format Sales_range $15.
        Age_group $15.;
 If Sales < 100 then Sales_range= "<100";
 else if 100<= Sales <500 then Sales_range="100-500";
 else if 500<= Sales <=800 then Sales_range="500-800";
 else Sales_range="800 >";


 if Age <20 then Age_group="< 20";
 else if 20<= Age< =40 then Age_group="21-40";
 else if 41<= Age< =60 then Age_group="41-60";
 else if Age >60  then Age_group="60 > ";



/* Tenure=intck('day', Actdt, Deactdt);*/
if deactdt ne '.'  then do ;
tenure =intck('day',Actdt,Deactdt);
end;
else tenure = intck('day',actdt,'31Jan2001'd);


if Tenure < =30 then Tenure_Grouped = "1 month or less";
else if 31<= Tenure <= 90 then Tenure_Grouped = "1-3 months";
else if 91<= Tenure < =180 then Tenure_Grouped = "3-6 months";
else if 181<= Tenure < =270 then Tenure_Grouped = "6-9 months";
else if 271<= Tenure < =365 then Tenure_Grouped = "9-12 months";
else if 366<= Tenure < =545 then Tenure_Grouped = "1-1,5 years";
else if  Tenure => 546 then Tenure_Grouped = " 1,5- 2 years";


format Actdt mmddyy10. Deactdt mmddyy10. Status $20.;
if Deactdt = '.' then Status= 'Active';
else Status= 'Not_Active';

run;

DATA sastele.Active sastele.Inactive;
SET sastele.age_tenure_segmentation;
if Status= 'Active' then output sastele.Active;
else output sastele.Inactive;
Run;

title "Distribution of Age Group Province for Activated Accounts ";
proc freq data=sastele.active;
table age_group province;
run;
Title;

title "Distribution of Age Group Province  for Deactivated Accounts ";
proc freq data=sastele.Inactive;
table age_group province;
run;
Title;

PROC SGPLOT DATA=SASTELE.Inactive;
title "Distribution of Age Group category for Deactivated Accounts ";
VBAR  age_group/stat=percent seglabel;

RUN; 
PROC SGPLOT DATA=SASTELE.active;
title "Distribution of Age Group category for activated Accounts ";
VBAR  age_group/stat=percent seglabel;

RUN; 
/*By looking at this chart we can clearly see that most of the customers who cancelled 
 their contacts were 40-60 years old*/

TITLE "PIE CHART SHOWING INACTIVE CUSTOMER WITH AGE";
 PROC GCHART DATA=sastele.Inactive;
 PIE3D age_group/DISCRETE
 VALUE=INSIDE
 PERCENT=OUTSIDE
 EXPLODE=ALL
 SLICE=OUTSIDE
 RADIUS=20;
 RUN;

/*PIE CHART FOR ACTIVE USERS WITH AGE */
TITLE "PIE CHART SHOWING ACTIVE CUSTOMER WITH AGE";
 PROC GCHART DATA=sastele.Active;
 PIE3D age_group/DISCRETE
 VALUE=INSIDE
 PERCENT=OUTSIDE
 EXPLODE=ALL
 SLICE=OUTSIDE
 RADIUS=20;
 RUN;
TITLE;


/*Comparision of age for active and inactive accounts we can see that the distribution
is almost the same, thus most frequent age category for both active and inactive accounts is 40-60 y.o.

 lets take a look at the province distribution */

title "Province Distribution for Deactivated Accounts ";
PROC SGPLOT DATA=sastele.Inactive;
VBAR  province/stat=percent seglabel;
RUN; 
. TITLE;
/*By looking at this chart we can clearly see that most of the customers who cancelled 
 their contacts were from Ontario*/


 TITLE "PIECHART OF Province for Deactivated Accounts";
 PROC GCHART DATA=sastele.Inactive;
 PIE3D province/DISCRETE
 VALUE=INSIDE
 PERCENT=OUTSIDE
 EXPLODE=ALL
 SLICE=OUTSIDE
 RADIUS=20;
 RUN;
 TITLE;

/*checking the same for active accounts*/

title "Province Distribution for Active Accounts ";
PROC SGPLOT DATA=sastele.active;
VBAR  province/stat=percent seglabel;
RUN; 
 TITLE;


 TITLE "PIECHART Province for Active Accounts ";
 PROC GCHART DATA=sastele.active;
 PIE3D province/DISCRETE
 VALUE=INSIDE
 PERCENT=OUTSIDE
 EXPLODE=ALL
 SLICE=OUTSIDE
 RADIUS=20;
 RUN;
 TITLE;

/*Comparision of provience distribution for active and inactive accounts we can see that the distribution is almost 
 the same,
 thus most of the customers for both active and inactive accounts are from Ontario.;
*/


****************************************************************;
PROC SGPLOT DATA =sastele.Inactive; 
VBAR  DeactReason /stat=percent seglabel;  
yaxis grid display=(nolabel);  xaxis display=(nolabel)  discreteorder=data; 
where status='Not_Active' ;
RUN;
/*I've find out that the main 36.1% reason is "NEED".
next, I want to see from those who "NEED" something that is their age category? */


PROC SGPLOT DATA =sastele.Inactive; 
hBAR  age /stat=percent seglabel;  
yaxis grid display=(nolabel);  xaxis display=(nolabel)  discreteorder=data; 
where DeactReason='NEED' ;

STYLEATTRS     BACKCOLOR=DARKGREY    WALLCOLOR=WHITE; 
RUN;



/*1.3 Segment the customers based on age, province and sales amount:
Sales segment: < $100, $100---500, $500-$800, $800 and above.
Age segments: < 20, 21-40, 41-60, 60 and above.
Create analysis report by using the attached Excel template.*/;


PROC SGPLOT DATA=sastele.AGE_TENURE_SEGMENTATION;
VBAR  Age_group/stat=percent seglabel;
STYLEATTRS
BACKCOLOR=WHITE
WALLCOLOR=WHITE;
RUN; 

/*all the segmentations are done in one step above

so for my analys I want to find out what is the main reason people deactivating their accounts?
 */
PROC SGPLOT DATA =sastele.AGE_TENURE_SEGMENTATION; 
VBAR  DeactReason /stat=percent seglabel;  
yaxis grid display=(nolabel);  xaxis display=(nolabel)  discreteorder=data; 
where status='Not_Active' ;
RUN;
/*Age Segment in Province ON*/
proc SGPLOT data=sastele.Inactive;
VBAR Age_group /stat=percent seglabel;  
yaxis grid display=(nolabel);  xaxis display=(nolabel)  discreteorder=data; 
where province='ON' ;
run;
quit;

proc logistic data=sastele.AGE_TENURE_SEGMENTATION;
class Age_group sales;
model province (event='ON')= Age_group sales/clodds=pl;
/*units province='ON'*/;
run;
quit;
ods graphics off;

proc tabulate data=sastele.AGE_TENURE_SEGMENTATION;
var Status;
class Age_group sales;
table province *( Age_group sales);
run;


/***************************************************************************************************************************************
1.4.Statistical Analysis:
1) Calculate the tenure in days for each account and give its simple statistics.*/;
******************************************************************************************************************************************************************;
TITLE "Tenure by Accounts Status";
PROC sgplot DATA =sastele.Age_Tenure_Segmentation;
 VBAR Tenure_grouped / group=status;
    yaxis grid display=(nolabel);  xaxis display=(nolabel);
     ;
 RUN;
title;
 

%MACRO UNI_ANALYSIS_NUM(DATA,VAR);
 TITLE "THIS IS HISTOGRAM FOR &VAR";
 PROC SGPLOT DATA=&DATA;
  HISTOGRAM &VAR;
  DENSITY &VAR;
  DENSITY &VAR/type=kernel ;
     ;
  keylegend / location=inside position=topright;
 RUN;
 QUIT;
 TITLE "THIS IS HORIZONTAL BOXPLOT FOR &VAR";
 PROC SGPLOT DATA=&DATA;
  HBOX &VAR;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=LIGHTPINK
     ;
 RUN;
TITLE "THIS IS UNIVARIATE ANALYSIS FOR &VAR IN &DATA";
proc means data=&DATA  N NMISS MIN Q1 MEDIAN MEAN Q3 MAX qrange cv clm maxdec=2 ;
var &var;
run;
%MEND;

%UNI_ANALYSIS_NUM(sastele.Age_Tenure_Segmentation,Tenure)
%UNI_ANALYSIS_NUM(sastele.Age_Tenure_Segmentation,Sales)

/***************************************************************
1.4.2) Calculate the number of accounts deactivated for each month.
****************************************************************/;

proc sql;

create table sastele.Month_Count_By_Acc as
select  intnx('month',actdt,0)  as month format=date9.,
        sum(case when status='Not_Active' then 1 else 0 end ) as inactive_accounts,
        sum(case when status='Active' then 1 else 0 end ) as acive_accounts
from sastele.Age_Tenure_Segmentation
group by month ;

quit;

TITLE "Distribution of Inactive Accounts by Month";
PROC SGPLOT DATA =sastele.Month_Count_By_Acc;
 VBAR month / response=inactive_accounts;
    yaxis grid display=(nolabel);  xaxis display=(nolabel);
     ;
 RUN;
title;
/***********************************************************************************
1.4.3) Segment the account, first by account status “Active” and “Deactivated”, then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.
************************************************************************************/
%UNI_ANALYSIS_CAT(sastele.Age_Tenure_Segmentation,Status);
data sastele.Active sastele.Inactive;
set SASTELE.age_tenure_segmentation;
if Status= 'Active' then output SASTELE.Active;
else output SASTELE.Inactive;
run;
PROC SQL;
	CREATE TABLE sastele.TENURE_IN_DAYS AS
	SELECT  Acctno,Actdt,
			CASE 
			WHEN Deactdt is null then intck('day', Actdt,'31Jan2001'd) 
			ELSE intck('day', Actdt , Deactdt) end as Tenure_In_Days
			  	FROM sastele.New_Wireless_Fixed 
			GROUP BY Acctno,Actdt,Deactdt;
QUIT;
  PROC SQL;
  	CREATE TABLE TENURE_SEG AS
	SELECT T.Acctno,CASE
			WHEN Tenure_In_Days < 30 THEN '< 30 Days'
			
			WHEN Tenure_In_Days BETWEEN 30 AND 60 THEN '30-60 Days'
			 
			WHEN Tenure_In_Days BETWEEN 61 AND 365 THEN '61- one year'
			
			WHEN Tenure_In_Days > 365 THEN 'Over 1 year'
			END AS TENURE_SEG
		FROM sastele.TENURE_IN_DAYS T
	

	
		;
	QUIT;
/*Report the
number of accounts of percent of all for each segment.
*/
PROC SQL ;
	CREATE TABLE SASTELE.NO_ACC_TENURE_SEG AS
	SELECT COUNT(ACCTNO)  AS ACCTNO_TENURE_SEG ,TENURE_GROUPED
FROM 
	SASTELE.AGE_TENURE_SEGMENTATION
	GROUP BY TENURE_GROUPED;
	QUIT;
PROC SGPLOT DATA=SASTELE.NO_ACC_TENURE_SEG ;
vbar TENURE_GROUPED / group=ACCTNO_TENURE_SEG nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
RUN;
proc sgplot data=SASTELE.NO_ACC_TENURE_SEG;
 title "Total No of Accounts by Tenure Segmentation";
 hbox ACCTNO_TENURE_SEG / category=TENURE_GROUPED;
run;
title;

*CATEGORICAL VARIABLES : ;
%MACRO UNI_ANALYSIS_CAT(DATA,VAR);
 TITLE "THIS IS FREQUENCY OF &VAR FOR &DATA";
  PROC FREQ DATA=&DATA;
  TABLE &VAR;
 RUN;

TITLE "THIS IS VERTICAL BARCHART OF &VAR FOR &DATA";
PROC SGPLOT DATA = &DATA;
 VBAR &VAR;
  
     ;
 RUN;
TITLE;
TITLE "THIS IS PIECHART OF &VAR FOR &DATA";
PROC GCHART DATA=&DATA;
  PIE3D &VAR/discrete 
             value=inside
             percent=outside
             EXPLODE=ALL
			 SLICE=OUTSIDE
			 RADIUS=20
		
;
TITLE;
RUN;
%MEND;

%UNI_ANALYSIS_CAT(sastele.inactive,Tenure_Grouped)


 /**************************************************************************************
1.4.4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”
***************************************************************************************


 Lets try to find associiation between Tenure segments and Good Credit
 Tenure segments is CATEGORICAL variable and Good Credit is also CATEGORICAL
   */

PROC FREQ DATA=sastele.inactive;
 TABLE  Tenure_Grouped * GoodCredit/chisq norow nocol nopercent;
 
RUN;

PROC FREQ DATA=sastele.age_tenure_segmentation;
 TABLE  Tenure_Grouped  GoodCredit RatePlan DealerType/chisq norow nocol nopercent;
 
RUN;


title 'Distribution of Tenure and Good Credit for Deactivated Accounts';
proc sgplot data=sastele.inactive;
vbar Tenure_Grouped / group=GoodCredit nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
run;
title; 
******************************************************************************************************************************************************;
PROC FREQ DATA=sastele.inactive;
 TABLE  Tenure_Grouped * DealerType/chisq norow nocol nopercent;
 
RUN;
TITLE "TENURE SEGMENTS AND DEALER TYPE ANALYSIS";
  proc sgplot data=sastele.inactive;
vbar Tenure_Grouped / group=DealerType nostatlabel
       groupdisplay=cluster dataskin=gloss;
  yaxis grid display=(nolabel);  xaxis display=(nolabel);
yaxis grid;
run;
TITLE;
TITLE"GOOD CREDIT AND DEALER TYPE ANALYSIS";
proc sgplot data=sastele.age_tenure_segmentation;
vbar GoodCredit / group=DealerType nostatlabel
       groupdisplay=cluster dataskin=gloss;
  yaxis grid display=(nolabel);  xaxis display=(nolabel);
yaxis grid;
run;
TITLE;
*since p-value is less than 5% we reject null hypothese and conclude that
there is statistically assicoation between Tenure and Good Credit  at 5% significant level;


PROC FREQ DATA=sastele.active;
 TABLE  Tenure_Grouped * RatePlan/chisq norow nocol nopercent;
RUN;


PROC FREQ DATA=sastele.inactive;
 TABLE  Tenure_Grouped * RatePlan/chisq norow nocol nopercent;
 
RUN;

TITLE "Distribution of Tenure by Plan  for Activated Accounts";
PROC SGPLOT DATA =sastele.active;
 VBAR Tenure_Grouped / group=RatePlan
 GROUPDISPLAY=CLUSTER;
    yaxis grid display=(nolabel);  xaxis display=(nolabel);
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;
title;


TITLE "Distribution of Tenure by Plan  for Deactivated Accounts";
PROC SGPLOT DATA =sastele.inactive;
 VBAR Tenure_Grouped / group=RatePlan
 GROUPDISPLAY=CLUSTER;
    yaxis grid display=(nolabel);  xaxis display=(nolabel);
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;
title;


*since p-value is less than 5% we reject null hypothese and conclude that
there is statistically assicoation between Tenure and Plan at 5% significant level;

PROC FREQ DATA=sastele.inactive;
 TABLE  Tenure_Grouped * DealerType/chisq norow nocol nopercent;
 
RUN;

title 'Distribution of Tenure and Dealer Type';
proc sgplot data=sastele.inactive;
vbar Tenure_Grouped / group=DealerType nostatlabel
       groupdisplay=cluster dataskin=gloss;
  yaxis grid display=(nolabel);  xaxis display=(nolabel);
yaxis grid;
run;
title; 

*since p-value is less than 5% we reject null hypothese and conclude that
there is statistically assicoation between Tenure and Dealer Type  at 5% significant level;


/*********************************************************************************
1.4.*5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?
**************************************************************************************/
/*

Null hypothese:there is no associtation between the account status and the tenure segments
Alternative hypotheses: there is associtation between the account status and the tenure segments*/

PROC FREQ DATA=sastele.age_tenure_segmentation;
 TABLE  Tenure_Grouped * Status/chisq norow nocol nopercent;

RUN;

title 'Correlation between account status and the tenure segments';
proc sgplot data=sastele.age_tenure_segmentation;
vbar Status / group=Tenure_Grouped  nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
run;
title;

/*since  p-value is less than 5% we reject null hypothese and conclude that
there is statistically assicoation between the account status and the tenure segments */



/****************************************************************************************
1.4.6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?
*******************************************************************************************/

/*is there any assosiation between Status and Sales 
 i wanted to find whether amount of sales could lead to account being deactivated? 
 */
proc means data=sastele.age_tenure_segmentation nmiss mean std stderr cv lclm uclm median min max Q1 Q3 qrange maxdec=2;
var sales;
class status;
run;
*Test for normality;

 *since sales is continuous variable and status (activated/not activated) is categorical varible with only two
levels we
  should run t-test is all assumption are met;
/*
Prior to performing the t-test, it is important to validate our assumptions to ensure that we are performing 
an appropriate and reliable comparison.  Testing normality should be performed using a Shapiro-Wilk normality 
test (or equivalent), and/or a QQ plot for large sample sizes.
Here, we will use PROC UNIVARIATE to produce our Shapiro-Wilk normality test for each status, 
and PROC TTEST will produce our corresponding QQ plots.*/
proc univariate data=sastele.age_tenure_segmentation normal plot;
var sales;
class status;
run;
PROC SGPANEL DATA=sastele.age_tenure_segmentation;
PANELBY STATUS GOODCREDIT;
VBAR AGE_group/RESPONSE=SALES GROUPDISPLAY=CLUSTER CLUSTERWIDTH=0.5 stat=freq datalabel;
TITLE"ASSOCIATION BETWEEN SALES_AMOUNT,GOODCREDIT,AGE AND STATUS";
RUN;
 *The p-value for each test is provided.  A Shapiro-Wilk Test p-value < 0.05 indicate that we should reject the assumption 
of normality. But based on CLT, since sample size is large enough we can assume that the data is normally distributed 

*Test for equality of variances.
Using Levene’s Test for Homogeneity of Variances;

proc glm data=sastele.age_tenure_segmentation;
class status;
model sales = status;*we want to predict status based on sales;
means status / hovtest=levene(type=abs) welch;
run;

/*since p-value of Levene's test is greater than 5% ,accept null hypothese and get conclusion that
thoes two groups have equal variance so use the pooled ttest.

Boxplots to Visually Check for Outliers. in our case, the boxplot seems to indicate outliers, 
not enough evidence to suggest we move to a different analysis method.
So far, we have determined that the data for each status is normally distributed, variances are equal, 
and we do not have major influential outliers. Our next step is to officially perform an independent samples 
t-test to determine whether active and inactive accounts show significant differences between their average
sales expenditure
*/



proc ttest data=sastele.age_tenure_segmentation;
var sales;
class status;
run;


/*in our case the equal variances are assumed, the row representing the Pooled difference is appropriate. */

/*Because p-value greater than 5% we fail to reject null hypotheses and get the coclustion 
that there is NO statisticall association between sales and status of the account  at 5% significant level*/
/**/




TITLE "Distribution of sales and status";
PROC SGPLOT DATA =sastele.age_tenure_segmentation;
 VBAR sales_range / group= status
  groupdisplay=cluster  dataskin=gloss;
    yaxis grid display=(nolabel);  xaxis display=(nolabel);
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;
title;

TITLE "Distribution of sales and credit";
PROC SGPLOT DATA =sastele.age_tenure_segmentation;
 VBAR sales_range / group= GoodCredit
  groupdisplay=cluster  dataskin=gloss;
    yaxis grid display=(nolabel);  xaxis display=(nolabel);
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;
title;

ODS GRAPHICS ON / WIDTH =1000 IMAGEMAP=ON;
TITLE"ASSOCIATION BETWEEN SALES_AMOUNT,AGE";
proc Anova DATA=SASTELE.AGE_TENURE_SEGMENTATION  PLOTS(MAXPOINTS=NONE) ;
	CLASS Sales_range;
	Model Age=Sales_range;
RUN;
title;


***************************************************************************
1.4.4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”
***************************************************************************************


 Lets try to find association between Tenure segments and Good Credit
 Tenure segments is CATEGORICAL variable and Good Credit is also CATEGORICAL
   */
PROC print DATA=sastele.inactive;run;

*since p-value is less than 5% we reject null hypothese and conclude that
there is statistically assicoation between Tenure and Good Credit  at 5% significant level;

PROC FREQ DATA=sastele.age_tenure_segmentation;
 TABLE  Tenure_Grouped * rateplan/chisq norow nocol nopercent;
 
RUN;

PROC FREQ DATA=sastele.age_tenure_segmentation;
 TABLE  DealerType * rateplan/chisq norow nocol nopercent;
 
RUN;
PROC FREQ DATA=sastele.age_tenure_segmentation;
 TABLE  GoodCredit * DealerType/chisq norow nocol nopercent;
 
RUN;
PROC FREQ DATA=sastele.age_tenure_segmentation;
 TABLE  Tenure_Grouped * DealerType/chisq norow nocol nopercent;
 
RUN;

PROC FREQ DATA=sastele.age_tenure_segmentation;
 TABLE  RatePlan * GoodCredit/chisq norow nocol nopercent;
 
RUN;
title 'Correlation between GoodCredit and the tenure segments';
proc sgplot data=SASTELE.age_tenure_segmentation;
vbar goodcredit / group=Tenure_Grouped  nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
run;
title;
title 'Correlation between RatePLan and the tenure segments';	
proc sgplot data=SASTELE.age_tenure_segmentation;
vbar rateplan / group=Tenure_Grouped  nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
run;
title;
title 'Correlation between DealerType and the GoodCredit';
proc sgplot data=SASTELE.age_tenure_segmentation;
vbar dealertype / group=goodcredit  nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
run;
title;
title 'Correlation between RatePlan and the GoodCredit';
proc sgplot data=SASTELE.age_tenure_segmentation;
vbar rateplan / group=goodcredit  nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
run;
title;
/***********************************************************************************
1.4.5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?*/




/*
Null hypothese:there is no associtation between the account status and the tenure segments
Alternative hypotheses: there is associtation between the account status and the tenure segments*/

PROC FREQ DATA=SASTELE.age_tenure_segmentation;
 TABLE  Tenure_Grouped * Status/chisq norow nocol nopercent;

RUN;
PROC FREQ DATA=SASTELE.age_tenure_segmentation;
 TABLE  age_group * province/chisq norow nocol nopercent;

RUN;

title 'Correlation between account status and the tenure segments';
proc sgplot data=SASTELE.age_tenure_segmentation;
vbar Status / group=Tenure_Grouped  nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
run;

title;
proc sgpanel data=sastele.age_tenure_segmentation;
 panelby province /
    uniscale=row;
 histogram age;
 density age;
run;
/*6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?*/
/*in our case the equal variances are assumed, the row representing the Pooled difference is appropriate. */

/*Because p-value greater than 5% we fail to reject null hypotheses and get the coclustion 
that there is NO statisticall association between sales and status of the account  at 5% significant level*/
/**/
TITLE "Distribution of Goodcredit and status";
proc sgplot data=SASTELE.age_tenure_segmentation;
vbar Status / group=GoodCredit  nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
run;
TITLE;


TITLE "Distribution of age group and good credit";
proc sgplot data=SASTELE.age_tenure_segmentation;
vbar Age_group / group=GoodCredit  nostatlabel
       groupdisplay=cluster dataskin=gloss;

yaxis grid;
run;
TITLE;


TITLE "Distribution of sales and status";
PROC SGPLOT DATA =SASTELE.age_tenure_segmentation;
 VBAR sales_range / group= status
  groupdisplay=cluster  dataskin=gloss;
    yaxis grid display=(nolabel);  xaxis display=(nolabel);
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;
TITLE;

TITLE "Distribution of sales and credit";
PROC SGPLOT DATA =SASTELE.age_tenure_segmentation;
 VBAR sales_range / group= GoodCredit
  groupdisplay=cluster  dataskin=gloss;
    yaxis grid display=(nolabel);  xaxis display=(nolabel);
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;
title;
Proc  FREQ DATA=sastele.age_tenure_segmentation;
TABLE Age_group GoodCredit Status/chisq norow nocol nopercent;
RUN;
title;
Proc  FREQ DATA=sastele.age_tenure_segmentation;
TABLE sales GoodCredit /chisq norow nocol nopercent;
RUN;
TITLE "3D CHART TO SHOW AGE GROUP,GOODCREDIT AND STATUS";
goptions colors = ( blueviolet blue aquamarine green);

proc gchart data=SASTELE.age_tenure_segmentation;
  block age_group / group=goodcredit subgroup=status;
run;
quit;
TITLE;

proc gplot data=sastele.age_tenure_segmentation;
 plot age*sales / regeqn;
run; quit;
TITLE1;
TITLE2;
ods graphics on;
TITLE "CORRELATION BETWEEN THE DATA VARIABLES";
proc corr data=SASTELE.age_tenure_segmentation;
run;
TITLE;




proc tabulate data=SASTELE.age_tenure_segmentation;

class Status GoodCredit age_group;

var sales;

table status, sales*(n sum mean stddev skewness);

table goodcredit, sales*(n sum mean stddev skewness);

table age_group, sales*(n sum mean stddev skewness);

run;



/* GoodCredit based ON tTEST*/
TITLE "TTEST OF GOODCREDIT ON SALES";

proc ttest data=SASTELE.NEW_WIRELESS_FIXED alpha=0.05;

var sales;

class GoodCredit ;     

run;
TITLE;
/* Sales and Status based ON tTEST*/
TITLE "TTEST OF Status ON SALES";

proc ttest data=SASTELE.age_tenure_segmentation alpha=0.05;
var sales;
class Status  ;   
run;
TITLE;
**********************************************