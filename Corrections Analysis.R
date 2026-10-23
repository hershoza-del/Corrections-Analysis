#importing libraries, csv dataset, and making some changes

library(dplyr)
library(lubridate)
library(ggplot2)
library(forcats)
df <- read_csv("/Users/hershoza/Downloads/Corrections_Analysis.csv", show_col_types = FALSE) |>
       rename(start_date         = `Agency Start Date`,
              borough            = `Work Location Borough`,
              title              = Title,
              eave_status        = `Leave Status`,
              base_salary        = `Base Salary`,
              pay_basis          = `Pay Basis`,
              regular_gross_paid = `Regular Gross Paid`,
              ot_hours           = `OT Hours`,
              total_ot_paid      = `Total OT Paid`,
              total_other_pay    = `Total Other Pay`) |>
       mutate(tenure     = as.numeric(difftime(ymd("2025-06-30"), mdy(start_date),
                                               units = "days")) / 365.25,
  total_comp = regular_gross_paid + total_ot_paid + total_other_pay,
  is_co      = title == "Correction Officer",
  borough    = factor(borough, levels = c("Queens", "Bronx", "Manhattan", "Brooklyn"))) |>
      filter(leave_status == "Active",
                pay_basis == "per Annum",
                !is.na(borough))

#tests regarding overtime pay in Rikers Island (Queens) versus the other boroughs

df <- df |> filter(regular_gross_paid >= 0, total_ot_paid >= 0,
                   total_other_pay >= 0, ot_hours >= 0)
top_titles <- df |> count(title, sort = TRUE) |> slice_head(n = 8) |> pull(title)
df_top     <- df |> filter(title %in% top_titles)
df |> group_by(borough) |>
    summarise(n = n(), median_ot = median(total_ot_paid), mean_ot = mean(total_ot_paid))
# A tibble: 4 × 4
  borough       n median_ot mean_ot
  <fct>     <int>     <dbl>   <dbl>
1 Queens     5874    41953.  46804.
2 Bronx       430    49799.  50396.
3 Manhattan   364    48818.  53885.
4 Brooklyn    118    45367.  44120.
  kruskal.test(total_ot_paid ~ borough, data = df)

        Kruskal-Wallis rank sum test

data:  total_ot_paid by borough
Kruskal-Wallis chi-squared = 22.671, df = 3,
p-value = 4.729e-05

pairwise.wilcox.test(df$total_ot_paid, df$borough, p.adjust.method = "bonferroni")

      Pairwise comparisons using Wilcoxon rank sum test with continuity correction 

data:  df$total_ot_paid and df$borough 

          Queens Bronx  Manhattan
Bronx     0.0013 -      -        
Manhattan 0.0077 1.0000 -        
Brooklyn  1.0000 0.4256 0.5830   

P value adjustment method: bonferroni 
  fit <- aov(total_ot_paid ~ borough, data = df)
  summary(fit)
              Df    Sum Sq   Mean Sq F value  Pr(>F)   
borough        3 2.252e+10 7.506e+09   4.747 0.00261 **
Residuals   6782 1.073e+13 1.581e+09                   
---
Signif. codes:  
0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
  TukeyHSD(fit)
  Tukey multiple comparisons of means
    95% family-wise confidence level

Fit: aov(formula = total_ot_paid ~ borough, data = df)

$borough
                        diff        lwr       upr
Bronx-Queens        3592.529  -1512.572  8697.630
Manhattan-Queens    7081.555   1562.020 12601.090
Brooklyn-Queens    -2684.090 -12185.223  6817.042
Manhattan-Bronx     3489.026  -3789.154 10767.206
Brooklyn-Bronx     -6276.620 -16896.326  4343.086
Brooklyn-Manhattan -9765.645 -20590.679  1059.389
                       p adj
Bronx-Queens       0.2694046
Manhattan-Queens   0.0054280
Brooklyn-Queens    0.8867565
Manhattan-Bronx    0.6065466
Brooklyn-Bronx     0.4262051
Brooklyn-Manhattan 0.0939831

#tests regarding tenure and if they earn more in overtime and salary 

  cor.test(df$tenure, df$total_ot_paid, method = "spearman", exact = FALSE)

        Spearman's rank correlation rho

data:  df$tenure and df$total_ot_paid
S = 3.2215e+10, p-value < 2.2e-16
alternative hypothesis: true rho is not equal to 0
sample estimates:
      rho 
0.3814608 

  m1 <- lm(total_ot_paid ~ tenure, data = df)
  summary(m1)

Call:
lm(formula = total_ot_paid ~ tenure, data = df)

Residuals:
    Min      1Q  Median      3Q     Max 
-125866  -25909   -3408   22404  212329 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) 24943.70     884.33   28.21   <2e-16 ***
tenure       1949.43      65.94   29.56   <2e-16 ***
---
Signif. codes:  
0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 37460 on 6784 degrees of freedom
Multiple R-squared:  0.1141,	Adjusted R-squared:  0.114 
F-statistic: 873.9 on 1 and 6784 DF,  p-value: < 2.2e-16

  m2 <- lm(base_salary ~ tenure, data = df)
  summary(m2)

Call:
lm(formula = base_salary ~ tenure, data = df)

Residuals:
   Min     1Q Median     3Q    Max 
