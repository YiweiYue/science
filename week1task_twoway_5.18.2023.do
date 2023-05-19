clear 
cd "C:\Users\Lele\Desktop\stata700"
quietly {
				if c(N) { //background 
					1. adapted from chapter:twoway
					2. jhustata.github.io/book/jjj.html
					3. downloaded 59 files from...
					4. data.nber.org/mortality/
					5. ultimately use urls
				}
				if c(N)<1 { //methods
					timer on 1
				    capture log close
					log using nberv050223.log, replace 
					timer off 1
				}
				if c(N)<2 { //results
					timer on 2
					forvalues i=1988/2018  {
						timer on 21
						noi di "loading ...mort`i'.csv"
						import delimited mort`i'.csv, /*
						    */encoding(UTF-8) clear 
						timer off 21
						timer on 22
						noi di "saving ...mort`i'.dta"
						save mort`i'.dta,replace 
						timer off 22
					}
					timer off 2
				}
				if c(N)>3 { //conclusions
					timer on 3
					clear 
					//do nberappend.do
					lab data "mortality in the united states, 1988-2018"
					save mort1988_2018.dta,replace 
					timer off 3
				}
			  timer list 
			  log close 
			}

	
	
			
			qui {
	qui {
		//if c(N) {
			//1.appended 1988_2018
			//2.create one large file
			//3.save that analytic file
		//}
		if c(N)<1{
			que mem
			capture log close
			log using nberappend.log,replace 
		}
		if c(N)<2{
			timer on 2
			forval i=1988/2018 {
				noi di "appending... mort`i'.dta"
				append using mort`i'.dta,force
				timer off 2
			}
		}
		if c(N)>3{
			noi di "obs:`c(N)', vars:`c(k)'"
			lab data "mortality in the united states, 1988-2018"
			save mort1988_2018.dta,replace 
		}
	  timer list 
	  log close 
	}
}
//obs:4325055, vars:207


qui {
	//qui {
		//if c(N) { //background
			//1.produce twoway plot 
			//2.us mortality: 1988-2018
			//3.jhustata.github.io/book/jjj.html}
		if c(N)<1 { //methods
			capture log close 
			log using nber.twoway.log,replace 
			set max_memory .
		}
		if c(N)<2 { //results
		    timer on 2
			use year datayear using mort1988_2018.dta 
			noi di "obs:`c(N)', vars:`c(k)'"
			timer off 2
		}
		if c(N)>3 {
			timer on 3
			g deaths=1
			replace year=datayear if missing(year)
			replace year=year+1900 if inrange(year,79,95)
			replace year=year+1900+60 if year==9
			replace year=year+1900+60 if year==8 in 1/20295198
			replace year=year+1900+70 if inrange(year,0,7)
			replace year=year+1900+70 if year==8 in 33014266/43014266
			collapse (sum) deaths,by(year)
			lab data "Collapsed:deaths/year"
			save nbertwoway.dta,replace
			timer off 3
		}
		if c(N)==59 {
			twoway scatter deaths year, /*
			    */ti("Mortality in the United States, 1988-2018",pos(11)) /*
				*/yti("N",orientation(horizontal)) /*
				*/xti("Year") /*
				*/note("Source: https://data.nber.org/mortality/")
			graph export mortality.png, replace 
		}
		else {
			noi di "obs:`c(N)'<59"
		}
	  timer list 
      log close
	}
}


***nbermort Stata Program Code
***adapted from Pat's codes:https://pdona17.github.io/class700/chapter3.html
clear 
cd "C:\Users\Lele\Documents\open"

