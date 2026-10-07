-- DATA Cleaning

SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data 
-- 3. Null value or blank values 
-- 4. Remove any columns

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`)
    AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, location, 
    industry, total_laid_off, `date`, percentage_laid_off, industry
    , stage, funds_raised, country)
    AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Beyond Meat';

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, location, 
    industry, total_laid_off, `date`, percentage_laid_off, industry
    , stage, funds_raised, country)
    AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `total_laid_off` int DEFAULT NULL,
  `date` date DEFAULT NULL,
  `percentage_laid_off` decimal(6,4) DEFAULT NULL,
  `industry` varchar(50) DEFAULT NULL,
  `source` text,
  `stage` varchar(50) DEFAULT NULL,
  `funds_raised` decimal(12,2) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `date_added` date DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, location, 
    industry, total_laid_off, `date`, percentage_laid_off, industry
    , stage, funds_raised, country)
    AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- Standardizing data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT
  SUM(`date` LIKE '%/%/%')      AS slash_format,
  SUM(`date` LIKE '____-__-__') AS iso_format,
  SUM(`date` IS NULL OR `date` = 'NULL' OR `date` = '') AS empty_or_null
FROM layoffs_staging2;

DESCRIBE layoffs_staging2;

SELECT `date`,
       DATE_FORMAT(`date`, '%m-%d-%Y') AS formatted_date
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2;

-- working with NULL and blank VALUES

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;





