# Sales Fact View & ETL Pipeline

An anonymized version of a real-world SQL Server BI/ERP data integration project.

## Overview

A `FactSales` view was developed to combine sales and return transactions and calculate net sales metrics.

**Data Flow:**

`ERP → FactSales View → SSIS → Data Warehouse → SQL Server Agent Job → BI Reports`

The data was loaded into the Data Warehouse using **SSIS**. A SQL Server Agent Job was configured to refresh the fact table every **30 minutes** by truncating the target table and loading the latest data.

### Key Concepts

* SQL Server / T-SQL
* SQL Views & complex joins
* `UNION ALL` and aggregations
* Sales & return calculations
* SSIS / ETL
* Data Warehouse
* SQL Server Agent Jobs
* BI reporting

## Confidentiality

The original project was developed using proprietary company data and database objects.

AI was used to anonymize the original SQL while **preserving its structure, architecture, and business logic**. Company-specific names, schemas, tables, fields, and identifiers have been replaced with generic equivalents.
