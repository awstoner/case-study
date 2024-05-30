/* Total number of active customers, churned customers, and returning customers by reporting month and cohort month. */
MODEL (
  name splice_case_study.full_model,
  kind FULL,
  cron '@daily',
  grain (month, user_id)
);

WITH churn_return_calc AS (
  SELECT
    cohort_month,
    month,
    DATE_DIFF('MONTH', cohort_month, month) + 1 AS relative_month_number,
    user_id,
    customer_flag,
    CASE
      WHEN LAG(customer_flag, 1) OVER (PARTITION BY user_id ORDER BY month) = 1
      AND customer_flag = 0
      THEN TRUE
      ELSE FALSE
    END AS churn_flag,
    CASE
      WHEN LAG(customer_flag, 1) OVER (PARTITION BY user_id ORDER BY month) = 0
      AND customer_flag = 1
      THEN TRUE
      ELSE FALSE
    END AS return_flag
  FROM splice_case_study.incremental_model
  WHERE
    DATE_DIFF('MONTH', cohort_month, month) >= 0
    AND NOT (
      cohort_month = month AND customer_flag = 0
    )
)
SELECT
  cohort_month,
  month,
  relative_month_number,
  COUNT(DISTINCT CASE WHEN customer_flag = 1 THEN user_id END) AS overall_customers,
  COUNT(DISTINCT CASE WHEN churn_flag THEN user_id END) AS overall_churn,
  COUNT(DISTINCT CASE WHEN return_flag THEN user_id END) AS overall_return
FROM churn_return_calc
GROUP BY
  cohort_month,
  month,
  relative_month_number
ORDER BY
  cohort_month,
  month,
  relative_month_number