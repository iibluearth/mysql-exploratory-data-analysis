-- Exploratory Data Analysis 

SELECT * 
FROM layoffs_staging2;
# Peek at the dataset (raw view of all rows/columns)

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
# Quick stats: max layoffs & max percentage laid off
-- total_laid_off is more meaningful
# Shows max(percentage_laid_off) = 1 means 100 people was laidoffs
-- Example: one company laid off 12,000 people in a single day

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1; 
# Shows the companies completely went under that lost all their employees
# 100% layoffs → company completely shut down

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC; 
# Sort companies that collapsed by large number of employees lost

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; 
# Compare big funding vs. still failing companies

-- Total layoffs by company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
# Aggregated layoffs by company (Amazon, Google usually top)

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
# Find dataset timeframe (earliest & latest layoff dates)
# Min date 2020-03-11 and Max 2023-03-06

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
# Check which industries were hit hardest

SELECT * 
FROM layoffs_staging2;
# Peek at the dataset (raw view of all rows/columns)

-- Total layoffs by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
# See which countries had the most layoffs

SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;
# Shows individual dates and shows the SUM total_laid_off
# Daily totals → each date with sum of layoffs

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
# Shows Years GROUP BY to showing the SUM total_laid_off 
# Yearly trends → how layoffs grew/shrank by year

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
# Startup stage vs. growth vs. post-IPO layoffs

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
# ⚠️ SUM(percentage_laid_off) is misleading → doesn’t reflect true scale

SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
# AVG % also not too useful (doesn’t show company size impact)

-- Progression of layoffs over time
-- Build rolling totals
SELECT SUBSTRING(`date`,6,2) AS `MONTH`
FROM layoffs_staging2;
# Extract month from YYYY-MM-DD (positions 6-7)
# Count the date 2023-11-17 stop on 6 position (count #'s) on the date column and take 2 characters of the month

SELECT SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`
;
# Monthly total only (missing years, so can overlap)

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC
;
# Extract YYYY-MM for clearer timeline view
# Count date 2023-11-17  stop on 1 position (count #'s) on the date column and take 7 characters (count # and even '-')
# Show NULLs

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE `MONTH` IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;
# Error: Unknown column 'MONTH in WHERE clause

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;
# Removes NULLs and orders chronologically

-- Rolling totals (cumulative sum over months)
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, SUM(total_laid_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
# Error: Unknown column 'total_laid_off' in field list

-- Rolling totals (cumulative sum over months)
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
# Shows MONTH and rolling_total and want to see total_off column

-- Rolling totals (cumulative sum over months)
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
# Adds each month’s layoffs to previous months → cumulative trend
# Now shows MONTH, total_off (laid off) and rolling_total (progression)
# It adds on the next months + total_off = rolling_total
# 2020 as rolling_total 9628-80998
# 2021 looks like a good start to end rolling_total 87811-96821
# 2022 drops dramatically as rolling_total 97331-257482
# 2023 for first 3 months as rolling_total 342196-383159

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
# Shows the company and sum(total_laid_off)

SELECT company, `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `date`
;
# Shows the date  of the company SUM(total_laid_off) and wants to see the year

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC # small companies
;
# Shows the year with SUM total_laid_off of the company
# Break down layoffs by company & year (small ones first)

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC # large companies
;
# Shows companies like Google and Meta Year(`date`) with SUM(total_laid_off)
# Same breakdown but highlight biggest layoffs

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *
FROM Company_Year;
# Make CTE
# Shows company, years and total_laid_off As Company_Year

-- Ranking by year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;
# Ranking companies by layoffs each year (ignores NULL years)

-- Top 5 layoffs per year
WITH Company_Year (company, years, total_laid_off) AS # 1st CTE
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS # 2nd CTE
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * # Query off the 2nd CTE
FROM Company_Year_Rank
WHERE Ranking <= 5;
# Shows top 5 companies with the biggest layoffs for each year

