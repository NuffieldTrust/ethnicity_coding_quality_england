# Analysis of ethnicity using English health service datasets

## Project description

In 2021, The Nuffield Trust released a
[report](https://www.nuffieldtrust.org.uk/research/ethnicity-coding-in-english-health-service-datasets) 
looking at the quality and consistency of ethnicity coding within health 
datasets. It used data from Hospital Episode Statistics (HES).  

Our reports describe the poor quality of ethnicity data, and the use of some 
techniques to describe these. In this repository, we show how we processed data 
from Hospital Episode Statistics (HES). This includes:
- Cleaning HES data
- Re-allocating ethnicity codes to improve data quality
- Reporting on data quality issues.



Note that in 2022, The Nuffield Trust released a second [report](https://www.nuffieldtrust.org.uk/research/the-elective-care-backlog-and-ethnicity) 
using ethnicity data. This report looked at how the impact of elective care 
backlog affected people across different ethnic groups. We will add the code 
from that project to this account in the coming months, and will update this 
file.

## Data sources

The data used for this analysis is not publically available, so the code 
cannot be used to directly replicate the analysis. However, with modifications 
the code could be used on other copies of these datasets.

This work uses Hospital Episode Statistics (HES) data . 
Copyright © 2021, re-used with permission. A data-sharing agreement with NHS 
Digital DARS-NIC-226261-M2T0Q) governed access to and use of HES data for this 
project. No results or derived outputs from these datasets are present in this 
repository, but this code was used to create the results presented in the 
main report.


## Requirements

The scripts were written in SAS, although much of the code to re-allocate 
ethnic categories is written using SQL (with PROC SQL).  

## Usage
* [01_data_preprocess.sas](01_data_preprocess.sas) has the code used to process 
the raw HES data (SAS)
* [02_reallocate_by_dataset.sas](02_reallocate_by_dataset.sas) shows how to 
reallocate ethnicity when you want to incorporate historic information about 
ethnicity from a single dataset. 
* [03_reallocate_all_datasets.sas](03_reallocate_all_datasets.sas) is an 
alternative approach to reallocating ethnicity using information from multiple 
datasets.
* [04_ethnicity_summary.sas](04_ethnicity_summary.sas) has some code to 
generate summaries from HES of how coding changes by ethnicity.


## Code authors
* Jonathan Spencer - [Twitter](https://twitter.com/jspncr_) - [Github](https://github.com/jspncrnt)
* Theo Georghiou - [Github](https://github.com/tgeorghiou)

## License
This project is licensed under the [MIT License](https://github.com/NuffieldTrust/ethnicity-coding-quality-england/blob/main/LICENSE).

## Acknowledgements
This project was supported by the NHS Race and Health Observatory.

## Suggested citation

Scobie S, Spencer J, Raleigh V (2021) Ethnicity coding in English health service datasets. Research report, Nuffield Trust
