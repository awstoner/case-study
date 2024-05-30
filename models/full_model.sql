-- Total number of active customers, churned customers, and returning customers by reporting month and cohort month.
MODEL (
  name splice_case_study.full_model,
  kind FULL,
  cron '@daily',
  grain (cohort_month, user_id),
);

WITH churn_return_calc AS (
    SELECT
        cohort_month
        , month
        , DATE_DIFF('month', cohort_month, month) + 1 AS relative_month_number
        , user_id
        , customer_flag
        , CASE
            WHEN LAG(customer_flag, 1) OVER (PARTITION BY user_id ORDER BY month) = 1 AND customer_flag = 0 THEN 1
            WHEN LAG(customer_flag, 1) OVER (PARTITION BY user_id ORDER BY month) = 0 AND customer_flag = 1 THEN 2
            ELSE NULL
        END AS return_or_churn_flag
    FROM splice_case_study.incremental_model
    WHERE DATE_DIFF('month', cohort_month, month) >= 0
)
SELECT
    cohort_month
    , month
    , relative_month_number
    , COUNT(DISTINCT CASE WHEN customer_flag = 1 THEN user_id END) AS overall_customers
    , COUNT(DISTINCT CASE WHEN return_or_churn_flag = 1 THEN user_id END) AS overall_churn
    , COUNT(DISTINCT CASE WHEN return_or_churn_flag = 2 THEN user_id END) AS overall_return
FROM churn_return_calc
GROUP BY cohort_month, month, relative_month_number
ORDER BY cohort_month, month, relative_month_number;