-- Exploratory Data Analysis 

SELECT * 
FROM layoffs_staging2;
# Peek at the dataset (raw view of all rows/columns)

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
# Quick stats: max layoffs & max percentage laid off

-- total_laid_off is more meaningful
-- Example: one company laid off 12,000 people in a single day

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1; 
# 100% layoffs → company completely shut down

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC; 
# Sort companies that collapsed by number of employees lost

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

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
# Check which industries were hit hardest

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
# Daily totals → each date with sum of layoffs

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
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
# ⚠️ SUM(percentage) is misleading → doesn’t reflect true scale

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

SELECT SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`;
# Monthly total only (missing years, so can overlap)

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC;
# Extract YYYY-MM for clearer timeline view

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
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
SELECT `MONTH`, total_off,
       SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
# Adds each month’s layoffs to previous months → cumulative trend

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;
# Break down layoffs by company & year (small ones first)

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;
# Same breakdown but highlight biggest layoffs

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
WITH Company_Year (company, years, total_laid_off) AS
(
  SELECT company, YEAR(`date`), SUM(total_laid_off)
  FROM layoffs_staging2
  GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(
  SELECT *, 
         DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
  FROM Company_Year
  WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;
# Shows top 5 companies with the biggest layoffs for each year