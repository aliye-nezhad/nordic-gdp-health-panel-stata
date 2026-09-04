# GDP and Health Indicators in Nordic Countries

## Overview

This repository contains a reproducible Stata workflow for a balanced panel of
Norway, Sweden, Finland, and Denmark from 2000 through 2018. It examines
conditional associations between gross domestic product, life expectancy, age
dependency, and population.

The project is presented as a Stata and panel-data coding sample. It is not a
causal research design, and the estimates should not be interpreted as causal
effects.

## Research Question

How are selected health and demographic indicators associated with GDP in a
four-country Nordic panel?

The historical log-linear specification is:

```text
ln(GDP_it) = alpha_i
           + beta_1 ln(LifeExpectancy_it)
           + beta_2 ln(AgeDependency_it)
           + beta_3 ln(Population_it)
           + error_it
```

## Data

The historical workbook contains 76 observations: four countries observed
annually for 19 years. The script imports the original levels from columns A:H
and creates the logarithmic variables directly in Stata.

| Variable | Description | Role |
| --- | --- | --- |
| `gdp` | Gross domestic product | Dependent variable |
| `life_expectancy` | Life expectancy at birth | Health indicator |
| `age_dependency` | Age dependency ratio | Demographic indicator |
| `population` | Population field in the historical workbook | Scale control |
| `country_id` | Country identifier | Panel dimension |
| `year` | Calendar year | Time dimension |

The original workbook does not include complete metadata documentation (such as source URLs, indicator codes, or retrieval dates). The dataset is therefore preserved as provided for replication of the original workflow. During validation, a potential scale inconsistency was identified in Denmark's population variable; this issue is documented and should be considered when interpreting substantive results. See [`data/README.md`](data/README.md).

## Empirical Workflow

The single Stata script performs:

- Excel import, variable construction, and validation;
- balanced-panel declaration;
- descriptive-statistics and correlation exports;
- fixed-effects and random-effects estimation;
- a Hausman specification test;
- a Wooldridge test for serial correlation;
- fixed-effects AR(1) and FGLS specifications;
- fitted-value and residual construction; and
- automated export of tables, figures, a processed dataset, and a complete log.

## Repository Structure

```text
nordic-gdp-health-panel-stata/
├── README.md
├── LICENSE
├── .gitignore
├── replication/
│   └── run_analysis.do
├── data/
│   ├── README.md
│   ├── raw/
│   │   └── nordic_gdp_health_panel_2000_2018.xlsx
│   └── processed/
│       └── nordic_gdp_health_panel_2000_2018.dta
└── outputs/
    ├── figures/
    │   ├── age_dependency_by_country.png
    │   ├── life_expectancy_by_country.png
    │   └── log_gdp_by_country.png
    └── tables/
        ├── correlation_matrix.txt
        ├── descriptive_statistics.txt
        ├── hausman_test.txt
        └── model_comparison.txt
```

## Requirements

- Stata 15.1 or later
- Internet access on the first run if the community-contributed `xtserial`
  command is not already installed

The script attempts to install `xtserial` from Stata Journal package `st0039`
when needed. A Python-style `requirements.txt` is not needed.

## Reproduction

Download or clone the repository, open Stata, and set the working directory to
the repository root. On Windows:

```stata
cd "C:\path\to\nordic-gdp-health-panel-stata"
do run_analysis.do
```

The script expects `data/raw/nordic_gdp_health_panel_2000_2018.xlsx` and recreates the documented
tables, figures, dataset, and log.

## Output Guide

| Location | Contents |
| --- | --- |
| `outputs/tables/` | Descriptive statistics, correlations, Hausman output, and model comparison |
| `outputs/figures/` | GDP, life-expectancy, age-dependency, and residual diagnostics |
| `outputs/logs/` | Complete Stata execution record |
| `data/processed/nordic_gdp_health_panel_2000_2018.dta` | Analysis-ready panel with variables created by the script |

## Interpretation and Limitations

This project estimates conditional associations and is presented as an applied panel-data coding sample rather than a causal research design.

Important limitations include:

- a small panel consisting of four countries with 19 annual observations per country;
- incomplete provenance documentation for the historical workbook, including missing source metadata;
- a potential scale inconsistency identified in Denmark's population variable;
- GDP measured in nominal current-dollar terms rather than real GDP or per-capita measures;
- strongly trending macroeconomic variables and exposure to common time shocks;
- limited statistical power given the small number of cross-sectional units; and
- potential reverse causality and omitted-variable bias.

The FGLS specification is retained as part of the historical econometric workflow and robustness exercise. It should not be interpreted as fully resolving identification, endogeneity, or inference limitations.

## Skills Demonstrated

- Stata data import and validation;
- panel-data setup and estimation;
- diagnostic testing and model comparison;
- automated output generation; and
- transparent documentation of empirical limitations.

## Author

Aliye Nezhad

## License

The code and documentation are released under the MIT License. No separate license is asserted over the historical input workbook.
