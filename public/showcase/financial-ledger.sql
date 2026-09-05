-- ============================================================
-- Project  : NBFC Accounting Ledger System
-- Generated: 2026-09-04 20:23:47
-- Engine   : AI DB Schema Generator
-- Rules    : 98 production rules applied
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
START TRANSACTION;

-- ============================================================
-- Project  : NBFC Accounting Ledger System
-- Generated: 2026-09-04 20:20:07
-- Modules  : 7
-- Tables   : 21
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
  ui_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID for the registry entry (e.g. UI‑00001)',
  entity_type VARCHAR(50) NOT NULL COMMENT 'Logical entity this ID sequence belongs to (e.g. USER, INVOICE, LOAN)',
  prefix VARCHAR(10) NOT NULL COMMENT 'Prefix used for generated business IDs (e.g. UI, INV, LN)',
  last_seq VARCHAR(15) NOT NULL DEFAULT '00000' COMMENT 'Last issued numeric sequence for this entity type',
  next_seq VARCHAR(15) NOT NULL DEFAULT '00001' COMMENT 'Next sequence to be issued',
  total_children INT NOT NULL DEFAULT 0 COMMENT 'Aggregate count of child records linked to this entity',
  count_active INT NOT NULL DEFAULT 0 COMMENT 'Running count of active child records',
  last_child_id VARCHAR(20) NULL COMMENT 'Business ID of the most recently created child record',
  domain_code VARCHAR(10) NOT NULL COMMENT 'Domain‑specific code (e.g. FIN, HR, LOG)',
  effective_from DATETIME NOT NULL COMMENT 'Date‑time from which this ID mapping is effective',
  effective_to DATETIME NULL COMMENT 'Date‑time until which this ID mapping is valid (NULL = indefinite)',
  is_reserved TINYINT NOT NULL DEFAULT 0 COMMENT 'Flag indicating the ID is reserved for future use',
  is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT 'Soft‑delete flag for the registry entry',
  notes VARCHAR(500) NULL COMMENT 'Free‑form notes or description',
  added_by INT NULL COMMENT 'User ID who created this registry record',
  parent_entity_id VARCHAR(20) NULL COMMENT 'Business ID of a parent entity, if hierarchical',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=reserved, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  INDEX idx_unique_id_header_all_entity_type (entity_type),
  INDEX idx_unique_id_header_all_prefix (prefix),
  INDEX idx_unique_id_header_all_last_child_id (last_child_id),
  INDEX idx_unique_id_header_all_parent_entity_id (parent_entity_id),
  INDEX idx_unique_id_header_all_added_by (added_by),
  CONSTRAINT fk_unique_id_header_all_added_by
    FOREIGN KEY (added_by) REFERENCES user_header_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE factory_reset_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  app_version VARCHAR(20) NOT NULL COMMENT 'Current application version string',
  maintenance_mode TINYINT NOT NULL DEFAULT 0 COMMENT '1=maintenance mode ON, 0=OFF',
  api_throttle_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=API throttling active, 0=disabled',
  feature_payment_gateway_enabled TINYINT NOT NULL DEFAULT 1 COMMENT 'Toggle for payment gateway integration',
  feature_gst_compliance_enabled TINYINT NOT NULL DEFAULT 1 COMMENT 'Toggle GST calculation enforcement',
  feature_loan_module_enabled TINYINT NOT NULL DEFAULT 1 COMMENT 'Toggle loan processing module',
  feature_reporting_enabled TINYINT NOT NULL DEFAULT 1 COMMENT 'Toggle generation of scheduled reports',
  feature_audit_logging_enabled TINYINT NOT NULL DEFAULT 1 COMMENT 'Toggle detailed audit logging',
  feature_bulk_import_enabled TINYINT NOT NULL DEFAULT 0 COMMENT 'Toggle bulk data import capability',
  feature_sms_notifications_enabled TINYINT NOT NULL DEFAULT 1 COMMENT 'Toggle SMS notification service',
  feature_email_notifications_enabled TINYINT NOT NULL DEFAULT 1 COMMENT 'Toggle Email notification service',
  max_concurrent_sessions INT NOT NULL DEFAULT 500 COMMENT 'Maximum allowed concurrent user sessions',
  default_session_timeout INT NOT NULL DEFAULT 1800 COMMENT 'Default session timeout in seconds',
  data_retention_days INT NOT NULL DEFAULT 365 COMMENT 'Number of days to retain transactional data',
  emergency_shutdown_flag TINYINT NOT NULL DEFAULT 0 COMMENT '1=Emergency shutdown activated, 0=normal operation',
  added_by INT NULL COMMENT 'User ID who last changed the configuration',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=locked',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  INDEX idx_factory_reset_all_app_version (app_version),
  INDEX idx_factory_reset_all_added_by (added_by),
  CONSTRAINT fk_factory_reset_all_added_by
    FOREIGN KEY (added_by) REFERENCES user_header_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Core Accounting  (6 tables)
