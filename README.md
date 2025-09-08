# 📊 Tech Layoffs Analysis (2020–2023)

## 📌 Project Overview
This project analyzes tech company layoffs from 2020 to 2023 using MySQL.  
The goal was to understand **trends, industries affected, and the progression of layoffs over time**.  

## 🔑 Key Questions Explored
1. Which companies had the highest layoffs?
2. Which industries and countries were most impacted?
3. How did layoffs progress monthly and yearly?
4. Which companies ranked in the top 5 layoffs each year?

## 📁 Project Structure

```
📂 mysql-exploratory-data-analysis/
├── layoffs-analysis/         
│   ├── exploratory_analysis.sql  # Tutorial queries
│   ├── layoffs_staging2.sql      # Cleaned dataset (if allowed)
│
│── README.md                     # Tutorial + documentation
```


## 🛠 SQL Highlights

- **Data Cleaning**: Removed duplicates, handled NULLs  
- **Aggregations**: `SUM()`, `MAX()`, `MIN()`, `AVG()`  
- **Date Functions**: `YEAR()`, `SUBSTRING()`  
- **Window Functions**: `DENSE_RANK()`, rolling totals with `OVER()`  
- **CTEs**: Organized queries for readability  

## 📊 Sample Queries

### 1. Top Companies by Layoffs

<img src=https://i.imgur.com/xYK5trT.png/>
</p>

### 2. Layoffs by Industry and Country
<img src=https://i.imgur.com/aLGRAlO.png/>
</p>

<img src=https://i.imgur.com/GEPjglm.png/>
</p>

### 3. Yearly Layoffs

<img src=https://i.imgur.com/bEW1Nhj.png/>
</p>

### 4. Rolling Monthly Totals

<img src=https://i.imgur.com/QuPkPYz.png/>
</p>

### 5. Top 5 Companies Each Year

<img src=https://i.imgur.com/3qZu5DY.png/>
</p>

## 📈 Key Insights

**Amazon & Google** had the largest layoffs overall

**Consumer & Retail** industries were most impacted

Layoffs peaked in **2022,** showing a sharp increase

Some well-funded companies (with billions raised) still **collapsed**