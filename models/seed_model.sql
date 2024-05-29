MODEL (
  name sqlmesh_example.seed_model,
  kind SEED (
    path '../seeds/seed_data.csv'
  ),
  columns (
    id INTEGER,
    item_id INTEGER,
    event_date DATE,
    nullz INT
  ),
  grain (id, event_date)
);
