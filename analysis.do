/*******************************************************************************
Project:  GDP and Health Indicators in Nordic Countries, 2000-2018
File:     analysis.do
Purpose:  Reproduce the historical panel-data econometrics workflow
Author:   Aliye Nezhad
Version:  Stata 15.1+

Run this file from the repository root. The historical data and model sequence
are preserved; revisions are limited to paths, validation, comments, package
checks, and reproducible logging.
*******************************************************************************/

version 15.1
clear all
set more off
set linesize 100
capture log close _all

local data_file "data/Aliyeftn.stata.xlsx"

capture confirm file "`data_file'"
if _rc {
    display as error "Input file not found: `data_file'"
    display as error "Set Stata's working directory to the repository root and rerun analysis.do."
    exit 601
}

capture mkdir "outputs"
log using "outputs/gdp_health_analysis.log", replace text

/*******************************************************************************
1. Data import and validation
*******************************************************************************/

import excel using "`data_file'", sheet("Sheet1") cellrange(A2:H77) clear

rename (A B C D E F G H) ///
       (country year id time_id gdp life_expectancy age_dependency population)

replace country = strtrim(country)

foreach var in year id time_id gdp life_expectancy age_dependency population {
    capture confirm numeric variable `var'
    if _rc {
        destring `var', replace ignore(",")
    }
}

assert _N == 76
assert !missing(country, year, id, time_id, gdp, life_expectancy, ///
                age_dependency, population)
assert inrange(year, 2000, 2018)
assert inrange(id, 1, 4)

isid id time_id
sort id time_id
by id: assert _N == 19

assert country == "Norway"  if id == 1
assert country == "Sweden"  if id == 2
assert country == "Finland" if id == 3
assert country == "Denmark" if id == 4

foreach var in gdp life_expectancy age_dependency population {
    assert `var' > 0
}

quietly summarize population if country == "Denmark"
if r(max) < 1000000 {
    display as error "DATA NOTE: Denmark's population field is on a different scale from the other countries."
    display as error "The historical values are preserved, but substantive interpretation is not recommended."
}

generate double lngdp = ln(gdp)
generate double lnl   = ln(life_expectancy)
generate double lna   = ln(age_dependency)
generate double lnp   = ln(population)

label variable country        "Country"
label variable year           "Calendar year"
label variable id             "Country panel identifier"
label variable time_id        "Annual time identifier"
label variable gdp            "Gross domestic product"
label variable life_expectancy "Life expectancy at birth"
label variable age_dependency "Age dependency ratio"
label variable population     "Population field in historical workbook"
label variable lngdp          "Log GDP"
label variable lnl            "Log life expectancy at birth"
label variable lna            "Log age dependency ratio"
label variable lnp            "Log population field"

order country year id time_id gdp life_expectancy age_dependency population ///
      lngdp lnl lna lnp

xtset id time_id, yearly
xtdescribe
summarize lngdp lnl lna lnp

/*******************************************************************************
2. Baseline fixed-effects model
*******************************************************************************/

xtreg lngdp lnl lna lnp, fe
estimates store fe_model

* The reported F test that all country effects equal zero compares the
* fixed-effects specification with pooled OLS.

/*******************************************************************************
3. Cross-sectional dependence
*******************************************************************************/

capture which xtcsd
if _rc {
    display as text "Installing required user-written command: xtcsd"
    ssc install xtcsd
}

xtcsd, pesaran abs

/*******************************************************************************
4. Panel unit-root checks

These historical checks are retained for replication. With four panels and
evidence of cross-sectional dependence, their p-values require caution.
*******************************************************************************/

xtunitroot llc lngdp
xtunitroot llc lnl
xtunitroot llc lna
xtunitroot llc lna, trend
xtunitroot llc lnp, trend

/*******************************************************************************
5. Fixed-effects versus random-effects specification
*******************************************************************************/

xtreg lngdp lnl lna lnp, re
estimates store re_model

hausman fe_model re_model, sigmamore

/*******************************************************************************
6. Groupwise heteroskedasticity comparison
*******************************************************************************/

xtgls lngdp lnl lna lnp, panels(iid) corr(independent)
estimates store homoskedastic_gls

xtgls lngdp lnl lna lnp, panels(heteroskedastic) corr(independent) igls
estimates store heteroskedastic_gls

lrtest heteroskedastic_gls homoskedastic_gls, df(3)

/*******************************************************************************
7. Serial correlation
*******************************************************************************/

capture which xtserial
if _rc {
    display as text "Installing required user-written command: xtserial"
    ssc install xtserial
}

xtserial lngdp lnl lna lnp

/*******************************************************************************
8. Historical final specifications
*******************************************************************************/

xtregar lngdp lnl lna lnp, fe rhotype(dw)
estimates store fe_ar1

xtgls lngdp lnl lna lnp, panels(correlated) corr(ar1) igls
estimates store final_fgls

estimates table fe_model re_model fe_ar1 final_fgls, ///
    b(%9.3f) se(%9.3f) stats(N)

/*******************************************************************************
9. End of analysis
*******************************************************************************/

display as result "Analysis completed. Output saved to outputs/gdp_health_analysis.log"
log close