qui{
	
	//capture program drop nbermort
	//program define nbersmort
	
	syntax , [yearstart (int 4)] [yearend (int 4)]
	
	global url https://data.nber.org/mortality/
	clear
	gen deaths = .
	gen year = .
	save mortdata, replace
	
	forvalues i = `yearstart' / `yearend'{
		assert inrange(`yearstart', 1988, 2018)
		assert inrange(`yearend', 1988, 2018)
		use "${url}`i'/mort`i'", clear
		g deaths=1
		collapse (count) deaths
		gen year = `i'
	    save yr`i', replace
		use mortdata, clear
		append using yr`i'
		save mortdata, replace
		
	}
	
	use mortdata, clear
	
	gen deaths1k = deaths / 1000
	
	#delimit ;
	line deaths1k year,
	xtit("Year")
	ytit("Deaths in thousands")
	;
	#delimit cr
//end
//nbermort, yearstart(1988) yearend(2018)	
}





***twoway codes
clear all
cd "C:\Users\Lele\Desktop\stata700"
use transplants, clear
gen int yr = year(transplant_date) 
gen byte n=1
rename gender female
rename don_ecd ecd
collapse (sum) n ecd female, by(yr) 
gen int scd = n-ecd
gen int male=n-female
save tx_yr, replace
graph twoway line n yr
graph twoway connected n yr
graph twoway area n yr
graph twoway bar n yr
graph twoway scatter ecd scd
graph twoway function y=x^2+2
twoway function y=x^2+2, range(1 10)
twoway function y=x^2+2, range(yr)
graph twoway line ecd scd yr
graph twoway line n ecd scd yr
graph twoway area ecd scd yr
graph twoway area ecd scd yr //where is the ecd area?
graph twoway area scd ecd yr //order matters!
graph twoway bar scd ecd yr
graph twoway bar scd ecd yr
twoway line n yr || connected male female yr
twoway line n yr ///
    || connected male female yr
regress n yr
twoway line n yr ///
    || function y=_b[_cons]+_b[yr]*x, range(yr)
twoway line female yr /// 
    || line male yr ///
    || line scd yr ///
    || line ecd yr ///
    || line n yr
twoway line n yr, yscale(range(0))
tw li n yr, yscale(range(0 700))
tw li n yr, xscale(range(2050))
tw li female yr, yscale(log)
tw li female yr, xscale(reverse) //rarely a good idea
tw li ecd yr, xscale(off) yscale(off)
tw li ecd yr, xscale(off) yscale(off)
tw li ecd yr, xscale(off) ///
    yscale(log range(1) reverse)
tw li n yr, yscale(range(0)) ylabel(#4)
tw li n yr, ///
    yscale(range(0)) ylabel(minmax)
tw li n yr, ylabel(0(100)600) ///
    xlabel(2005 2007 "policy change" 2010(5)2020)
tw li n yr, xtick(2005(1)2020) ///
    yscale(range(0)) ylabel(0(100)600)
tw li n yr, xtitle("Calendar year") ///
    ytitle("DDKT") ylabel(0(100)600)
tw li n yr, ///
    yscale(range(0)) ylabel(0(100)600)
tw li n yr, ///
    title("Transplants per year") ///
    subtitle("2006-2018")
twoway line n yr, xline(2007) ///
    text(450 2007 "Policy change")
twoway line n yr, yline(350)
twoway line n yr, ylabel(0(100)600) ///
    text(600 2017 "Local peak in 2017")
graph twoway scatter peak_pra age
tw sc peak_pra age, jitter(2)
tw sc bmi age if gend==0, mcolor(orange) /// 
    || sc bmi age if gend==1, mcolor(black) //orioles colors
tw sc bmi age if gender==0, msymbol(D) ///
    || sc bmi age if gender==1, msymbol(+)
tw sc bmi age if gender==0, msize(small) ///
    || sc bmi age if gender==1, msize(large)
	
	
clear all
qui {
 if c(N) { //clear data before running script
        1. adopted from wk1 of this class
  1. https://jhustata.github.io/book/bbb.html
  2. import demographics data from nhanes
 }
 if c(N)<1 { //settings,logfile,macros
  capture log close 
  log using session0.log, replace 
  global url https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/
  global datafile DEMO.XPT 
 }
 if c(N)<2 { //import datafile
  import sasxport5 "${url}${datafile}", clear
  replace ridageyr=.
  noi di "N=`c(N)'"
 }
 if c(N)>3 {
     g number=1
  preserve 
      sum ridageyr
   assert c(type) == "float"
      collapse (sum) number,by(ridageyr)
 }
 local N=c(N)-1
 if `N' { //no ouput if c(N)=0
  noi di "N=`c(N)'"
  local ages=c(N)
  line number ridageyr, connect(stairstep) /*
      */text(500 40 "Vars: `c(k)', Obs: `c(N)'") /*
   */yti("") /*
   */xti("")
  graph save agedist1.gph,replace 
  twoway area number ridageyr, connect(none) /*
      */text(500 40 "Vars: `c(k)', Obs: `c(N)'") /*
   */yti("") /*
   */xti("")
  graph save agedist2.gph,replace 
  restore 
 }
 if `N' {
  noi di "N=`c(N)'"
  hist ridageyr, freq bins(`ages') /*
      */text(500 40 "Vars: `c(k)', Obs: `c(N)'") /*
   */yti("") /*
   */xti("")
  graph save agedist3.gph,replace 
  graph combine agedist1.gph /*
              */agedist2.gph /*
     */agedist3.gph /*
         */, row(1) /*
      */  l1ti("N",orientation(horizontal)) /*
      */  b1ti("Age, y")
  graph export agedist.png,replace 
  noi di c(scheme)
  noi di c(version)
 }
 else {
  noi di "N=`N' (i.e., code-block is not expressed)"
 }
}



