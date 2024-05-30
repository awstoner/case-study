-- Incremental dataset storing customer account IDs and subscription status by month, from 2023-06-01 onward.
MODEL (
  name splice_case_study.incremental_model,
  kind INCREMENTAL_BY_TIME_RANGE (
    time_column month
  ),
  start '2023-06-01',
  cron '@daily',
  grain (month, user_id)
);

SELECT
  month::DATE,
  user_id::BIGINT,
  cohort_month::DATE,
  customer_flag::INT
FROM
  splice_case_study.seed_model
WHERE
  month BETWEEN @start_date AND @end_date