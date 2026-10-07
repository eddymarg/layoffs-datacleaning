# Data Cleaning in MySQL: Tech Layoffs Dataset

This project is part of my practice as I grow my skills in data analysis. I took a real-world dataset from Kaggle and cleaned it with MySQL so it would be ready for exploratory analysis. The goal was not only to end up with a clean table but to understand *why* each cleaning step matters and what can go wrong along the way.

## Dataset

**Source:** [Layoffs Dataset on Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022)

The dataset tracks tech layoffs from the start of COVID-19 onward. Each row describes a layoff event, with columns such as company, location, industry, total employees laid off, percentage laid off, date, funding stage, country, and funds raised.

Like most real-world data, it arrived with problems: duplicate rows, inconsistent spelling, dates stored as text, and missing values.

## Why Data Cleaning?

Analysis is only as reliable as the data behind it. A duplicated row inflates totals, an industry spelled two different ways splits into two groups, and dates stored as text can't be sorted or grouped by year. Cleaning comes before analysis so the insights that follow can be trusted.

## Cleaning Process

### 1. Create a Staging Table

I never edit the raw data directly. I copied it into a staging table first so the original stays untouched if I need to start over.

```sql
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;
```

### 2. Remove Duplicates

The table has no unique ID, so I used `ROW_NUMBER()` partitioned over every column to flag rows that appear more than once. Since MySQL can't delete directly from a CTE, I created a second staging table (`layoffs_staging2`) with a `row_num` column and deleted the rows where `row_num > 1`.

```sql
DELETE FROM layoffs_staging2
WHERE row_num > 1;
```

### 3. Standardize the Data

I looked for values that mean the same thing but were written differently, for example:

- Extra whitespace in company names, fixed with `TRIM()`
- Industry labels with several variations of the same name, merged into one
- Country names with a trailing period, fixed with `TRIM(TRAILING '.' FROM country)`

**What I learned here:** This step taught me the most. After the first conversion, re-running the `UPDATE` threw errors such as `Incorrect datetime value: '2022-11-17'`, because the values were already converted and no longer matched the `%m/%d/%Y` format. Later, comparing the column to the string `'NULL'` raised `Incorrect DATE value`, which told me the column had already become a `DATE` type. Working through these errors taught me to:

- Check the current state of a column (`DESCRIBE table_name;`) before modifying it
- Use a `WHERE` clause so updates only touch rows that actually need them
- Understand that a `DATE` column always stores values as `YYYY-MM-DD`, and that `DATE_FORMAT()` should be used for display instead of storing dates as text

### 5. Handle Null and Blank Values

Where possible, I filled in missing values from other rows. For instance, if a company had its industry listed in one row but blank in another, I used a self-join to populate the blank. Values that couldn't be reliably filled were left as NULL instead of guessed.

### 6. Remove Unusable Rows and Columns

Rows where both `total_laid_off` and `percentage_laid_off` were NULL offered little value for analysis about layoffs, so I removed them. Finally, I dropped the helper `row_num` column.

```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```

## Skills Practiced

- Creating staging tables to protect raw data
- Window functions (`ROW_NUMBER() OVER (PARTITION BY ...)`)
- CTEs
- String functions (`TRIM`, `LIKE`, `TRAILING`)
- Date conversion (`STR_TO_DATE`, `DATE_FORMAT`) and changing column types
- Self-joins to fill missing values
- Reading and debugging MySQL error messages

## Next Steps

With the data cleaned, the next phase is exploratory data analysis: looking at layoffs over time, by industry, by country, and by company stage to find trends.

## About Me

I'm building my skills in data analysis through hands-on projects like this one. Each project is a chance to practice real techniques on real data and to learn from the problems that come up along the way.