-90799  -7957   2619   9765 189331 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) 82271.06     529.29  155.44   <2e-16 ***
tenure       1537.18      39.47   38.95   <2e-16 ***
---
Signif. codes:  
0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 22420 on 6784 degrees of freedom
Multiple R-squared:  0.1827,	Adjusted R-squared:  0.1826 
F-statistic:  1517 on 1 and 6784 DF,  p-value: < 2.2e-16

#tests regarding if correction officers earn more or less than that of other roles

  df_top |> group_by(title) |>
      summarise(n = n(), avg_ot_hours = mean(ot_hours), median_ot_hours = median(ot_hours)) |>
      arrange(desc(avg_ot_hours))
# A tibble: 8 × 4
  title                     n avg_ot_hours median_ot_hours
  <chr>                 <int>        <dbl>           <dbl>
1 Warden-Assistant Dep…    68        988.            902  
2 Captain                 515        788.            738  
3 Correction Officer     4972        631.            614. 
4 Program Specialist  …    65        304.              5  
5 Investigator            113        201.            151  
6 Principal Administra…    72        153.             12.5
7 Community Coordinator   111         88.9             2  
8 *Cook                    70         76.4            36  
  wilcox.test(ot_hours ~ is_co, data = df)

	      Wilcoxon rank sum test with continuity correction

data:  ot_hours by is_co
W = 2473094, p-value < 2.2e-16
alternative hypothesis: true location shift is not equal to 0

  kruskal.test(ot_hours ~ title, data = df_top)

	      Kruskal-Wallis rank sum test

data:  ot_hours by title
Kruskal-Wallis chi-squared = 710.92, df = 7,
p-value < 2.2e-16

  m_all <- lm(total_ot_paid ~ tenure + borough + is_co, data = df)
  summary(m_all)

Call:
lm(formula = total_ot_paid ~ tenure + borough + is_co, data = df)

Residuals:
    Min      1Q  Median      3Q     Max 
-132400  -24813   -5431   18870  227705 

Coefficients:
                  Estimate Std. Error t value Pr(>|t|)
(Intercept)        7329.77    1126.95   6.504 8.37e-11
tenure             2034.67      64.41  31.587  < 2e-16
boroughBronx      -1982.44    1803.72  -1.099   0.2718
boroughManhattan  -3848.08    1966.26  -1.957   0.0504
boroughBrooklyn  -16736.92    3364.95  -4.974 6.72e-07
is_coTRUE         23552.53     990.92  23.768  < 2e-16
                    
(Intercept)      ***
tenure           ***
boroughBronx        
boroughManhattan .  
boroughBrooklyn  ***
is_coTRUE        ***
---
Signif. codes:  
0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 35960 on 6780 degrees of freedom
Multiple R-squared:  0.1843,	Adjusted R-squared:  0.1837 
F-statistic: 306.5 on 5 and 6780 DF,  p-value: < 2.2e-16

#importing libraries

  library(scales)
  dir.create("figures", showWarnings = FALSE)

#graph regarding overtime pay in Rikers Island (Queens) versus the other boroughs 

  p1 <- ggplot(df, aes(borough, total_ot_paid)) +
      geom_boxplot(outlier.alpha = 0.2) +
      scale_y_continuous(labels = label_dollar()) +
      labs(x = NULL, y = "Total OT paid, FY2025", title = "Overtime pay by borough")
  ggsave("figures/q1_ot_by_borough.png", p1, width = 7, height = 5, dpi = 300)
  print(p1)
  
#graphs regarding tenure and if they earn more in overtime and salary
  
  p2 <- ggplot(df, aes(tenure, total_ot_paid, color = is_co)) +
      geom_point(alpha = 0.3, size = 0.8) +
      geom_smooth(method = "lm", se = FALSE) +
      scale_y_continuous(labels = label_dollar()) +
      scale_color_discrete(labels = c("Other titles", "Correction Officer")) +
      labs(x = "Years of tenure", y = "Total OT paid", color = NULL,
           title = "Tenure vs. overtime pay")
  ggsave("figures/q2_tenure_vs_ot.png", p2, width = 7, height = 5, dpi = 300)
 `geom_smooth()` using formula = 'y ~ x'
  print(p2)
  
 `geom_smooth()` using formula = 'y ~ x'
   p2b <- ggplot(df, aes(tenure, base_salary, color = is_co)) +
       geom_point(alpha = 0.3, size = 0.8) +
       geom_smooth(method = "lm", se = FALSE) +
       scale_y_continuous(labels = label_dollar()) +
       scale_color_discrete(labels = c("Other titles", "Correction Officer")) +
       labs(x = "Years of tenure", y = "Base salary", color = NULL,
            title = "Tenure vs. base salary")
  ggsave("figures/q2_tenure_vs_salary.png", p2b, width = 7, height = 5, dpi = 300)
 `geom_smooth()` using formula = 'y ~ x'
  print(p2b)
  
#graph regarding if correction officers earn more or less than that of other roles
  
 `geom_smooth()` using formula = 'y ~ x'
   p3 <- df_top |> group_by(title) |>
       summarise(avg_ot_hours = mean(ot_hours)) |>
       ggplot(aes(fct_reorder(title, avg_ot_hours), avg_ot_hours)) +
       geom_col() +
       coord_flip() +
       labs(x = NULL, y = "Average OT hours, FY2025", title = "Overtime hours by title (top 8 by headcount)")
   ggsave("figures/q3_ot_hours_by_title.png", p3, width = 8, height = 5, dpi = 300)
   print(p3)