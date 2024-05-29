MODEL (
  name splice_case_study.seed_model,
  kind SEED (
    path '../seeds/cohort_test_data.csv'
  ),
  -- No need for additional csv settings (custom delimiters, encoding, etc.) with the sample dataset
  columns (
    month DATE,
    user_id BIGINT,
    cohort_month DATE,
    customer_flag INT
  ),
  grain (id, event_date)
);