-- ============================================================

CREATE TABLE journal_entry_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=posted, 5=reversed',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  source_account_id VARCHAR(20) NOT NULL COMMENT 'Business ID of source ledger account',
  destination_account_id VARCHAR(20) NOT NULL COMMENT 'Business ID of destination ledger account',
  transaction_date DATETIME NOT NULL COMMENT 'Date and time of the transaction',
  amount DECIMAL(10,2) NOT NULL COMMENT 'Transaction amount (debit = credit)',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  before_balance_source DECIMAL(12,2) NOT NULL COMMENT 'Source account balance before transaction',
  after_balance_source DECIMAL(12,2) NOT NULL COMMENT 'Source account balance after transaction',
  before_balance_destination DECIMAL(12,2) NOT NULL COMMENT 'Destination account balance before transaction',
  after_balance_destination DECIMAL(12,2) NOT NULL COMMENT 'Destination account balance after transaction',
  added_by INT NOT NULL COMMENT 'User ID who created this transaction',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier from which transaction originated',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the client',
  approval_1_by INT NULL COMMENT 'User ID who performed first approval',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT '1=approved, 2=rejected, 3=pending',
  batch_id VARCHAR(30) NULL COMMENT 'Batch identifier for settlement reconciliation',
  diff_amount DECIMAL(10,2) NOT NULL COMMENT 'Change from previous transaction amount, computed at insert',
  INDEX idx_journal_entry_transaction_all_month_year (month_year),
  INDEX idx_journal_entry_transaction_all_source_account_id (source_account_id),
  INDEX idx_journal_entry_transaction_all_destination_account_id (destination_account_id),
  INDEX idx_journal_entry_transaction_all_added_by (added_by),
  INDEX idx_journal_entry_transaction_all_device_id (device_id),
  INDEX idx_journal_entry_transaction_all_batch_id (batch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE journal_entry_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  journal_entry_id INT NULL COMMENT 'FK to journal_entry_transaction_all.id',
  previous_status INT NOT NULL COMMENT '1=active, 2=inactive, 3=deleted, 4=posted, 5=reversed',
  new_status INT NOT NULL COMMENT '1=active, 2=inactive, 3=deleted, 4=posted, 5=reversed',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who made the change',
  changed_on DATETIME NOT NULL COMMENT 'When the change occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  INDEX idx_journal_entry_life_cycle_all_journal_entry_id (journal_entry_id),
  CONSTRAINT fk_journal_entry_life_cycle_all_journal_entry_transaction_all
    FOREIGN KEY (journal_entry_id) REFERENCES journal_entry_transaction_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_account_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=closed, 4=blocked, 5=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  LA_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable ledger account ID (e.g. LA-00001)',
  account_name VARCHAR(150) NOT NULL COMMENT 'Descriptive name of the ledger account',
  account_type VARCHAR(30) NOT NULL COMMENT 'Type of account (Asset, Liability, Equity, Revenue, Expense)',
  currency VARCHAR(3) NOT NULL DEFAULT 'INR' COMMENT 'Currency code',
  opening_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Balance at the start of the accounting period',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after latest posting',
  total_debits DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Cumulative debit amount posted',
  total_credits DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Cumulative credit amount posted',
  total_transactions INT NOT NULL DEFAULT 0 COMMENT 'Number of transactions posted to this account',
  last_transaction_on DATETIME NULL COMMENT 'Timestamp of the most recent transaction',
  added_by INT NOT NULL COMMENT 'User ID who created the ledger account',
  parent_account_id VARCHAR(20) NULL COMMENT 'Business ID of parent ledger account, if hierarchical',
  is_cash_account TINYINT NOT NULL DEFAULT 0 COMMENT '1=Cash account, 0=Non‑cash',
  operational_status INT NOT NULL DEFAULT 1 COMMENT '1=available, 2=allocated, 3=suspended, 4=closed',
  deactivated_on DATETIME NULL COMMENT 'Timestamp when account was deactivated',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Default SGST rate for this account',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Default CGST rate for this account',
  igst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Default IGST rate for this account',
  INDEX idx_ledger_account_header_all_account_type (account_type),
  INDEX idx_ledger_account_header_all_currency (currency),
  INDEX idx_ledger_account_header_all_added_by (added_by),
  INDEX idx_ledger_account_header_all_parent_account_id (parent_account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_account_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL COMMENT 'Status at time of archive',
  created_on DATETIME NOT NULL COMMENT 'Original creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Original last modification timestamp',
  LA_id VARCHAR(20) NOT NULL COMMENT 'Ledger account business ID',
  account_name VARCHAR(150) NOT NULL COMMENT 'Descriptive name of the ledger account',
  account_type VARCHAR(30) NOT NULL COMMENT 'Type of account',
  currency VARCHAR(3) NOT NULL COMMENT 'Currency code',
  opening_balance DECIMAL(12,2) NOT NULL COMMENT 'Opening balance at time of archive',
  closing_balance DECIMAL(12,2) NOT NULL COMMENT 'Closing balance at time of archive',
  total_debits DECIMAL(12,2) NOT NULL COMMENT 'Cumulative debits at time of archive',
  total_credits DECIMAL(12,2) NOT NULL COMMENT 'Cumulative credits at time of archive',
  total_transactions INT NOT NULL COMMENT 'Number of transactions at time of archive',
  last_transaction_on DATETIME NULL COMMENT 'Timestamp of last transaction before archive',
  added_by INT NOT NULL COMMENT 'User who originally added the record',
  parent_account_id VARCHAR(20) NULL COMMENT 'Parent account ID at time of archive',
  is_cash_account TINYINT NOT NULL COMMENT 'Cash account flag',
  operational_status INT NOT NULL COMMENT 'Operational status at time of archive',
  deactivated_on DATETIME NULL COMMENT 'Deactivation timestamp if applicable',
  sgst_percentage DECIMAL(5,2) NOT NULL COMMENT 'SGST rate at time of archive',
  cgst_percentage DECIMAL(5,2) NOT NULL COMMENT 'CGST rate at time of archive',
  igst_percentage DECIMAL(5,2) NOT NULL COMMENT 'IGST rate at time of archive',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_ledger_account_archive_all_LA_id (LA_id),
  INDEX idx_ledger_account_archive_all_archived_on (archived_on),
  INDEX idx_ledger_account_archive_all_parent_account_id (parent_account_id),
  INDEX idx_ledger_account_archive_all_added_by (added_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE tax_line_item_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  tax_line_item_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID for this tax line item (e.g. TXL‑00001)',
  journal_entry_id INT NULL COMMENT 'FK to journal_entry_transaction_all.id',
  sort_order INT NOT NULL COMMENT 'Sequence number of the line within the journal entry',
  line_description VARCHAR(255) NOT NULL COMMENT 'Description of the tax line item',
  base_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Base amount on which tax is calculated',
  tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total tax amount for this line',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  igst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'IGST rate applied',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this tax line is posted',
  added_by INT NOT NULL COMMENT 'User ID who created this tax line item',
  approval_1_by INT NULL COMMENT 'User ID of first approver',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT 'Approval status: 1=approved, 2=rejected, 3=pending',
  INDEX idx_tax_line_item_details_all_journal_entry_id (journal_entry_id),
  CONSTRAINT fk_tax_line_item_details_all_journal_entry
    FOREIGN KEY (journal_entry_id) REFERENCES journal_entry_transaction_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tax_rate_master_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=retired',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  tax_rate_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID for tax rate (e.g. TAX‑00001)',
  jurisdiction_code VARCHAR(10) NOT NULL COMMENT 'Code representing state or union territory',
  jurisdiction_name VARCHAR(100) NOT NULL COMMENT 'Full name of the jurisdiction',
  product_service_category VARCHAR(100) NOT NULL COMMENT 'Category of product or service the rate applies to',
  effective_from DATE NOT NULL COMMENT 'Date from which this rate becomes effective',
  effective_to DATE NULL COMMENT 'Date until which this rate is valid (NULL = indefinite)',
  sgst_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST rate percentage',
  cgst_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST rate percentage',
  igst_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST rate percentage',
  tds_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Tax Deducted at Source rate percentage',
  is_interstate BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Indicates if rate is for inter‑state transactions',
  description VARCHAR(500) NULL COMMENT 'Optional free‑text description of the tax rate',
  added_by INT NOT NULL COMMENT 'User ID who added this tax rate record',
  last_reviewed_on DATETIME NULL COMMENT 'Timestamp of the last review of this rate',
  review_by INT NULL COMMENT 'User ID who performed the last review',
  INDEX idx_tax_rate_master_all_jurisdiction_code (jurisdiction_code),
  INDEX idx_tax_rate_master_all_product_service_category (product_service_category),
  INDEX idx_tax_rate_master_all_effective_from (effective_from)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Period Management  (4 tables)
-- ============================================================

CREATE TABLE period_close_request_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=pending, 2=approved, 3=rejected, 4=completed',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  branch_id INT NULL COMMENT 'Branch where period close is requested',
  request_by INT NOT NULL COMMENT 'User who initiated the close request',
  request_on DATETIME NOT NULL COMMENT 'Timestamp when request was made',
  approval_1_by INT NULL COMMENT 'First approver user ID',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT '1=approved, 2=rejected, 3=escalated',
  before_closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Closing balance before this request',
  after_closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Closing balance after this request',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount applicable to this request',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount applicable to this request',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount applicable to this request',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this transaction',
  added_by INT NOT NULL COMMENT 'User ID who added this record',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier from which request originated',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the requester',
  INDEX idx_period_close_request_month_year (month_year),
  INDEX idx_period_close_request_branch (branch_id),
  INDEX idx_period_close_request_added_by (added_by),
  INDEX idx_period_close_request_device_id (device_id),
  CONSTRAINT fk_period_close_request_branch
    FOREIGN KEY (branch_id) REFERENCES ledger_account_header_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE period_close_request_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  period_close_request_id VARCHAR(30) NULL COMMENT 'Business ID of the period close request (transaction_ref)',
  previous_status INT NOT NULL COMMENT '1=pending, 2=approved, 3=rejected, 4=completed – status before change',
  new_status INT NOT NULL COMMENT '1=pending, 2=approved, 3=rejected, 4=completed – status after change',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'When the status change occurred',
  trigger_event VARCHAR(100) NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  INDEX idx_lc_period_close_request_id (period_close_request_id),
  INDEX idx_lc_changed_by (changed_by),
  CONSTRAINT fk_lc_period_close_request
    FOREIGN KEY (period_close_request_id) REFERENCES period_close_request_transaction_all(transaction_ref)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE financial_report_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  report_header_id VARCHAR(30) NOT NULL COMMENT 'Business ID of the parent financial report (to be defined elsewhere)',
  branch_id INT NULL COMMENT 'Branch for which the report is generated',
  period_month_year VARCHAR(7) NOT NULL COMMENT 'Reporting period in YYYY‑MM',
  sort_order INT NOT NULL COMMENT 'Line item sequence within the report',
  account_code VARCHAR(20) NOT NULL COMMENT 'Chart of accounts code',
  account_name VARCHAR(100) NOT NULL COMMENT 'Account descriptive name',
  debit_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Debit amount for this line item',
  credit_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Credit amount for this line item',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount for this line item',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount for this line item',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount for this line item',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Closing balance after this line item',
  added_by INT NOT NULL COMMENT 'User who generated this report line',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier used for report generation',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the device',
  INDEX idx_fin_report_header (report_header_id),
  INDEX idx_fin_report_branch (branch_id),
  INDEX idx_fin_report_period (period_month_year),
  INDEX idx_fin_report_device_id (device_id),
  CONSTRAINT fk_fin_report_branch
    FOREIGN KEY (branch_id) REFERENCES ledger_account_header_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE consolidation_batch_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=scheduled, 2=running, 3=completed, 4=failed',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID for the batch',
  head_office_user_id INT NOT NULL COMMENT 'User who triggered the consolidation',
  batch_started_on DATETIME NOT NULL COMMENT 'Timestamp when batch started',
  batch_completed_on DATETIME NULL COMMENT 'Timestamp when batch finished',
  approval_1_by INT NULL COMMENT 'First approver for batch execution',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT '1=approved, 2=rejected',
  total_branches INT NOT NULL DEFAULT 0 COMMENT 'Number of branches included in this batch',
  total_debit DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Aggregate debit amount across all branches',
  total_credit DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Aggregate credit amount across all branches',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Aggregate SGST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Aggregate CGST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Aggregate IGST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Average SGST rate applied in batch',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Average CGST rate applied in batch',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after batch processing',
  added_by INT NOT NULL COMMENT 'User who recorded the batch entry',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier from which batch was initiated',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the initiator',
  INDEX idx_consolidation_month_year (month_year),
  INDEX idx_consolidation_added_by (added_by),
  INDEX idx_consolidation_head_office_user (head_office_user_id),
  INDEX idx_consolidation_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Audit Trail  (1 tables)
-- ============================================================

CREATE TABLE audit_log_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  parent_entity_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the parent entity (e.g. INV-00001)',
  parent_id INT NOT NULL COMMENT 'Surrogate key of the parent record',
  sort_order INT NOT NULL COMMENT 'Line item sequence within the audit log entry',
  action_type VARCHAR(20) NOT NULL COMMENT 'Type of action: CREATE, UPDATE, DELETE, APPROVE, POST, SYSTEM',
  action_by INT NOT NULL COMMENT 'User ID who performed the action',
  action_on DATETIME NOT NULL COMMENT 'Timestamp when the action occurred',
  description TEXT NULL COMMENT 'Human‑readable description of the action',
  reference_table VARCHAR(50) NULL COMMENT 'Name of the table the action relates to',
  reference_id VARCHAR(30) NULL COMMENT 'Business ID of the referenced record',
  old_value TEXT NULL COMMENT 'Serialized snapshot of the data before change',
  new_value TEXT NULL COMMENT 'Serialized snapshot of the data after change',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this action, if applicable',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount captured at action time',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount captured at action time',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount captured at action time',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied at action time',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied at action time',
  month_year VARCHAR(7) NOT NULL COMMENT 'Pre‑tagged YYYY‑MM for analytics partitioning',
  INDEX idx_audit_log_details_all_parent_entity_id (parent_entity_id),
  INDEX idx_audit_log_details_all_parent_id (parent_id),
  INDEX idx_audit_log_details_all_sort_order (sort_order),
  INDEX idx_audit_log_details_all_month_year (month_year),
  INDEX idx_audit_log_details_all_reference_id (reference_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- MODULE COMPLETE


-- ============================================================
-- MODULE: Notification & Alerting  (4 tables)
-- ============================================================

CREATE TABLE alert_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=archived, 4=failed',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  alert_type VARCHAR(50) NOT NULL COMMENT 'Type of alert (e.g., HIGH_VALUE_CHANGE, ACCOUNT_LOCK)',
  severity VARCHAR(20) NOT NULL COMMENT 'Severity level (e.g., INFO, WARN, CRITICAL)',
  party_from_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the initiator (e.g., EMP‑00001)',
  party_to_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the target (e.g., ACC‑00012)',
  before_value VARCHAR(255) COMMENT 'Value before change (JSON or plain text)',
  after_value VARCHAR(255) COMMENT 'Value after change (JSON or plain text)',
  amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Monetary amount related to the alert',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this alert event',
  added_by INT NULL COMMENT 'User ID who added the alert',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier from which the alert originated',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the source',
  approval_1_by INT NULL COMMENT 'User ID of first approver (if required)',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT 'Approval status code (1=approved, 2=rejected, 3=pending)',
  INDEX idx_alert_transaction_all_month_year (month_year),
  INDEX idx_alert_transaction_all_party_from_id (party_from_id),
  INDEX idx_alert_transaction_all_party_to_id (party_to_id),
  INDEX idx_alert_transaction_all_device_id (device_id),
  INDEX idx_alert_transaction_all_added_by (added_by),
  CONSTRAINT fk_alert_transaction_all_added_by
    FOREIGN KEY (added_by) REFERENCES factory_reset_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notification_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=queued, 2=sent, 3=delivered, 4=failed, 5=cancelled',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  alert_transaction_id VARCHAR(30) NULL COMMENT 'FK to alert_transaction_all.transaction_ref',
  sort_order INT NOT NULL COMMENT 'Sequence of notification attempts for the same alert',
  channel VARCHAR(20) NOT NULL COMMENT 'Delivery channel (EMAIL, SMS, PUSH, WHATSAPP)',
  recipient_user_id INT NOT NULL COMMENT 'User ID of the notification recipient',
  recipient_contact VARCHAR(100) NOT NULL COMMENT 'Contact detail (email address, phone number, device token)',
  message_subject VARCHAR(255) NULL COMMENT 'Subject line for email or push notification',
  message_body TEXT NOT NULL COMMENT 'Full message payload sent to the user',
  delivery_status VARCHAR(20) NOT NULL COMMENT 'Current delivery status (PENDING, SENT, DELIVERED, FAILED)',
  sent_on DATETIME NULL COMMENT 'Timestamp when the message was sent',
  delivered_on DATETIME NULL COMMENT 'Timestamp when the message was confirmed delivered',
  failed_reason VARCHAR(255) NULL COMMENT 'Reason for delivery failure, if any',
  added_by INT NULL COMMENT 'User ID who queued the notification',
  device_id VARCHAR(50) NULL COMMENT 'Device identifier used for sending',
  ip_address VARCHAR(45) NULL COMMENT 'IP address of the sending system',
  INDEX idx_notification_details_all_alert_transaction_id (alert_transaction_id),
  INDEX idx_notification_details_all_recipient_user_id (recipient_user_id),
  INDEX idx_notification_details_all_device_id (device_id),
  INDEX idx_notification_details_all_added_by (added_by),
  CONSTRAINT fk_notification_details_all_alert_transaction
    FOREIGN KEY (alert_transaction_id) REFERENCES alert_transaction_all(transaction_ref)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_notification_details_all_added_by
    FOREIGN KEY (added_by) REFERENCES factory_reset_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE message_template_configuration_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=archived',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  entity_type VARCHAR(50) NOT NULL COMMENT 'Entity or domain this template applies to (e.g., ALERT, PAYMENT, LOAN)',
  template_name VARCHAR(100) NOT NULL COMMENT 'Logical name of the template',
  subject_template VARCHAR(255) NOT NULL COMMENT 'Subject line with placeholders',
  body_template TEXT NOT NULL COMMENT 'Message body with placeholders',
  effective_from DATE NOT NULL COMMENT 'Date from which the template becomes effective',
  effective_to DATE NULL COMMENT 'Date after which the template is no longer effective',
  version_number INT NOT NULL DEFAULT 1 COMMENT 'Version of the template for audit',
  updated_by INT NULL COMMENT 'User ID who last updated the template',
  approved_by INT NULL COMMENT 'User ID who approved the template',
  INDEX idx_message_template_configuration_all_entity_type (entity_type),
  INDEX idx_message_template_configuration_all_template_name (template_name),
  INDEX idx_message_template_configuration_all_updated_by (updated_by),
  INDEX idx_message_template_configuration_all_approved_by (approved_by),
  CONSTRAINT fk_message_template_configuration_all_updated_by
    FOREIGN KEY (updated_by) REFERENCES factory_reset_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_message_template_configuration_all_approved_by
    FOREIGN KEY (approved_by) REFERENCES factory_reset_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE event_queue_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=queued, 2=processing, 3=completed, 4=failed, 5=dead_letter',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY‑MM for partitioning and analytics',
  event_type VARCHAR(50) NOT NULL COMMENT 'Type of system event (e.g., ALERT_GENERATED, PAYMENT_RECEIVED)',
  payload JSON NOT NULL COMMENT 'Event payload in JSON format',
  priority INT NOT NULL DEFAULT 5 COMMENT 'Processing priority (1=high, 10=low)',
  scheduled_on DATETIME NULL COMMENT 'When the event is scheduled to be processed',
  processed_on DATETIME NULL COMMENT 'Timestamp when processing finished',
  processed_by INT NULL COMMENT 'User or service ID that processed the event',
  retry_count INT NOT NULL DEFAULT 0 COMMENT 'Number of retry attempts',
  added_by INT NULL COMMENT 'User ID who enqueued the event',
  device_id VARCHAR(50) NOT NULL COMMENT 'Originating device identifier',
  ip_address VARCHAR(45) NOT NULL COMMENT 'Originating IP address',
  INDEX idx_event_queue_all_month_year (month_year),
  INDEX idx_event_queue_all_event_type (event_type),
  INDEX idx_event_queue_all_status (status),
  INDEX idx_event_queue_all_device_id (device_id),
  INDEX idx_event_queue_all_added_by (added_by),
  CONSTRAINT fk_event_queue_all_added_by
    FOREIGN KEY (added_by) REFERENCES factory_reset_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Security & RBAC  (3 tables)
-- ============================================================

CREATE TABLE user_session_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=expired, 4=terminated, 5=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  user_session_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID for the session (e.g. US-00001)',
  user_id INT NULL COMMENT 'FK to user_header_all – owner of the session',
  session_token VARCHAR(255) NOT NULL COMMENT 'Encrypted token representing the session',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address from which the session was created',
  device_type VARCHAR(50) NOT NULL COMMENT 'Type of device (e.g. WEB, MOBILE, TABLET)',
  login_time DATETIME NOT NULL COMMENT 'Timestamp when the user logged in',
  logout_time DATETIME NULL COMMENT 'Timestamp when the user logged out',
  last_activity_on DATETIME NOT NULL COMMENT 'Timestamp of the last activity in this session',
  role_ids JSON NOT NULL COMMENT 'JSON array of role IDs assigned to the session',
  permission_ids JSON NOT NULL COMMENT 'JSON array of permission IDs effective for the session',
  total_permission_checks INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of permission checks performed in this session',
  last_permission_check_on DATETIME NULL COMMENT 'Timestamp of the most recent permission check',
  failed_permission_checks INT NOT NULL DEFAULT 0 COMMENT 'Counter of failed permission checks in this session',
  session_status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=idle, 3=expired, 4=terminated',
  expiration_time DATETIME NOT NULL COMMENT 'Scheduled expiration timestamp for the session',
  is_impersonated TINYINT NOT NULL DEFAULT 0 COMMENT 'Flag indicating if the session is an impersonation (1=Yes,0=No)',
  impersonated_by INT NULL COMMENT 'User ID who initiated impersonation, if applicable',
  added_by INT NULL COMMENT 'User ID who created this session record',
  INDEX idx_user_session_header_all_user_id (user_id),
  INDEX idx_user_session_header_all_session_token (session_token),
  INDEX idx_user_session_header_all_status (status),
  INDEX idx_user_session_header_all_added_by (added_by),
  INDEX idx_user_session_header_all_impersonated_by (impersonated_by),
  CONSTRAINT fk_user_session_header_all_user
    FOREIGN KEY (user_id) REFERENCES user_header_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_user_session_header_all_added_by
    FOREIGN KEY (added_by) REFERENCES user_header_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_user_session_header_all_impersonated_by
    FOREIGN KEY (impersonated_by) REFERENCES user_header_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_session_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL COMMENT 'Status at time of archiving',
  created_on DATETIME NOT NULL COMMENT 'Original creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Original last modification timestamp',
  user_session_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the session',
  user_id INT NOT NULL COMMENT 'Owner user ID',
  session_token VARCHAR(255) NOT NULL COMMENT 'Session token',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the session',
  device_type VARCHAR(50) NOT NULL COMMENT 'Device type',
  login_time DATETIME NOT NULL COMMENT 'Login timestamp',
  logout_time DATETIME NULL COMMENT 'Logout timestamp',
  last_activity_on DATETIME NOT NULL COMMENT 'Last activity timestamp',
  role_ids JSON NOT NULL COMMENT 'Roles assigned (JSON)',
  permission_ids JSON NOT NULL COMMENT 'Permissions effective (JSON)',
  total_permission_checks INT NOT NULL COMMENT 'Total permission checks performed',
  last_permission_check_on DATETIME NULL COMMENT 'Timestamp of last permission check',
  failed_permission_checks INT NOT NULL COMMENT 'Failed permission checks count',
  session_status INT NOT NULL COMMENT 'Current session status',
  expiration_time DATETIME NOT NULL COMMENT 'Scheduled expiration',
  is_impersonated TINYINT NOT NULL COMMENT 'Impersonation flag',
  impersonated_by INT NULL COMMENT 'Impersonating user ID',
  added_by INT NOT NULL COMMENT 'Creator user ID',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this record',
  INDEX idx_user_session_archive_all_user_session_id (user_session_id),
  INDEX idx_user_session_archive_all_user_id (user_id),
  INDEX idx_user_session_archive_all_added_by (added_by),
  INDEX idx_user_session_archive_all_impersonated_by (impersonated_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE permission_check_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=recorded, 2=reviewed, 3=escalated',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  permission_check_id VARCHAR(20) NOT NULL COMMENT 'Business ID for this permission check event (e.g. PC-00001)',
  user_session_header_id INT NULL COMMENT 'FK to user_session_header_all – session in which the check occurred',
  user_session_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the parent user session',
  line_no INT NOT NULL COMMENT 'Sequence number of this detail line within the check',
  permission_code VARCHAR(50) NOT NULL COMMENT 'Code of the permission being evaluated',
  outcome ENUM('ALLOW','DENY') NOT NULL COMMENT 'Result of the permission evaluation',
  outcome_reason VARCHAR(255) NULL COMMENT 'Explanation for the outcome, if any',
  checked_on DATETIME NOT NULL COMMENT 'Timestamp when the permission was checked',
  checked_by INT NOT NULL COMMENT 'User ID that performed the check (system or admin)',
  source_ip VARCHAR(45) NOT NULL COMMENT 'IP address from which the check originated',
  user_agent VARCHAR(255) NOT NULL COMMENT 'User‑agent string of the client',
  additional_context TEXT NULL COMMENT 'Optional JSON or text with extra context',
  month_year VARCHAR(7) NOT NULL COMMENT 'Pre‑tagged YYYY‑MM for analytics partitioning',
  diff_outcome_flag TINYINT NOT NULL DEFAULT 0 COMMENT '1 if outcome differs from previous check for same permission',
  INDEX idx_permission_check_details_all_user_session_header_id (user_session_header_id),
  INDEX idx_permission_check_details_all_permission_code (permission_code),
  INDEX idx_permission_check_details_all_month_year (month_year),
  INDEX idx_permission_check_details_all_permission_check_id (permission_check_id),
  INDEX idx_permission_check_details_all_user_session_id (user_session_id),
  CONSTRAINT fk_permission_check_details_all_user_session_header_all
    FOREIGN KEY (user_session_header_id) REFERENCES user_session_header_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Approval Engine  (1 tables)
-- ============================================================

CREATE TABLE approvable_item_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=failed',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  approvable_type VARCHAR(50) NOT NULL COMMENT 'Type of underlying object (e.g. JOURNAL_ENTRY, PERIOD_CLOSE)',
  approvable_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the underlying object',
  initiator_id INT NOT NULL COMMENT 'User who initiated the transaction',
  initiator_role VARCHAR(30) NOT NULL COMMENT 'Role of the initiator (e.g. accountant, manager)',
  amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Primary monetary amount of the transaction',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this transaction',
  before_status INT NOT NULL COMMENT 'Status of the underlying object before this transaction',
  after_status INT NOT NULL COMMENT 'Status of the underlying object after this transaction',
  approval_1_by INT NULL COMMENT 'User ID who performed first‑level approval',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first‑level approval',
  approval_1_status INT NULL COMMENT '1=approved, 2=rejected, 3=escalated',
  approval_2_by INT NULL COMMENT 'User ID who performed second‑level approval',
  approval_2_on DATETIME NULL COMMENT 'Timestamp of second‑level approval',
  approval_2_status INT NULL COMMENT '1=approved, 2=rejected, 3=escalated',
  added_by INT NOT NULL COMMENT 'User ID who added this transaction record',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier from which the transaction originated',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the originating client',
  remarks TEXT NULL COMMENT 'Free‑form remarks or notes',
  INDEX idx_approvable_item_transaction_all_month_year (month_year),
  INDEX idx_approvable_item_transaction_all_approvable_id (approvable_id),
  INDEX idx_approvable_item_transaction_all_initiator_id (initiator_id),
  INDEX idx_approvable_item_transaction_all_added_by (added_by),
  INDEX idx_approvable_item_transaction_all_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE ledger_account_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  ledger_account_id INT NULL COMMENT 'Surrogate key of the ledger account',
  previous_status INT NOT NULL COMMENT 'Previous operational status',
  new_status INT NOT NULL COMMENT 'New operational status',
  changed_by INT NOT NULL COMMENT 'User who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the change',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Record modification timestamp',
  INDEX idx_ledger_account_life_cycle_all_ledger_account_id (ledger_account_id),
  CONSTRAINT fk_ledger_account_life_cycle_all_ledger_account
    FOREIGN KEY (ledger_account_id) REFERENCES ledger_account_header_all(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
-- ============================================================
-- End of schema
-- ============================================================
