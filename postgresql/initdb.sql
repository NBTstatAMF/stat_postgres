CREATE USER docker WITH PASSWORD 'stat4omor';
-- CREATE DATABASE docker;


CREATE DATABASE db_stat_dep WITH ENCODING 'UTF-8' OWNER docker;
\c db_stat_dep;
SET ROLE docker;
CREATE SCHEMA sma_stat_dep;

-- GRANT ALL PRIVILEGES ON DATABASE db_stat_dep TO docker;
-- GRANT ALL PRIVILEGES ON SCHEMA sma_stat_dep TO docker;

-- upload_statuses options: [1: pending, 2: in_process, 3 - imported, 4: - finished, 5: - reject, 0: - error]
-- channer [1: email, 2: api, 3: ftp, 4: filesys]


CREATE TABLE sma_stat_dep.tbl_file_upload (
  id SERIAL PRIMARY KEY,
  UID VARCHAR(100),
  fetch_id VARCHAR(255) NOT NULL,
  email_datetime TIMESTAMP WITH TIME ZONE,
  uploaded_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
  email_from VARCHAR(255),
  upload_status INT NOT NULL,
  channel INT NOT NULL
);

CREATE TABLE sma_stat_dep.tbl_files(
  id SERIAL PRIMARY KEY,
  id_file_upload INT NOT NULL,
  upload_status INT NOT NULL,
  file_name VARCHAR(100) NOT NULL,
  file BYTEA NOT NULL,
  logs VARCHAR,
  schedule INT
);

CREATE TABLE sma_stat_dep.tbl_schedule(
  id SERIAL PRIMARY KEY,
  report_type_id INT NOT NULL, 
  bank_id INT NOT NULL,
  period_id INT NOT NULL,
  version_id INT NOT NULL, 
  reporting_window INT NOT NULL,
  UNIQUE (report_type_id, bank_id, period_id, version_id)
);

CREATE TABLE sma_stat_dep.tbl_report_type(
  id SERIAL PRIMARY KEY,
  code VARCHAR(100),
  version VARCHAR (100),
  name VARCHAR(100),
  validation_config VARCHAR, 
  report_period_type INT NOT NULL,
  UNIQUE (code, version, report_period_type)
);

-- status's options: [0: disabled, 1: enaled]
CREATE TABLE sma_stat_dep.tbl_metadata(
  id SERIAL PRIMARY KEY,
  code VARCHAR(100),
  version VARCHAR(100) UNIQUE,
  status INT
);

-- status's options: [0: disabled, 1: enaled]
-- type's options: [1: bank, 2: non_bank_credit_org, 3: MDO, 4: MKO, 5: MKF, 6: Islamic bank]
CREATE TABLE sma_stat_dep.tbl_entities(
  id SERIAL PRIMARY KEY,
  code VARCHAR (20) UNIQUE, 
  bic4 VARCHAR(4) UNIQUE,
  name VARCHAR(100),
  type INT,
  label_id INT,
  status INT
);

CREATE TABLE sma_stat_dep.tbl_period(
  id SERIAL PRIMARY KEY,
  type INT, 
  from_date DATE,
  to_date DATE,
  order_number INT,
  UNIQUE (type, from_date, to_date)
);

CREATE TABLE sma_stat_dep.tbl_version(
  id SERIAL PRIMARY KEY,
  code VARCHAR(100) UNIQUE,
  name VARCHAR(100)
);

CREATE TABLE sma_stat_dep.tbl_ent(
  id SERIAL PRIMARY KEY,
  code VARCHAR(100) UNIQUE,
  name VARCHAR(100),
  tstp TIMESTAMP
);

CREATE TABLE sma_stat_dep.tbl_file_per_schedule(
  id SERIAL PRIMARY KEY,
  schedule_id INT REFERENCES sma_stat_dep.tbl_schedule(id),
  file_id INT REFERENCES sma_stat_dep.tbl_files(id),
  UNIQUE (schedule_id, file_id)
);

CREATE TABLE sma_stat_dep.tbl_attr_values(
  id SERIAL PRIMARY KEY,
  ent_id INT REFERENCES sma_stat_dep.tbl_ent(id),
  file_per_schedule_id INT REFERENCES sma_stat_dep.tbl_file_per_schedule(id),
  a_value JSONB 
);

CREATE INDEX idxgin_a_values ON sma_stat_dep.tbl_attr_values USING GIN (a_value);
