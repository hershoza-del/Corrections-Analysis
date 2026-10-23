# Corrections-Analysis

An analysis of 10000+ staff in the NYC Department of Corrections for the 2025 fiscal year.

## Disclaimers

- Based from the original dataset in NYC Open Data (source down below), only corrections staff and the 2-25 fiscal year are taken into account.
- MOST IMPORTANTLY: these results down below are solely based from this filtered dataset.

## Approach

- Python (pandas): cleaned and rearranged the data
- SQL: exploring and summarizing the data for each question
- R (ggplot2 included): running statistical tests for each question and creating charts based on each question (charts can be found on my Hersh Oza LinkedIn page)

## Question 1: How does overtime pay at Rikers Island (Queens) compare with correction staff in the Bronx, Manhattan, and Brooklyn?

### Tests

- Kruskal-Wallis (do any boroughs differ?): χ² = 22.67, df = 3, p < 0.001. At least one borough differs.
- Pairwise Wilcoxon, Bonferroni-corrected (which ones?): Queens is lower than the Bronx (p = 0.001) and Manhattan (p = 0.008). No other pairs differ.
- One-way ANOVA + Tukey HSD (comparing means): F = 4.75, p = 0.003. Only Manhattan vs. Queens is significant; Manhattan's mean is about $7,100 higher (95% CI: $1,600 to $12,600).

### Interpretation

- Queens had the lowest median overtime pay compared with the Bronx, Manhattan, and Brooklyn, even with the infamous Rikers Island. However, the difference between the boroughs is only by a little.
- However, it's clear that boroughs aren't an indicator whether or not a corrections staff members would receive higher overtime pay. It really depends on a member's tenure and title held. 

## Question 2: To what extent do longer-tenured employees earn more in overtime and in base salary?

### Tests

- Spearman correlation (tenure vs. overtime pay): ρ = 0.38, p < 0.001. A moderate positive relationship.
- Linear regression, overtime pay ~ tenure: each additional year of tenure is associated with about $1,949 more in overtime pay (p < 0.001, R² = 0.11).
- Linear regression, base salary ~ tenure: each additional year is associated with about $1,537 more in base salary (p < 0.001, R² = 0.18).

### Interpretation

- While longer-tenured staff can earn more in overtime and base salary on paper, tenure doesn't fully explain nor account into how longer-tenured staff earns more money.
- The base salary for corrections officers, the largest group of staff, has remained almost stagnant for a five-year period, at around $105,000.
- Overtime pay is a huge indicator of how they earn more money, rather than raises in salary.

## Question 3: How do average overtime hours and total pay for corrections officers compare with that of other roles?

### Tests

- Wilcoxon rank-sum (Correction Officers vs. everyone else): W = 2,473,094, p < 0.001. COs work significantly more overtime hours than non-CO employees overall.
- Kruskal-Wallis across the top 8 titles: χ² = 710.9, df = 7, p < 0.001. Overtime hours differ strongly by title.

### Interpretation

- Staff who are uniformed (i.e wardens, captains, corrections officers) are likely to work more in overtime than those in civilian roles.
- A corrections officer works around 614 overtime hours per year, which is roughly 12 extra hours per week. While wardens and captains work more than corrections officers, corrections officers are the largest group of staff that receive overtime pay.
- A civilian role like program specialists work around 5 overtime hours per year. 

## Data Source

Citywide Payroll Data (Fiscal Year), published by the City of New York on NYC Open Data (dataset ID k397-673e) 
