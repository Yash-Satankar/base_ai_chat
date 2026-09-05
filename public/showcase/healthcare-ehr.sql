-- ============================================================
-- Project  : Hospital Clinical Database
-- Generated: 2026-09-05 11:04:05
-- Engine   : AI DB Schema Generator
-- Rules    : 98 production rules applied
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
START TRANSACTION;

-- ============================================================
-- Project  : Hospital Clinical Database
-- Generated: 2026-09-05 10:57:44
-- Modules  : 6
-- Tables   : 32
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
START TRANSACTION;


-- ============================================================
-- MODULE: Infrastructure  (2 tables)
-- ============================================================

CREATE TABLE unique_id_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  table_name VARCHAR(100) NOT NULL COMMENT 'Logical table this ID sequence is for',
  id_for VARCHAR(50) NOT NULL COMMENT 'Business entity this ID represents',
  prefix VARCHAR(20) NOT NULL COMMENT 'Business ID prefix (e.g. PAT, DOC, WRD)',
  last_id VARCHAR(15) NOT NULL DEFAULT '00000' COMMENT 'Last issued numeric sequence',
  business_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. UI_id)',
  domain_code VARCHAR(10) NOT NULL COMMENT 'Domain specific code (e.g. HCS for healthcare)',
  effective_date DATETIME NOT NULL COMMENT 'Date from which this ID is valid',
  expiry_date DATETIME NULL COMMENT 'Date after which this ID is retired',
  amount_limit DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Monetary ceiling associated with the ID',
  flag_active TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=active, 0=inactive flag for quick checks',
  total_child_records INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of all child rows linked to this entity',
  count_active_children INT NOT NULL DEFAULT 0 COMMENT 'Counter of currently active child records',
  last_child_id VARCHAR(20) NULL COMMENT 'Business ID of the most recently created child record',
  description VARCHAR(255) NULL COMMENT 'Free‑form description or notes',
  added_by INT NOT NULL COMMENT 'User ID who created this registry entry',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  CONSTRAINT fk_uniqueid_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_uniqueid_table_name (table_name),
  INDEX idx_uniqueid_prefix (prefix),
  INDEX idx_uniqueid_last_id (last_id),
  INDEX idx_uniqueid_last_child_id (last_child_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE factory_reset_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key (singleton row)',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=maintenance, 3=decommissioned',
  app_version VARCHAR(20) NOT NULL COMMENT 'Current deployed application version',
  maintenance_mode TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=maintenance window active, 0=normal operation',
  api_throttle_enabled TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=API throttling enforced, 0=disabled',
  feature_prescription_enabled TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=Prescription module enabled, 0=disabled',
  feature_lab_results_enabled TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=Lab results module enabled, 0=disabled',
  max_concurrent_jobs INT NOT NULL DEFAULT 10 COMMENT 'Maximum number of concurrent background jobs',
  default_locale VARCHAR(10) NOT NULL DEFAULT 'en_IN' COMMENT 'Default locale for the platform',
  data_retention_days INT NOT NULL DEFAULT 365 COMMENT 'Number of days to retain transactional data',
  audit_logging_enabled TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=Audit logging active, 0=inactive',
  emergency_shutdown TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=Emergency shutdown engaged, 0=normal',
  added_by INT NOT NULL COMMENT 'User ID who last modified the feature flags',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  CONSTRAINT fk_factoryreset_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_factoryreset_app_version (app_version),
  INDEX idx_factoryreset_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Clinical Core  (14 tables)
-- ============================================================

CREATE TABLE patient_record_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=discharged, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  PR_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. PR00001)',
  patient_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient',
  patient_ref_id INT NOT NULL COMMENT 'FK to patient_header_all.id',
  encounter_date DATETIME NOT NULL COMMENT 'Date and time of patient admission/encounter start',
  discharge_date DATETIME NULL COMMENT 'Date and time of patient discharge, if applicable',
  diagnosis_code VARCHAR(10) NOT NULL COMMENT 'Primary diagnosis ICD‑10 code',
  primary_physician_id INT NOT NULL COMMENT 'User ID of the attending physician',
  primary_physician_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  ward_id INT NOT NULL COMMENT 'Ward where patient is admitted',
  ward_ref_id INT NOT NULL COMMENT 'FK to ward_header_all.id',
  bed_number VARCHAR(5) NOT NULL COMMENT 'Bed identifier within the ward',
  total_medications INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of medication items linked to this record',
  total_lab_tests INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of lab test results linked to this record',
  last_medication_on DATETIME NULL COMMENT 'Timestamp of the most recent medication order',
  last_lab_result_on DATETIME NULL COMMENT 'Timestamp of the most recent lab result entry',
  is_critical TINYINT NOT NULL DEFAULT 0 COMMENT 'Flag indicating critical condition (1=Yes, 0=No)',
  insurance_provider VARCHAR(100) NULL COMMENT 'Name of the insurance provider',
  insurance_policy_no VARCHAR(50) NULL COMMENT 'Policy number of the patient''s insurance',
  total_charges DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Total billed amount for the encounter',
  added_by INT NOT NULL COMMENT 'User ID who created this patient record',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  CONSTRAINT fk_patient_record_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_patient_record_physician_ref FOREIGN KEY (primary_physician_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_patient_record_ward_ref FOREIGN KEY (ward_ref_id) REFERENCES ward_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_patient_record_patient_id (patient_id),
  INDEX idx_patient_record_patient_ref_id (patient_ref_id),
  INDEX idx_patient_record_primary_physician_id (primary_physician_id),
  INDEX idx_patient_record_ward_id (ward_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE patient_record_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL COMMENT '1=active, 2=inactive, 3=discharged, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  PR_id VARCHAR(20) NOT NULL COMMENT 'Human‑readable business ID (e.g. PR00001)',
  patient_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient',
  encounter_date DATETIME NOT NULL COMMENT 'Date and time of patient admission/encounter start',
  discharge_date DATETIME NULL COMMENT 'Date and time of patient discharge',
  diagnosis_code VARCHAR(10) NOT NULL COMMENT 'Primary diagnosis ICD‑10 code',
  primary_physician_id INT NOT NULL COMMENT 'User ID of the attending physician',
  ward_id INT NOT NULL COMMENT 'Ward where patient was admitted',
  bed_number VARCHAR(5) NOT NULL COMMENT 'Bed identifier within the ward',
  total_medications INT NOT NULL COMMENT 'Aggregate counter of medication items',
  total_lab_tests INT NOT NULL COMMENT 'Aggregate counter of lab test results',
  last_medication_on DATETIME NULL COMMENT 'Timestamp of the most recent medication order',
  last_lab_result_on DATETIME NULL COMMENT 'Timestamp of the most recent lab result entry',
  is_critical TINYINT NOT NULL COMMENT 'Flag indicating critical condition (1=Yes, 0=No)',
  insurance_provider VARCHAR(100) NULL COMMENT 'Name of the insurance provider',
  insurance_policy_no VARCHAR(50) NULL COMMENT 'Policy number of the patient''s insurance',
  total_charges DECIMAL(12,2) NOT NULL COMMENT 'Total billed amount for the encounter',
  added_by INT NOT NULL COMMENT 'User ID who originally created the record',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User ID who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_patient_record_archive_all_PR_id (PR_id),
  INDEX idx_patient_record_archive_all_patient_id (patient_id),
  INDEX idx_patient_record_archive_all_primary_physician_id (primary_physician_id),
  INDEX idx_patient_record_archive_all_ward_id (ward_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE patient_record_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  PR_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient record',
  previous_status INT NOT NULL COMMENT 'Status before this change (1=active,2=inactive,3=discharged,4=deleted)',
  new_status INT NOT NULL COMMENT 'Status after this change (1=active,2=inactive,3=discharged,4=deleted)',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User ID who performed the transition',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the transition',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT 'Record status (1=active,2=inactive,3=deleted)',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  INDEX idx_patient_record_life_cycle_all_PR_id (PR_id),
  INDEX idx_patient_record_life_cycle_all_changed_by (changed_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE patient_record_version_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=archived',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  PR_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the parent patient record',
  sort_order INT NOT NULL COMMENT 'Line‑item sequence within the version snapshot',
  field_name VARCHAR(50) NOT NULL COMMENT 'Name of the field being versioned',
  old_value VARCHAR(255) NULL COMMENT 'Previous value of the field',
  new_value VARCHAR(255) NULL COMMENT 'New value of the field after change',
  changed_by INT NOT NULL COMMENT 'User ID who made the change',
  changed_on DATETIME NOT NULL COMMENT 'When the change occurred',
  version_type VARCHAR(20) NOT NULL COMMENT 'CREATE, UPDATE or DELETE operation type',
  remarks TEXT NULL COMMENT 'Optional free‑form notes about the change',
  INDEX idx_patient_record_version_details_all_PR_id (PR_id),
  INDEX idx_patient_record_version_details_all_changed_by (changed_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE medication_order_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  medication_order_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. MO‑00001)',
  patient_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient',
  patient_ref_id INT NOT NULL COMMENT 'FK to patient_record_header_all.id',
  prescribing_doctor_id INT NOT NULL COMMENT 'User ID of the doctor who prescribed',
  prescribing_doctor_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  medication_code VARCHAR(30) NOT NULL COMMENT 'Standard medication code (e.g. ATC, RxNorm)',
  medication_name VARCHAR(255) NOT NULL COMMENT 'Full name of the medication',
  dosage_amount DECIMAL(10,2) NOT NULL COMMENT 'Dosage amount per administration',
  dosage_unit VARCHAR(20) NOT NULL COMMENT 'Unit of dosage (e.g. mg, ml, tablets)',
  frequency_per_day INT NOT NULL COMMENT 'Number of administrations per day',
  route VARCHAR(50) NOT NULL COMMENT 'Route of administration (e.g. oral, IV, IM)',
  start_date DATETIME NOT NULL COMMENT 'When the medication order becomes effective',
  end_date DATETIME NULL COMMENT 'When the medication order expires or is discontinued',
  instructions TEXT COMMENT 'Free‑text clinical instructions for the order',
  is_prn TINYINT NOT NULL DEFAULT 0 COMMENT 'Flag indicating PRN (as needed) order',
  total_items INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter: total medication items prescribed',
  count_items INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter: number of distinct medication items',
  last_item_added_on DATETIME NULL COMMENT 'Timestamp of the most recent item addition',
  added_by INT NOT NULL COMMENT 'User ID who created this order',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  status INT NOT NULL DEFAULT 1 COMMENT '1=Draft, 2=PendingApproval, 3=Approved, 4=Rejected, 5=Cancelled, 6=Deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_medication_order_header_all_patient_ref FOREIGN KEY (patient_ref_id) REFERENCES patient_record_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_medication_order_header_all_doctor_ref FOREIGN KEY (prescribing_doctor_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_medication_order_header_all_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_medication_order_header_all_patient_ref_id (patient_ref_id),
  INDEX idx_medication_order_header_all_doctor_ref_id (prescribing_doctor_ref_id),
  INDEX idx_medication_order_header_all_addedby_ref_id (added_by_ref_id),
  INDEX idx_medication_order_header_all_status (status),
  INDEX idx_medication_order_header_all_patient_id (patient_id),
  INDEX idx_medication_order_header_all_prescribing_doctor_id (prescribing_doctor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE medication_order_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  medication_order_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the medication order',
  patient_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient',
  prescribing_doctor_id INT NOT NULL COMMENT 'User ID of prescribing doctor',
  medication_code VARCHAR(30) NOT NULL COMMENT 'Medication code',
  medication_name VARCHAR(255) NOT NULL COMMENT 'Medication name',
  dosage_amount DECIMAL(10,2) NOT NULL COMMENT 'Dosage amount',
  dosage_unit VARCHAR(20) NOT NULL COMMENT 'Dosage unit',
  frequency_per_day INT NOT NULL COMMENT 'Frequency per day',
  route VARCHAR(50) NOT NULL COMMENT 'Administration route',
  start_date DATETIME NOT NULL COMMENT 'Order start datetime',
  end_date DATETIME NULL COMMENT 'Order end datetime',
  instructions TEXT COMMENT 'Clinical instructions',
  is_prn TINYINT NOT NULL DEFAULT 0 COMMENT 'PRN flag',
  total_items INT NOT NULL DEFAULT 0 COMMENT 'Total items at time of archive',
  count_items INT NOT NULL DEFAULT 0 COMMENT 'Item count at time of archive',
  last_item_added_on DATETIME NULL COMMENT 'Timestamp of last item addition at archive time',
  added_by INT NOT NULL COMMENT 'Creator user ID',
  status INT NOT NULL COMMENT 'Status at time of archive',
  created_on DATETIME NOT NULL COMMENT 'Original creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Original last modification timestamp',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User ID who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving',
  INDEX idx_medication_order_archive_all_medication_order_id (medication_order_id),
  INDEX idx_medication_order_archive_all_patient_id (patient_id),
  INDEX idx_medication_order_archive_all_prescribing_doctor_id (prescribing_doctor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE medication_order_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  medication_order_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the medication order',
  previous_status INT NOT NULL COMMENT 'Status before transition (1=Draft,2=PendingApproval,3=Approved,4=Rejected,5=Cancelled,6=Deleted)',
  new_status INT NOT NULL COMMENT 'Status after transition (same code set as previous_status)',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the change',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT 'Record status (1=active,2=inactive,3=deleted)',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  INDEX idx_medication_order_life_cycle_all_medication_order_id (medication_order_id),
  INDEX idx_medication_order_life_cycle_all_new_status (new_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE medication_order_status_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status_code INT NOT NULL COMMENT 'Numeric status code (e.g., 1,2,3...)',
  status_name VARCHAR(50) NOT NULL COMMENT 'Human‑readable name of the status',
  description VARCHAR(255) NULL COMMENT 'Detailed description of the status',
  is_final TINYINT NOT NULL DEFAULT 0 COMMENT '1 if this status is terminal (no further transitions)',
  sort_order INT NOT NULL DEFAULT 0 COMMENT 'Display order for UI dropdowns',
  created_by INT NOT NULL COMMENT 'User ID who created this lookup row',
  modified_by INT NOT NULL COMMENT 'User ID who last modified this lookup row',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active,2=inactive,3=deleted',
  CONSTRAINT uq_medication_order_status_all_code UNIQUE (status_code),
  INDEX idx_medication_order_status_all_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE lab_result_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=archived',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  lab_result_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. LR-00001)',
  patient_record_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient record',
  patient_record_ref_id INT NOT NULL COMMENT 'FK to patient_record_header_all.id',
  encounter_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient encounter',
  medication_order_id VARCHAR(20) NULL COMMENT 'Business ID of related medication order, if any',
  medication_order_ref_id INT NULL COMMENT 'FK to medication_order_header_all.id',
  test_code VARCHAR(20) NOT NULL COMMENT 'Lab test code (e.g. CBC, LFT)',
  test_name VARCHAR(100) NOT NULL COMMENT 'Descriptive name of the lab test',
  result_value VARCHAR(100) NOT NULL COMMENT 'Raw result as reported by the lab',
  result_numeric DECIMAL(10,2) NULL COMMENT 'Numeric representation of the result, if applicable',
  unit VARCHAR(20) NULL COMMENT 'Unit of measurement for numeric result',
  reference_range_low DECIMAL(10,2) NULL COMMENT 'Lower bound of reference range',
  reference_range_high DECIMAL(10,2) NULL COMMENT 'Upper bound of reference range',
  result_flag VARCHAR(20) NULL COMMENT 'Flag indicating result status (e.g. High, Low, Normal)',
  result_json JSON NULL COMMENT 'Structured JSON payload for complex result data',
  collected_on DATETIME NOT NULL COMMENT 'Date‑time when specimen was collected',
  reported_on DATETIME NOT NULL COMMENT 'Date‑time when result was reported',
  performed_by INT NOT NULL COMMENT 'User ID of the lab technician who performed the test',
  performed_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  added_by INT NOT NULL COMMENT 'User ID who created this lab result record',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  total_items INT NOT NULL DEFAULT 1 COMMENT 'Aggregate counter: total number of result items (usually 1)',
  count_abnormal INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter: number of abnormal findings in this result set',
  last_result_on DATETIME NOT NULL COMMENT 'Timestamp of the most recent result update',
  notes TEXT NULL COMMENT 'Additional clinical notes or comments',
  CONSTRAINT fk_lab_result_patient_record_ref FOREIGN KEY (patient_record_ref_id) REFERENCES patient_record_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_lab_result_med_order_ref FOREIGN KEY (medication_order_ref_id) REFERENCES medication_order_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_lab_result_performed_by_ref FOREIGN KEY (performed_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_lab_result_added_by_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_lab_result_header_all_patient_ref_id (patient_record_ref_id),
  INDEX idx_lab_result_header_all_med_order_ref_id (medication_order_ref_id),
  INDEX idx_lab_result_header_all_test_code (test_code),
  INDEX idx_lab_result_header_all_status (status),
  INDEX idx_lab_result_header_all_encounter_id (encounter_id),
  INDEX idx_lab_result_header_all_medication_order_id (medication_order_id),
  INDEX idx_lab_result_header_all_patient_record_id (patient_record_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE lab_result_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL COMMENT 'Historical status snapshot (mirrors source status)',
  created_on DATETIME NOT NULL COMMENT 'Original creation timestamp of the source record',
  modified_on DATETIME NOT NULL COMMENT 'Original last modification timestamp of the source record',
  lab_result_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the lab result',
  patient_record_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient record',
  encounter_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient encounter',
  medication_order_id VARCHAR(20) NULL COMMENT 'Business ID of related medication order',
  test_code VARCHAR(20) NOT NULL COMMENT 'Lab test code',
  test_name VARCHAR(100) NOT NULL COMMENT 'Lab test name',
  result_value VARCHAR(100) NOT NULL COMMENT 'Raw result value',
  result_numeric DECIMAL(10,2) NULL COMMENT 'Numeric result, if applicable',
  unit VARCHAR(20) NULL COMMENT 'Result unit',
  reference_range_low DECIMAL(10,2) NULL COMMENT 'Reference range low',
  reference_range_high DECIMAL(10,2) NULL COMMENT 'Reference range high',
  result_flag VARCHAR(20) NULL COMMENT 'Result flag (High/Low/Normal)',
  result_json JSON NULL COMMENT 'JSON payload of result',
  collected_on DATETIME NOT NULL COMMENT 'Specimen collection timestamp',
  reported_on DATETIME NOT NULL COMMENT 'Result reporting timestamp',
  performed_by INT NOT NULL COMMENT 'Lab technician user ID',
  added_by INT NOT NULL COMMENT 'User who originally added the record',
  total_items INT NOT NULL COMMENT 'Total items counter at time of archiving',
  count_abnormal INT NOT NULL COMMENT 'Abnormal count at time of archiving',
  last_result_on DATETIME NOT NULL COMMENT 'Timestamp of last result update',
  notes TEXT NULL COMMENT 'Clinical notes',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archiving',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_lab_result_archive_all_encounter_id (encounter_id),
  INDEX idx_lab_result_archive_all_lab_result_id (lab_result_id),
  INDEX idx_lab_result_archive_all_medication_order_id (medication_order_id),
  INDEX idx_lab_result_archive_all_patient_record_id (patient_record_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE lab_result_status_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Short code for status (e.g. PENDING, COMPLETED)',
  description VARCHAR(255) NOT NULL COMMENT 'Full description of the status',
  is_critical TINYINT NOT NULL DEFAULT 0 COMMENT '1=critical result, 0=non‑critical',
  notification_required TINYINT NOT NULL DEFAULT 0 COMMENT '1=notify clinician, 0=no notification',
  sort_order INT NOT NULL DEFAULT 0 COMMENT 'Display order for UI dropdowns',
  color_code VARCHAR(7) NULL COMMENT 'Hex color code for UI representation',
  allowed_transition VARCHAR(255) NULL COMMENT 'Comma‑separated list of status_codes allowed to transition from this state',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  added_by INT NOT NULL COMMENT 'User who added the status record',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  INDEX idx_lab_result_status_all_is_critical (is_critical)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE approval_task_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=revoked',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  medication_order_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the parent medication order',
  medication_order_ref_id INT NOT NULL COMMENT 'FK to medication_order_header_all.id',
  sort_order INT NOT NULL COMMENT 'Sequence number of this approval step',
  approver_id INT NOT NULL COMMENT 'User ID of the approver for this step',
  approver_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  approval_status INT NOT NULL DEFAULT 1 COMMENT '1=Pending, 2=Approved, 3=Rejected, 4=Escalated',
  approval_comment TEXT NULL COMMENT 'Approver comments for this step',
  approved_on DATETIME NULL COMMENT 'Timestamp when approval decision was made',
  reviewed_by INT NULL COMMENT 'User ID who reviewed the approval after decision',
  reviewed_by_ref_id INT NULL COMMENT 'FK to user_header_all.id',
  review_on DATETIME NULL COMMENT 'Timestamp of the review',
  added_by INT NOT NULL COMMENT 'User who created this approval task record',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  notes TEXT NULL COMMENT 'Additional notes for the approval step',
  CONSTRAINT fk_approval_task_med_order_ref FOREIGN KEY (medication_order_ref_id) REFERENCES medication_order_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_approval_task_approver_ref FOREIGN KEY (approver_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_approval_task_reviewed_by_ref FOREIGN KEY (reviewed_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_approval_task_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_approval_task_med_order_ref_id (medication_order_ref_id),
  INDEX idx_approval_task_approver_ref_id (approver_ref_id),
  INDEX idx_approval_task_status (approval_status),
  INDEX idx_approval_task_details_all_approver_id (approver_id),
  INDEX idx_approval_task_details_all_medication_order_id (medication_order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE approval_task_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  approval_task_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the approval task (e.g. ATK-00001)',
  approval_task_ref_id INT NOT NULL COMMENT 'FK to approval_task_details_all.id',
  previous_status INT NOT NULL COMMENT 'Previous state of the task (1=Pending,2=Approved,3=Rejected,4=Escalated,5=Cancelled)',
  new_status INT NOT NULL COMMENT 'New state of the task (1=Pending,2=Approved,3=Rejected,4=Escalated,5=Cancelled)',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User ID who performed the transition',
  changed_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp when the transition occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition (e.g., auto_escalation, manual_approval)',
  remarks TEXT NULL COMMENT 'Additional remarks or comments',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_approval_task_life_cycle_task_ref FOREIGN KEY (approval_task_ref_id) REFERENCES approval_task_details_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_approval_task_life_cycle_changedby_ref FOREIGN KEY (changed_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_approval_task_life_cycle_task_ref_id (approval_task_ref_id),
  INDEX idx_approval_task_life_cycle_previous_status (previous_status),
  INDEX idx_approval_task_life_cycle_new_status (new_status),
  INDEX idx_approval_task_life_cycle_all_approval_task_id (approval_task_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE approval_task_status_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status_code INT NOT NULL COMMENT '1=Pending,2=Approved,3=Rejected,4=Escalated,5=Cancelled',
  status_name VARCHAR(50) NOT NULL COMMENT 'Human‑readable name of the status',
  description TEXT NULL COMMENT 'Detailed description of what the status means',
  is_final TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=final state, 0=intermediate state',
  escalation_level INT NULL COMMENT 'Numeric level of escalation required (if any)',
  notify_role VARCHAR(50) NULL COMMENT 'System role to be notified when entering this status',
  requires_approval TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=requires explicit approval, 0=auto‑transition',
  auto_transition_to INT NULL COMMENT 'Status code to auto‑move to after timeout (if applicable)',
  timeout_minutes INT NULL COMMENT 'Minutes after which auto‑transition occurs',
  created_by INT NOT NULL COMMENT 'User ID who created this status record',
  modified_by INT NOT NULL COMMENT 'User ID who last modified this status record',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  INDEX idx_approval_task_status_all_status_code (status_code),
  INDEX idx_approval_task_status_all_is_final (is_final)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Security & RBAC  (6 tables)
-- ============================================================

CREATE TABLE role_definition_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=archived',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  role_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID for role (e.g. RD-00001)',
  role_name VARCHAR(100) NOT NULL COMMENT 'Descriptive name of the security role',
  role_description VARCHAR(500) NULL COMMENT 'Detailed description of role responsibilities',
  is_system_role TINYINT NOT NULL DEFAULT 0 COMMENT '1=system‑defined role, 0=custom role',
  department_id INT NULL COMMENT 'FK to department_header_all (if role scoped to a department)',
  department_ref_id INT NULL COMMENT 'FK to department_header_all.id',
  effective_date DATE NOT NULL COMMENT 'Date from which the role becomes effective',
  expiry_date DATE NULL COMMENT 'Date after which the role is no longer valid',
  total_permissions INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of permissions assigned to this role',
  total_users INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of users assigned to this role',
  last_permission_assigned_on DATETIME NULL COMMENT 'Timestamp of most recent permission assignment',
  last_user_assigned_on DATETIME NULL COMMENT 'Timestamp of most recent user assignment',
  added_by INT NOT NULL COMMENT 'User ID who created this role record',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  CONSTRAINT fk_roledefinition_department_ref FOREIGN KEY (department_ref_id) REFERENCES department_header_all(id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_roledefinition_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_roledefinition_department_ref_id (department_ref_id),
  INDEX idx_roledefinition_addedby_ref_id (added_by_ref_id),
  INDEX idx_roledefinition_department_id (department_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role_definition_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=archived',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  role_id VARCHAR(20) NOT NULL COMMENT 'Human‑readable business ID for role (e.g. RD-00001)',
  role_name VARCHAR(100) NOT NULL COMMENT 'Descriptive name of the security role',
  role_description VARCHAR(500) NULL COMMENT 'Detailed description of role responsibilities',
  is_system_role TINYINT NOT NULL DEFAULT 0 COMMENT '1=system‑defined role, 0=custom role',
  department_id INT NULL COMMENT 'FK to department_header_all (if role scoped to a department)',
  effective_date DATE NOT NULL COMMENT 'Date from which the role became effective',
  expiry_date DATE NULL COMMENT 'Date after which the role expired',
  total_permissions INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of permissions at time of archiving',
  total_users INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of users at time of archiving',
  last_permission_assigned_on DATETIME NULL COMMENT 'Timestamp of most recent permission assignment before archive',
  last_user_assigned_on DATETIME NULL COMMENT 'Timestamp of most recent user assignment before archive',
  added_by INT NOT NULL COMMENT 'User ID who originally created the role',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User ID who performed the archiving',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_role_definition_archive_all_department_id (department_id),
  INDEX idx_role_definition_archive_all_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE permission_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deprecated',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  permission_code VARCHAR(50) NOT NULL UNIQUE COMMENT 'Machine‑readable code (e.g. READ_PATIENT_RECORD)',
  permission_name VARCHAR(100) NOT NULL COMMENT 'Human‑readable name of the permission',
  permission_description VARCHAR(500) NULL COMMENT 'Detailed description of what the permission allows',
  module_name VARCHAR(100) NOT NULL COMMENT 'Application module to which this permission belongs (e.g. PatientCare, Billing)',
  is_sensitive TINYINT NOT NULL DEFAULT 0 COMMENT '1=permission grants access to sensitive data, 0=regular',
  created_by INT NOT NULL COMMENT 'User ID who created the permission record',
  created_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  modified_by INT NOT NULL COMMENT 'User ID who last modified the permission record',
  modified_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  CONSTRAINT fk_permission_createdby_ref FOREIGN KEY (created_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_permission_modifiedby_ref FOREIGN KEY (modified_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_permission_createdby_ref_id (created_by_ref_id),
  INDEX idx_permission_modifiedby_ref_id (modified_by_ref_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE rbac_store_configuration_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=revoked',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  role_id VARCHAR(20) NOT NULL COMMENT 'Business ID of role',
  role_ref_id INT NOT NULL COMMENT 'FK to role_definition_header_all.id',
  permission_id INT NOT NULL COMMENT 'ID of permission',
  permission_ref_id INT NOT NULL COMMENT 'FK to permission_all.id',
  entity_type VARCHAR(50) NOT NULL COMMENT 'Type of entity the mapping applies to (e.g. PATIENT_RECORD, LAB_RESULT)',
  entity_id VARCHAR(20) NULL COMMENT 'Specific entity identifier if mapping is scoped to a single entity',
  effective_from DATE NOT NULL COMMENT 'Date from which this mapping becomes effective',
  effective_to DATE NULL COMMENT 'Date after which this mapping is no longer effective',
  config_note VARCHAR(255) NULL COMMENT 'Additional notes or business rules for this mapping',
  updated_by INT NOT NULL COMMENT 'User ID who performed the latest update',
  updated_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  approved_by INT NOT NULL COMMENT 'User ID who approved the configuration change',
  approved_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  CONSTRAINT fk_rbac_role_ref FOREIGN KEY (role_ref_id) REFERENCES role_definition_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rbac_permission_ref FOREIGN KEY (permission_ref_id) REFERENCES permission_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rbac_updatedby_ref FOREIGN KEY (updated_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rbac_approvedby_ref FOREIGN KEY (approved_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_rbac_store_configuration_all_role_ref_id (role_ref_id),
  INDEX idx_rbac_store_configuration_all_permission_ref_id (permission_ref_id),
  INDEX idx_rbac_store_configuration_all_updated_by_ref_id (updated_by_ref_id),
  INDEX idx_rbac_store_configuration_all_approved_by_ref_id (approved_by_ref_id),
  INDEX idx_rbac_store_configuration_all_entity_type (entity_type),
  INDEX idx_rbac_store_configuration_all_entity_id (entity_id),
  INDEX idx_rbac_store_configuration_all_role_id (role_id),
  INDEX idx_rbac_store_configuration_all_permission_id (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE user_role_assignment_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=revoked',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  user_id VARCHAR(20) NOT NULL COMMENT 'Human‑readable business ID of the user (e.g. USR‑00001)',
  user_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  role_id VARCHAR(20) NOT NULL COMMENT 'Human‑readable business ID of the role (e.g. ROLE‑ADMIN)',
  role_ref_id INT NOT NULL COMMENT 'FK to role_definition_header_all.id',
  assigned_by INT NOT NULL COMMENT 'User ID who performed the assignment',
  assigned_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  assigned_on DATETIME NOT NULL COMMENT 'Timestamp when the role was assigned',
  assignment_reason VARCHAR(500) NULL COMMENT 'Reason for assigning this role to the user',
  expires_on DATETIME NULL COMMENT 'Optional expiry timestamp for temporary assignments',
  notes TEXT NULL COMMENT 'Additional free‑form notes about the assignment',
  is_primary TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=primary role for the user, 0=secondary/auxiliary',
  CONSTRAINT fk_user_role_assignment_user_ref FOREIGN KEY (user_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_user_role_assignment_role_ref FOREIGN KEY (role_ref_id) REFERENCES role_definition_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_user_role_assignment_assignedby_ref FOREIGN KEY (assigned_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_user_role_assignment_user_ref_id (user_ref_id),
  INDEX idx_user_role_assignment_role_ref_id (role_ref_id),
  INDEX idx_user_role_assignment_status (status),
  INDEX idx_user_role_assignment_user_id (user_id),
  INDEX idx_user_role_assignment_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE access_decision_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=recorded, 2=archived, 3=invalid',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY‑MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  requestor_user_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the user who initiated the request',
  requestor_user_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  target_user_id VARCHAR(20) NULL COMMENT 'Business ID of the user whose data is being accessed',
  target_user_ref_id INT NULL COMMENT 'FK to user_header_all.id',
  resource_type VARCHAR(50) NOT NULL COMMENT 'Type of resource accessed (e.g. PATIENT_RECORD, LAB_RESULT)',
  resource_id VARCHAR(30) NOT NULL COMMENT 'Business ID of the specific resource instance',
  action VARCHAR(30) NOT NULL COMMENT 'Requested action (e.g. READ, UPDATE, DELETE)',
  decision VARCHAR(10) NOT NULL COMMENT 'Result of RBAC evaluation: ALLOW or DENY',
  evaluated_permissions JSON NOT NULL COMMENT 'List of permissions evaluated during the decision',
  before_state JSON NULL COMMENT 'Snapshot of the resource state before the action (if applicable)',
  after_state JSON NULL COMMENT 'Snapshot of the resource state after the action (if applicable)',
  amount DECIMAL(10,2) NULL COMMENT 'Financial amount involved in the request, if any',
  added_by INT NOT NULL COMMENT 'User ID who logged this decision record',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  device_id VARCHAR(50) NOT NULL COMMENT 'Identifier of the device used for the request',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the requester',
  CONSTRAINT fk_access_decision_requestor_ref FOREIGN KEY (requestor_user_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_access_decision_target_ref FOREIGN KEY (target_user_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_access_decision_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_access_decision_month_year (month_year),
  INDEX idx_access_decision_requestor_user_ref_id (requestor_user_ref_id),
  INDEX idx_access_decision_target_user_ref_id (target_user_ref_id),
  INDEX idx_access_decision_resource (resource_type, resource_id),
  INDEX idx_access_decision_device_id (device_id),
  INDEX idx_access_decision_status (status),
  INDEX idx_access_decision_transaction_all_requestor_user_id (requestor_user_id),
  INDEX idx_access_decision_transaction_all_resource_id (resource_id),
  INDEX idx_access_decision_transaction_all_target_user_id (target_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Audit & Compliance  (4 tables)
-- ============================================================

CREATE TABLE audit_log_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  table_name VARCHAR(100) NOT NULL COMMENT 'Name of the table being audited',
  row_id VARCHAR(36) NOT NULL COMMENT 'Primary key of the audited row (UUID or business ID)',
  action VARCHAR(10) NOT NULL COMMENT 'INSERT|UPDATE|DELETE|READ',
  before_state JSON COMMENT 'JSON snapshot of the row before the operation',
  after_state JSON COMMENT 'JSON snapshot of the row after the operation',
  actor_user_id INT NOT NULL COMMENT 'User ID who performed the action',
  actor_user_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  device_id VARCHAR(50) NOT NULL COMMENT 'Identifier of the device used',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the requester',
  user_agent VARCHAR(255) NOT NULL COMMENT 'User‑agent string of the client',
  added_by INT NOT NULL COMMENT 'User ID who recorded this audit entry',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Financial amount involved, if any',
  CONSTRAINT fk_audit_log_transaction_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_audit_log_transaction_actor_ref FOREIGN KEY (actor_user_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_audit_log_transaction_month_year (month_year),
  INDEX idx_audit_log_transaction_table_name (table_name),
  INDEX idx_audit_log_transaction_actor_user_ref_id (actor_user_ref_id),
  INDEX idx_audit_log_transaction_all_actor_user_id (actor_user_id),
  INDEX idx_audit_log_transaction_all_device_id (device_id),
  INDEX idx_audit_log_transaction_all_row_id (row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_log_entry_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  audit_log_transaction_id INT NOT NULL COMMENT 'FK to parent audit_log_transaction_all',
  audit_log_transaction_ref_id INT NOT NULL COMMENT 'FK to audit_log_transaction_all.id',
  sort_order INT NOT NULL COMMENT 'Line‑item sequence within the audit transaction',
  field_name VARCHAR(100) NOT NULL COMMENT 'Name of the audited field',
  old_value VARCHAR(255) COMMENT 'Value before change',
  new_value VARCHAR(255) COMMENT 'Value after change',
  changed_by INT NOT NULL COMMENT 'User ID who caused the change',
  changed_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the change',
  CONSTRAINT fk_audit_log_entry_parent_ref FOREIGN KEY (audit_log_transaction_ref_id) REFERENCES audit_log_transaction_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_audit_log_entry_changedby_ref FOREIGN KEY (changed_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_audit_log_entry_audit_log_transaction_ref_id (audit_log_transaction_ref_id),
  INDEX idx_audit_log_entry_field_name (field_name),
  INDEX idx_audit_log_entry_details_all_audit_log_transaction_id (audit_log_transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_log_store_configuration_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  entity_type VARCHAR(50) NOT NULL COMMENT 'Type of entity the config applies to (e.g. PATIENT, LAB_RESULT)',
  entity_id VARCHAR(30) NOT NULL COMMENT 'Business ID of the entity',
  effective_from DATE NOT NULL COMMENT 'Configuration becomes effective on this date',
  effective_to DATE NOT NULL COMMENT 'Configuration expires on this date',
  retention_days INT NOT NULL COMMENT 'Number of days audit logs are retained',
  encryption_key_id VARCHAR(50) NOT NULL COMMENT 'Reference to encryption key for tamper‑evidence',
  updated_by INT NOT NULL COMMENT 'User ID who last updated this configuration',
  updated_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  approved_by INT NOT NULL COMMENT 'User ID who approved this configuration',
  approved_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  CONSTRAINT fk_audit_log_store_cfg_updated_by_ref FOREIGN KEY (updated_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_audit_log_store_cfg_approved_by_ref FOREIGN KEY (approved_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_audit_log_store_cfg_entity (entity_type, entity_id),
  INDEX idx_audit_log_store_cfg_effective (effective_from, effective_to),
  INDEX idx_audit_log_store_cfg_updated_by_ref_id (updated_by_ref_id),
  INDEX idx_audit_log_store_cfg_approved_by_ref_id (approved_by_ref_id),
  INDEX idx_audit_log_store_configuration_all_encryption_key_id (encryption_key_id),
  INDEX idx_audit_log_store_configuration_all_entity_id (entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE data_operation_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  operation_type VARCHAR(10) NOT NULL COMMENT 'READ|WRITE|UPDATE|DELETE',
  target_table VARCHAR(100) NOT NULL COMMENT 'Table on which the operation was performed',
  target_row_id VARCHAR(36) NOT NULL COMMENT 'Primary key of the target row',
  before_state JSON COMMENT 'JSON snapshot before the operation (if applicable)',
  after_state JSON COMMENT 'JSON snapshot after the operation (if applicable)',
  actor_user_id INT NOT NULL COMMENT 'User ID who performed the operation',
  actor_user_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  device_id VARCHAR(50) NOT NULL COMMENT 'Identifier of the device used',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the requester',
  user_agent VARCHAR(255) NOT NULL COMMENT 'User‑agent string of the client',
  added_by INT NOT NULL COMMENT 'User ID who recorded this data operation',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Financial amount involved, if any',
  CONSTRAINT fk_data_operation_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_data_operation_actor_ref FOREIGN KEY (actor_user_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_data_operation_month_year (month_year),
  INDEX idx_data_operation_target (target_table, target_row_id),
  INDEX idx_data_operation_actor_user_ref_id (actor_user_ref_id),
  INDEX idx_data_operation_transaction_all_actor_user_id (actor_user_id),
  INDEX idx_data_operation_transaction_all_device_id (device_id),
  INDEX idx_data_operation_transaction_all_target_row_id (target_row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Billing & Ledger  (4 tables)
-- ============================================================

CREATE TABLE charge_item_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  charge_item_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the charge item (e.g. CHG-00001)',
  patient_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the patient',
  patient_ref_id INT NOT NULL COMMENT 'FK to patient_record_header_all.id',
  admission_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the admission episode',
  admission_ref_id INT NOT NULL COMMENT 'FK to admission_header_all.id',
  service_code VARCHAR(30) NOT NULL COMMENT 'Code representing the billable service or product',
  service_description VARCHAR(255) NOT NULL COMMENT 'Human readable description of the service',
  quantity DECIMAL(10,2) NOT NULL DEFAULT 1.00 COMMENT 'Quantity of the service rendered',
  unit_price DECIMAL(10,2) NOT NULL COMMENT 'Price per unit of the service',
  total_amount DECIMAL(10,2) NOT NULL COMMENT 'Quantity * unit_price',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST rate applied',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST rate applied',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST rate applied (inter‑state)',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sort_order INT NOT NULL COMMENT 'Line number / sequence for ordering within the bill',
  added_by INT NOT NULL COMMENT 'User ID who created this charge item',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier from which the item was entered',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the client creating the record',
  CONSTRAINT fk_charge_item_patient_ref FOREIGN KEY (patient_ref_id) REFERENCES patient_record_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_charge_item_admission_ref FOREIGN KEY (admission_ref_id) REFERENCES admission_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_charge_item_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_charge_item_patient_ref_id (patient_ref_id),
  INDEX idx_charge_item_admission_ref_id (admission_ref_id),
  INDEX idx_charge_item_device_id (device_id),
  INDEX idx_charge_item_service_code (service_code),
  INDEX idx_charge_item_details_all_admission_id (admission_id),
  INDEX idx_charge_item_details_all_charge_item_id (charge_item_id),
  INDEX idx_charge_item_details_all_patient_id (patient_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_account_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=closed, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  la_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable Ledger Account ID (e.g. LA-00001)',
  account_number VARCHAR(100) NOT NULL COMMENT 'Unique account number in the chart of accounts',
  account_name VARCHAR(150) NOT NULL COMMENT 'Descriptive name of the ledger account',
  account_type VARCHAR(30) NOT NULL COMMENT 'Type of account (Asset, Liability, Equity, Revenue, Expense)',
  currency VARCHAR(3) NOT NULL DEFAULT 'INR' COMMENT 'Currency code (ISO 4217)',
  opening_balance DECIMAL(15,4) NOT NULL DEFAULT 0.0000 COMMENT 'Balance at the start of the accounting period',
  current_balance DECIMAL(15,4) NOT NULL DEFAULT 0.0000 COMMENT 'Running balance after latest transaction',
  parent_account_id VARCHAR(20) NULL COMMENT 'Business ID of parent ledger account for hierarchy',
  parent_account_ref_id INT NULL COMMENT 'FK to ledger_account_header_all.id',
  is_control_account TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=control account, 0=detail account',
  total_debits DECIMAL(15,4) NOT NULL DEFAULT 0.0000 COMMENT 'Aggregate sum of debit postings',
  total_credits DECIMAL(15,4) NOT NULL DEFAULT 0.0000 COMMENT 'Aggregate sum of credit postings',
  transaction_count INT NOT NULL DEFAULT 0 COMMENT 'Number of transactions posted to this account',
  last_transaction_on DATETIME NULL COMMENT 'Timestamp of the most recent transaction',
  added_by INT NOT NULL COMMENT 'User ID who created the ledger account',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  department_code VARCHAR(20) NOT NULL COMMENT 'Department to which the account belongs (e.g. CARD, RAD, PHARMA)',
  cost_center VARCHAR(20) NOT NULL COMMENT 'Cost centre identifier for internal accounting',
  is_active TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=account is active for posting, 0=inactive',
  CONSTRAINT fk_ledger_account_parent_ref FOREIGN KEY (parent_account_ref_id) REFERENCES ledger_account_header_all(id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_ledger_account_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_ledger_account_account_number (account_number),
  INDEX idx_ledger_account_parent_account_ref_id (parent_account_ref_id),
  INDEX idx_ledger_account_header_all_parent_account_id (parent_account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_account_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT COMMENT 'Status at time of archiving',
  created_on DATETIME COMMENT 'Original creation timestamp',
  modified_on DATETIME COMMENT 'Original last modification timestamp',
  la_id VARCHAR(20) COMMENT 'Ledger Account business ID',
  account_number VARCHAR(100) COMMENT 'Account number',
  account_name VARCHAR(150) COMMENT 'Account name',
  account_type VARCHAR(30) COMMENT 'Account type',
  currency VARCHAR(3) COMMENT 'Currency code',
  opening_balance DECIMAL(15,4) COMMENT 'Opening balance at archive time',
  current_balance DECIMAL(15,4) COMMENT 'Balance at archive time',
  parent_account_id VARCHAR(20) COMMENT 'Parent account business ID',
  is_control_account TINYINT(1) COMMENT 'Control account flag',
  total_debits DECIMAL(15,4) COMMENT 'Total debits till archive',
  total_credits DECIMAL(15,4) COMMENT 'Total credits till archive',
  transaction_count INT COMMENT 'Number of transactions till archive',
  last_transaction_on DATETIME COMMENT 'Timestamp of last transaction before archive',
  added_by INT COMMENT 'User who originally added the account',
  department_code VARCHAR(20) COMMENT 'Department code',
  cost_center VARCHAR(20) COMMENT 'Cost centre',
  is_active TINYINT(1) COMMENT 'Active flag at archive time',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archiving',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_ledger_account_archive_all_la_id (la_id),
  INDEX idx_ledger_account_archive_all_parent_account_id (parent_account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_transaction_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=posted, 2=failed, 3=reversed, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID (e.g. TRX-20230905-001)',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY‑MM for partitioning and analytics',
  debit_account_id VARCHAR(20) NOT NULL COMMENT 'Business ID of debit ledger account',
  debit_account_ref_id INT NOT NULL COMMENT 'FK to ledger_account_header_all.id',
  credit_account_id VARCHAR(20) NOT NULL COMMENT 'Business ID of credit ledger account',
  credit_account_ref_id INT NOT NULL COMMENT 'FK to ledger_account_header_all.id',
  amount DECIMAL(15,4) NOT NULL COMMENT 'Transaction amount (currency defined by accounts)',
  transaction_type VARCHAR(50) NOT NULL COMMENT 'Type of transaction (e.g. PATIENT_CHARGE, INSURANCE_PAYMENT, INVENTORY_ADJUST)',
  reference_id VARCHAR(30) NULL COMMENT 'External reference (e.g. invoice number, claim ID)',
  posting_date DATETIME NOT NULL COMMENT 'Date and time when transaction was posted to the ledger',
  description TEXT NULL COMMENT 'Narrative description of the transaction',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST rate applied to this transaction',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST rate applied to this transaction',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST rate applied (inter‑state)',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  before_balance_debit DECIMAL(15,4) NOT NULL COMMENT 'Debit account balance before posting',
  after_balance_debit DECIMAL(15,4) NOT NULL COMMENT 'Debit account balance after posting',
  before_balance_credit DECIMAL(15,4) NOT NULL COMMENT 'Credit account balance before posting',
  after_balance_credit DECIMAL(15,4) NOT NULL COMMENT 'Credit account balance after posting',
  added_by INT NOT NULL COMMENT 'User ID who initiated the transaction',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier from which transaction was created',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the client creating the transaction',
  CONSTRAINT fk_ledger_transaction_debit_account_ref FOREIGN KEY (debit_account_ref_id) REFERENCES ledger_account_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ledger_transaction_credit_account_ref FOREIGN KEY (credit_account_ref_id) REFERENCES ledger_account_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ledger_transaction_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_ledger_transaction_month_year (month_year),
  INDEX idx_ledger_transaction_debit_account_ref_id (debit_account_ref_id),
  INDEX idx_ledger_transaction_credit_account_ref_id (credit_account_ref_id),
  INDEX idx_ledger_transaction_device_id (device_id),
  INDEX idx_ledger_transaction_transaction_all_credit_account_id (credit_account_id),
  INDEX idx_ledger_transaction_transaction_all_debit_account_id (debit_account_id),
  INDEX idx_ledger_transaction_transaction_all_reference_id (reference_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Notification Engine  (2 tables)
-- ============================================================

CREATE TABLE notification_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  notification_type_code VARCHAR(20) NOT NULL COMMENT 'FK to notification_type_all.type_code',
  sender_user_id INT NOT NULL COMMENT 'User who triggered the notification',
  sender_user_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  recipient_user_id INT NOT NULL COMMENT 'User who receives the notification',
  recipient_user_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  patient_id VARCHAR(20) NOT NULL COMMENT 'Business ID of patient',
  patient_ref_id INT NOT NULL COMMENT 'FK to patient_record_header_all.id',
  old_status INT COMMENT 'Previous status value (if applicable)',
  new_status INT COMMENT 'New status value (if applicable)',
  amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Monetary amount related to the notification, if any',
  sgst_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'State GST amount, if financial',
  cgst_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Central GST amount, if financial',
  message_body TEXT NOT NULL COMMENT 'Full notification message content',
  added_by INT NOT NULL COMMENT 'User ID who created this record',
  added_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier from which notification was generated',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the source system',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  CONSTRAINT fk_notification_type FOREIGN KEY (notification_type_code) REFERENCES notification_type_all(type_code) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_notification_patient_ref FOREIGN KEY (patient_ref_id) REFERENCES patient_record_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_notification_sender_user_ref FOREIGN KEY (sender_user_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_notification_recipient_user_ref FOREIGN KEY (recipient_user_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_notification_addedby_ref FOREIGN KEY (added_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_notification_month_year (month_year),
  INDEX idx_notification_sender_user_ref_id (sender_user_ref_id),
  INDEX idx_notification_recipient_user_ref_id (recipient_user_ref_id),
  INDEX idx_notification_patient_ref_id (patient_ref_id),
  INDEX idx_notification_type_code (notification_type_code),
  INDEX idx_notification_transaction_all_device_id (device_id),
  INDEX idx_notification_transaction_all_patient_id (patient_id),
  INDEX idx_notification_transaction_all_recipient_user_id (recipient_user_id),
  INDEX idx_notification_transaction_all_sender_user_id (sender_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notification_type_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  type_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Business code for the notification type (e.g., CONFIRM, ALERT, BILL_UPD)',
  type_name VARCHAR(100) NOT NULL COMMENT 'Human‑readable name of the notification type',
  description TEXT COMMENT 'Detailed description of when this notification is used',
  email_template VARCHAR(100) COMMENT 'Name of the email template associated with this type',
  sms_template VARCHAR(100) COMMENT 'Name of the SMS template associated with this type',
  push_template VARCHAR(100) COMMENT 'Name of the push‑notification template',
  priority INT NOT NULL DEFAULT 5 COMMENT 'Priority level (1=highest, 10=lowest)',
  default_channel VARCHAR(20) NOT NULL COMMENT 'Default delivery channel (e.g., email, sms, push)',
  retention_days INT NOT NULL DEFAULT 30 COMMENT 'Number of days the notification is retained in the system',
  is_auditable INT NOT NULL DEFAULT 1 COMMENT '1=changes are audited, 0=not audited',
  requires_approval INT NOT NULL DEFAULT 0 COMMENT '1=requires approval workflow, 0=auto‑send',
  created_by INT NOT NULL COMMENT 'User ID who created this notification type',
  modified_by INT NOT NULL COMMENT 'User ID who last modified this notification type',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE lab_result_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  lab_result_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the lab result',
  lab_result_ref_id INT NOT NULL COMMENT 'FK to lab_result_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous status code',
  new_status INT NOT NULL COMMENT 'New status code',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User ID who performed the transition',
  changed_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  CONSTRAINT fk_lab_result_life_cycle_lab_result_ref FOREIGN KEY (lab_result_ref_id) REFERENCES lab_result_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_lab_result_life_cycle_changedby_ref FOREIGN KEY (changed_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_lab_result_life_cycle_lab_result_ref_id (lab_result_ref_id),
  INDEX idx_lab_result_life_cycle_previous_status (previous_status),
  INDEX idx_lab_result_life_cycle_new_status (new_status),
  INDEX idx_lab_result_life_cycle_all_lab_result_id (lab_result_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_account_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  ledger_account_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the ledger account',
  ledger_account_ref_id INT NOT NULL COMMENT 'FK to ledger_account_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous status code',
  new_status INT NOT NULL COMMENT 'New status code',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User ID who performed the transition',
  changed_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  CONSTRAINT fk_ledger_account_life_cycle_account_ref FOREIGN KEY (ledger_account_ref_id) REFERENCES ledger_account_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ledger_account_life_cycle_changedby_ref FOREIGN KEY (changed_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_ledger_account_life_cycle_account_ref_id (ledger_account_ref_id),
  INDEX idx_ledger_account_life_cycle_previous_status (previous_status),
  INDEX idx_ledger_account_life_cycle_new_status (new_status),
  INDEX idx_ledger_account_life_cycle_all_ledger_account_id (ledger_account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role_definition_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  role_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the role',
  role_ref_id INT NOT NULL COMMENT 'FK to role_definition_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous status code',
  new_status INT NOT NULL COMMENT 'New status code',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User ID who performed the transition',
  changed_by_ref_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  CONSTRAINT fk_role_definition_life_cycle_role_ref FOREIGN KEY (role_ref_id) REFERENCES role_definition_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_role_definition_life_cycle_changedby_ref FOREIGN KEY (changed_by_ref_id) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_role_definition_life_cycle_role_ref_id (role_ref_id),
  INDEX idx_role_definition_life_cycle_previous_status (previous_status),
  INDEX idx_role_definition_life_cycle_new_status (new_status),
  INDEX idx_role_definition_life_cycle_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
-- ============================================================
-- End of schema
-- ============================================================