***lab6 (including solutions)
clear all
cd "C:\Users\Lele\Desktop"
use transplants.dta, clear

count
set seed 2021
gen rdm=runiform()
sort rdm
keep if _n<=_N/10
drop rdm
count

//alternative
use transplants.dta, clear
count
sample 10
count

use transplants.dta, clear

sum age
gen fake_age=rnormal(r(mean), r(sd))
sum age fake_age
compare age fake_age
kdensity age, addplot(kdensity fake_age)
list fake_id age fake_age in 1/10
graph export kdensity.png, replace 

   use transplants.dta, clear 
   graph twoway scatter peak_pra age    //full syntax
   tw sc peak_pra age                 //abbreviated syntax
   
//explore other twoway options!!  
#delimit ;
forval f=0/1 { ;
	sum peak_pra if gender==`f', d ;
	local m_iqr_`f': di 
       "Median" %2.0f r(p50)
       " (IQR," %2.0f r(p25)
            "-" %2.0f r(p75)
            ")"
			;
} ;
tw (sc peak_pra age if gender==0)
   (sc peak_pra age if gender==1,
       legend(
           on
           ring(0)
           pos(11)
           lab(1 "Male")
           lab(2 "Female")
       )
       ti("Most Recent Serum PRA",pos(11))
       yti("%", orientation(horizontal))
   text(50 10 "`m_iqr_0'",col(midblue))
   text(45 10 "`m_iqr_1'",col(cranberry))
   )
   ;
   #delimit cr
   graph export lab6q5.png, replace 
   
        use transplants, clear
     collapse (mean) don_ecd, by(age)
     graph twoway line don_ecd age, text(.5 40 "obs: `c(N)', vars: `c(k)'")
     graph export collpasebyage.png,replace
     count 
     
//alternative, without messing up the data
if c(N) == r(N) | c(N) == 6000 {
	
use transplants, clear
egen m_don_ecd=mean(don_ecd), by(age)
egen agetag=tag(age)
#delimit ;
line m_don_ecd age if agetag, 
    text(
    .5 40 
    "obs: `c(N)', vars: `c(k)'"
    ) 
    sort ;
#delimi cr
count
graph export lab6q6.png,replace 

}

     use transplants, clear
     gen age10 = round(age, 10)
     //one way to restore data after messing it up
     preserve 
         collapse (mean) don_ecd, by(age10)
         graph twoway line don_ecd age10
         graph export collpasebyage10.png,replace
     restore 
     count 
 
 
 //you're welcome to flout
//   these guidelines after May 19
//but please don't flaunt your disregard 
//   for the didactic value before then

//collapse [-] at qui
qui {

//collapse [-] at if X {
qui {
	if 0 { //lab6 dofile
	if 1 { //transplants.dta
	if 2 { //runiform(),two methods
	if 3 { //transplants reload
	if 4 { //r(normal),kdensity
	if 5 { //embed macro in text then graph
	if 6 { //collpase & egen equivalence!!!!!!
	if 7 { //aesthetical .do file structure :)
       timer list  
       log close 
}

//alternative
//`if c(N) xxx {` merely placebolder
//but may become functional condition as 
//do file grows in complexity
//and accommodates more general stance
//e.g., due regard to c(os), c(version)
//or even to c(N), e(N), and r(N)
//suppose you have a rule of thumb:
//never to run a regression when c(N)<30?
//maybe ok to run, but not to report output when e(df)<30?
//well, maybe ok to do all above, but with a proviso in reported output?
//you are in position to incorporate any of the above into your .do files!!!

//collapse [-] at if `condition' {
qui {
    clear 
    cls
	if c(N) { //lab6 dofile
	if c(N)<1 { //transplants.dta
	if c(N)<2 { //runiform(),two methods
	if c(N)>3 { //transplants reload
	if c(N)>4 { //r(normal),kdensity
	if c(N)>5 { //embed macro in text then graph
	if c(N)>6 { //collpase & egen equivalence!!!!!!
	if c(N)==r(N) | c(N)==6000 { //aesthetical .do file structure 
       timer list  
       log close 
}

