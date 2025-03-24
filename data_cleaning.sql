-- SQL Data Cleaning Project: Layoffs Dataset

-- This script performs a full cleaning process on the 'company_layoffs' dataset.
-- Steps include:
--   1. Duplicate removal
--   2. Standardizing text fields
--   3. Handling null/blank values
--   4. Column and row cleanup

-- Result: A clean, analysis-ready version of the dataset stored in 'company_layoffs_cleaned2'

SELECT *
FROM company_layoffs;

SELECT COUNT(*)
FROM company_layoffs;

-- Create the table where modifications will be made
CREATE TABLE company_layoffs_cleaned
LIKE company_layoffs;

-- Since it was just created, it will appear empty...
SELECT *
FROM company_layoffs_cleaned;

-- Copy data from the original table to the one we will modify
-- WARNING: If you run this more than once, the data will be duplicated
INSERT company_layoffs_cleaned
SELECT *
FROM company_layoffs;

-- Now you can see the copied data
SELECT *
FROM company_layoffs_cleaned;

-- SELECT COUNT(*) FROM company_layoffs_cleaned;

-- Add a new column to the table to filter duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM company_layoffs_cleaned;

-- "cte" (common table expression): A virtual table that only exists when the query is executed. 
-- It helps write cleaner code and avoid subqueries.
-- "ROW_NUMBER() OVER (...) AS row_num" assigns a row number to each repeated entry within groups of:
-- company, location, etc. For example: if 3 rows are exactly the same, they'll be numbered 1, 2, 3.
-- "PARTITION BY (...)": Within each group of duplicates, the first gets row_num = 1, second = 2, etc.

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM company_layoffs_cleaned
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1;

-- Example of duplicate in `Oda`
SELECT *
FROM company_layoffs_cleaned
WHERE company = 'Oda';

-- Attempt to delete duplicates (this method does not work in MySQL)
WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM company_layoffs_cleaned
)
DELETE
FROM duplicate_cte 
WHERE row_num > 1;

-- SOLUTION: To allow deletion, we create another table (go to `company_layoffs_cleaned`, copy to clipboard + create statement)

CREATE TABLE `company_layoffs_cleaned2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Show the new empty table
SELECT *
FROM company_layoffs_cleaned2;

INSERT INTO company_layoffs_cleaned2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM company_layoffs_cleaned;

SELECT *
FROM company_layoffs_cleaned2
WHERE row_num > 1;


-- If anyone is having trouble here, I had an error code 1175. You just need to go to Edit-> Preferences-> 
-- SQL Editor -> and deselect the option "Safe Edits". You then have to exit and open again 
-- (save before you exit) and then run again.
DELETE 
FROM company_layoffs_cleaned2
WHERE row_num > 1;

-- One way to verify that duplicates were removed
SELECT *
FROM company_layoffs_cleaned2;

-- Part 1: Column "company"
-- "TRIM" removes white spaces (from beginning and end) or specific characters

SELECT company, TRIM(company)
FROM company_layoffs_cleaned2;

UPDATE company_layoffs_cleaned2
SET company = TRIM(company);

SELECT *
FROM company_layoffs_cleaned2;

-- Part 2: Column "industry": here we see 2 problems: NULL values and very similar industry names (needs normalization)
-- "DISTINCT" selects the first occurrence of each "industry". Doesn't repeat!
SELECT DISTINCT industry
FROM company_layoffs_cleaned2
ORDER BY industry; -- Or "order by 1" could be...

-- Detect rows to normalize
SELECT *
FROM company_layoffs_cleaned2
WHERE industry LIKE 'Crypto%';

-- Apply updates to the table
UPDATE company_layoffs_cleaned2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'; -- "Crypto" + whatever


-- Part 3: Column "country" (starts with location but moves on to analyze "country")
SELECT DISTINCT country
FROM company_layoffs_cleaned2
WHERE country LIKE 'United States%'
ORDER BY 1;

-- Filter rows with issue "United States." (not fixed yet)
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM company_layoffs_cleaned2
ORDER BY 1;

-- Apply the update to fix it
UPDATE company_layoffs_cleaned2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Column "date" is declared as text — not ideal
SELECT *
FROM company_layoffs_cleaned2;

-- Let's convert the format
SELECT `date`, STR_TO_DATE(`date`,'%m/%d/%Y')
FROM company_layoffs_cleaned2;

-- Apply the update with the correct format
UPDATE company_layoffs_cleaned2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

-- DESCRIBE company_layoffs_cleaned2;

ALTER TABLE company_layoffs_cleaned2
MODIFY COLUMN `date` DATE;

SELECT *
FROM company_layoffs_cleaned2;

UPDATE company_layoffs_cleaned2
SET industry= NULL
WHERE industry = '';

-- From line 218
SELECT *
FROM company_layoffs_cleaned2
WHERE industry IS NULL
OR industry = '';

-- Running this line you’ll see two rows from "Airbnb" where one has industry "Travel" and the other is NULL.
-- We'll do a JOIN to assign "Travel" to the row with NULL.
SELECT *
FROM company_layoffs_cleaned2
WHERE company = 'Airbnb';

SELECT blank_t1.industry, notblank_t2.industry
FROM company_layoffs_cleaned2 blank_t1
JOIN company_layoffs_cleaned2 notblank_t2
	ON blank_t1.company = notblank_t2.company
    -- AND blank_t1.location = notblank_t2.location -- Por las dudas se agrega esta condición (en caso que en algun lugar del mundo haya otra compania con el mismo nombre)
WHERE (blank_t1.industry IS NULL OR blank_t1.industry = '')
AND notblank_t2.industry IS NOT NULL;

-- Run the update on t1:
UPDATE company_layoffs_cleaned2 blank_t1
JOIN company_layoffs_cleaned2 notblank_t2
	ON blank_t1.company = notblank_t2.company
SET blank_t1.industry  = notblank_t2.industry
WHERE blank_t1.industry IS NULL
AND notblank_t2.industry IS NOT NULL;

-- If it doesn't work yet, unify all blank strings into NULL and rerun the same query
-- (refer back to line 190)

-- After running line 201, you should see that the company "Airbnb" now has "Travel" filled in correctly

-- Looking at the full dataset, we still see some rows with NULL values (total_laid_off, percentage_laid_off, funds_raised_millions)
-- SELECT COUNT(*)
SELECT *
FROM company_layoffs_cleaned2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Completely delete rows where both columns are NULL because the data isn’t relevant
DELETE 
FROM company_layoffs_cleaned2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM company_layoffs_cleaned2;

-- Finally, drop the "row_num" column created for duplicate removal
ALTER TABLE company_layoffs_cleaned2
DROP COLUMN row_num;