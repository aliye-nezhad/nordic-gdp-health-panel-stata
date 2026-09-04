# Data Documentation

## Files

| File | Status | Purpose |
| --- | --- | --- |
| `raw/nordic_gdp_health_panel_2000_2018.xlsx` | Historical input | Original workbook used by `run_analysis.do` |
| `processed/nordic_gdp_health_panel_2000_2018.dta` | Generated output | Analysis-ready panel created by `run_analysis.do` |

`run_analysis.do` imports cells `A2:H77` from `Sheet1`. It does not use the
formula-generated copies in columns J:Q because the logarithms are recreated in
Stata.

## Variables

| Source column | Stata variable | Description |
| --- | --- | --- |
| A | `country_name` | Country name |
| B | `year` | Calendar year, 2000-2018 |
| C | `country_id` | Country identifier, 1-4 |
| D | `time_id` | Within-country time identifier, 1-19 |
| E | `gdp` | Gross domestic product field |
| F | `life_expectancy` | Life expectancy at birth |
| G | `age_dependency` | Age dependency ratio |
| H | `population` | Population field |

The script creates `lngdp`, `lnl`, `lna`, and `lnp` as natural logarithms.

## Panel Structure

The dataset is strongly balanced:

- four countries;
- 19 annual observations per country;
- 2000 through 2018; and
- 76 observations in total.

## Provenance and Validation Limitation

The historical workbook does not contain complete source documentation, including source URLs, indicator codes, retrieval dates, or a full data dictionary. The repository therefore treats the workbook as a historical replication input rather than a fully documented research dataset.

During validation, Denmark's population field was found to range from approximately 69,650 to 71,625, while the other countries' population fields are recorded in millions. This appears to indicate a scale or variable-definition inconsistency. The values are deliberately preserved without correction to maintain reproducibility of the historical workflow.

Specifications including the population variable should therefore be interpreted with caution.

## Reproducibility

The raw workbook is not overwritten. Running `run_analysis.do` from the repository
root regenerates `processed/nordic_gdp_health_panel_2000_2018.dta` and every file under `outputs/`.
