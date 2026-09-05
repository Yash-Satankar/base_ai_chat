-- ============================================================
-- Project  : B2B Multi-Tenant SaaS Control Plane
-- Generated: 2026-09-05 10:07:56
-- Engine   : AI DB Schema Generator
-- Rules    : 98 production rules applied
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
START TRANSACTION;

-- ============================================================
-- Project  : B2B Multi-Tenant SaaS Control Plane
-- Generated: 2026-09-05 10:04:42
-- Modules  : 7
-- Tables   : 35
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
  table_name VARCHAR(100) NOT NULL COMMENT 'Table this ID sequence is for',
  id_for VARCHAR(50) NOT NULL COMMENT 'Entity this ID represents',
  prefix VARCHAR(20) NOT NULL COMMENT 'Business ID prefix (e.g. EMP, ORD, FLT)',
  last_id VARCHAR(15) NOT NULL DEFAULT '00000' COMMENT 'Last issued sequence number',
  business_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. UI‑00001)',
  domain_code VARCHAR(30) NOT NULL COMMENT 'Domain specific code for categorisation',
  effective_date DATETIME NOT NULL COMMENT 'Date from which this ID becomes active',
  expiry_date DATETIME NULL COMMENT 'Date after which this ID is no longer valid',
  amount_limit DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Maximum monetary amount allowed for this entity',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount associated with the entity',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount associated with the entity',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount associated with the entity',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST rate applied',
  total_child_count INT NOT NULL DEFAULT 0 COMMENT 'Aggregate count of child records linked to this entity',
  last_child_id VARCHAR(20) NULL COMMENT 'Business ID of the most recently created child record',
  added_by INT NOT NULL COMMENT 'User ID who created this registry entry',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=retired, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  INDEX idx_unique_id_header_all_table_name (table_name),
  INDEX idx_unique_id_header_all_id_for (id_for),
  INDEX idx_unique_id_header_all_added_by (added_by),
  INDEX idx_unique_id_header_all_last_child_id (last_child_id),
  CONSTRAINT fk_unique_id_header_all_added_by FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE factory_reset_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  app_version VARCHAR(20) NOT NULL COMMENT 'Current deployed application version',
  maintenance_mode TINYINT NOT NULL DEFAULT 0 COMMENT '1=maintenance mode ON, 0=OFF',
  api_throttle_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=API throttling active, 0=inactive',
  feature_x_enabled TINYINT NOT NULL DEFAULT 1 COMMENT 'Feature X toggle (1=enabled, 0=disabled)',
  feature_y_enabled TINYINT NOT NULL DEFAULT 0 COMMENT 'Feature Y toggle (1=enabled, 0=disabled)',
  max_concurrent_jobs INT NOT NULL DEFAULT 100 COMMENT 'Maximum number of concurrent background jobs allowed',
  default_currency VARCHAR(5) NOT NULL DEFAULT 'INR' COMMENT 'Default currency code for financial transactions',
  audit_retention_days INT NOT NULL DEFAULT 365 COMMENT 'Number of days audit logs are retained',
  password_policy_strength INT NOT NULL DEFAULT 3 COMMENT 'Password strength level (1=low … 5=high)',
  data_encryption_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '1=Data at rest encrypted, 0=not encrypted',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount used for platform‑wide calculations',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount used for platform‑wide calculations',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount used for platform‑wide calculations',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Default State GST rate',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Default Central GST rate',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Platform‑wide closing balance placeholder',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=archived, 4=deleted',
  added_by INT NOT NULL COMMENT 'User ID who created the singleton record',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  INDEX idx_factory_reset_all_added_by (added_by),
  CONSTRAINT fk_factory_reset_all_added_by FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY uk_factory_reset_singleton (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Tenant Management  (4 tables)
-- ============================================================

CREATE TABLE tenant_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  tenant_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. TEN-00001)',
  name VARCHAR(255) NOT NULL COMMENT 'Legal name of the tenant organization',
  domain VARCHAR(255) NOT NULL COMMENT 'Primary internet domain used by the tenant',
  contact_email VARCHAR(255) NOT NULL COMMENT 'Primary contact email address',
  contact_phone VARCHAR(50) NOT NULL COMMENT 'Primary contact phone number',
  address_line1 VARCHAR(255) NOT NULL COMMENT 'First line of mailing address',
  address_line2 VARCHAR(255) NULL COMMENT 'Second line of mailing address',
  city VARCHAR(100) NOT NULL COMMENT 'City of the tenant address',
  state VARCHAR(100) NOT NULL COMMENT 'State/Province of the tenant address',
  postal_code VARCHAR(20) NOT NULL COMMENT 'Postal/ZIP code',
  country VARCHAR(100) NOT NULL COMMENT 'Country of the tenant',
  registration_date DATE NOT NULL COMMENT 'Date when tenant was legally registered',
  plan_code VARCHAR(50) NOT NULL COMMENT 'Subscription plan code assigned to tenant',
  subscription_start DATE NOT NULL COMMENT 'Start date of current subscription period',
  subscription_end DATE NOT NULL COMMENT 'End date of current subscription period',
  total_users INT NOT NULL DEFAULT 0 COMMENT 'Aggregate count of user accounts belonging to tenant',
  total_data_stores INT NOT NULL DEFAULT 0 COMMENT 'Aggregate count of data stores allocated to tenant',
  last_data_store_id VARCHAR(20) NULL COMMENT 'Business ID of the most recently created data store for tenant',
  added_by INT NOT NULL COMMENT 'User ID who created this tenant record',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=suspended, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_tenant_header_all_user_header_all FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_tenant_header_all_name (name),
  INDEX idx_tenant_header_all_domain (domain),
  INDEX idx_tenant_header_all_status (status),
  INDEX idx_tenant_header_all_last_data_store_id (last_data_store_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenant_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key (archived copy)',
  tenant_id VARCHAR(20) COMMENT 'Business ID of tenant',
  name VARCHAR(255) COMMENT 'Legal name of the tenant organization',
  domain VARCHAR(255) COMMENT 'Primary internet domain used by the tenant',
  contact_email VARCHAR(255) COMMENT 'Primary contact email address',
  contact_phone VARCHAR(50) COMMENT 'Primary contact phone number',
  address_line1 VARCHAR(255) COMMENT 'First line of mailing address',
  address_line2 VARCHAR(255) COMMENT 'Second line of mailing address',
  city VARCHAR(100) COMMENT 'City of the tenant address',
  state VARCHAR(100) COMMENT 'State/Province of the tenant address',
  postal_code VARCHAR(20) COMMENT 'Postal/ZIP code',
  country VARCHAR(100) COMMENT 'Country of the tenant',
  registration_date DATE COMMENT 'Date when tenant was legally registered',
  plan_code VARCHAR(50) COMMENT 'Subscription plan code assigned to tenant',
  subscription_start DATE COMMENT 'Start date of current subscription period',
  subscription_end DATE COMMENT 'End date of current subscription period',
  total_users INT COMMENT 'Aggregate count of user accounts belonging to tenant',
  total_data_stores INT COMMENT 'Aggregate count of data stores allocated to tenant',
  last_data_store_id VARCHAR(20) COMMENT 'Business ID of the most recently created data store for tenant',
  added_by INT COMMENT 'User ID who created the original tenant record',
  status INT COMMENT 'Status at time of archiving (1=active, 2=inactive, 3=suspended, 4=deleted)',
  created_on DATETIME COMMENT 'Original record creation timestamp',
  modified_on DATETIME COMMENT 'Original last modification timestamp',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_tenant_archive_all_tenant_id (tenant_id),
  INDEX idx_tenant_archive_all_archived_on (archived_on),
  INDEX idx_tenant_archive_all_last_data_store_id (last_data_store_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE data_store_configuration_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  data_store_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the data store (generated from unique_id_header_all)',
  entity_type VARCHAR(50) NOT NULL COMMENT 'Type of entity the configuration applies to (e.g., DOCUMENTS, IMAGES)',
  storage_quota_gb DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Maximum storage quota allocated (GB)',
  retention_days INT NOT NULL DEFAULT 0 COMMENT 'Number of days data is retained before automatic purge',
  is_encrypted TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=encrypted at rest, 0=not encrypted',
  effective_from DATE NOT NULL COMMENT 'Date from which this configuration becomes effective',
  effective_to DATE NULL COMMENT 'Date after which this configuration expires (NULL = indefinite)',
  updated_by INT NOT NULL COMMENT 'User ID who last updated this configuration',
  approved_by INT NOT NULL COMMENT 'User ID who approved the configuration change',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=revoked',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_data_store_configuration_all_tenant_header_all FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_data_store_configuration_all_tenant_id (tenant_id),
  INDEX idx_data_store_configuration_all_data_store_id (data_store_id),
  INDEX idx_data_store_configuration_all_entity_type (entity_type),
  INDEX idx_data_store_configuration_all_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE configuration_configuration_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  feature_name VARCHAR(100) NOT NULL COMMENT 'Name of the feature toggle or setting',
  is_enabled TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=feature enabled, 0=disabled',
  limit_value INT NULL COMMENT 'Numeric limit associated with the feature (e.g., max API calls)',
  effective_from DATE NOT NULL COMMENT 'Date from which this configuration becomes effective',
  effective_to DATE NULL COMMENT 'Date after which this configuration expires (NULL = indefinite)',
  updated_by INT NOT NULL COMMENT 'User ID who last updated this configuration',
  approved_by INT NOT NULL COMMENT 'User ID who approved the configuration change',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deprecated',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_configuration_configuration_all_tenant_header_all FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_configuration_configuration_all_tenant_id (tenant_id),
  INDEX idx_configuration_configuration_all_feature_name (feature_name),
  INDEX idx_configuration_configuration_all_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: User & Identity  (7 tables)
-- ============================================================

CREATE TABLE user_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=locked, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  user_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human-readable business ID (e.g. U-00001)',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all',
  added_by INT NOT NULL COMMENT 'User ID who created this record',
  first_name VARCHAR(100) NOT NULL COMMENT 'User first name',
  last_name VARCHAR(100) NOT NULL COMMENT 'User last name',
  email VARCHAR(255) NOT NULL UNIQUE COMMENT 'User email address (login)',
  phone VARCHAR(20) COMMENT 'Contact phone number',
  role VARCHAR(50) NOT NULL COMMENT 'Application role (e.g. admin, manager, user)',
  is_admin TINYINT NOT NULL DEFAULT 0 COMMENT 'Flag indicating tenant administrator (1=yes,0=no)',
  password_hash VARCHAR(255) NOT NULL COMMENT 'Hashed password',
  password_last_changed_on DATETIME NOT NULL COMMENT 'When password was last changed',
  last_login_on DATETIME COMMENT 'Timestamp of last successful login',
  failed_login_count INT NOT NULL DEFAULT 0 COMMENT 'Consecutive failed login attempts',
  total_login_count INT NOT NULL DEFAULT 0 COMMENT 'Cumulative successful logins',
  wallet_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Current wallet balance for the user',
  total_invitations_sent INT NOT NULL DEFAULT 0 COMMENT 'Number of invitations this user has sent',
  total_api_keys INT NOT NULL DEFAULT 0 COMMENT 'Number of API keys owned by the user',
  last_invitation_sent_on DATETIME COMMENT 'When the last invitation was sent',
  address_line1 VARCHAR(255) COMMENT 'Primary address line',
  city VARCHAR(100) COMMENT 'City',
  state VARCHAR(100) COMMENT 'State / Province',
  country VARCHAR(100) COMMENT 'Country',
  zip_code VARCHAR(20) COMMENT 'Postal code',
  CONSTRAINT fk_user_header_all_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_user_header_all_addedby FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_user_header_all_tenant_id (tenant_id),
  INDEX idx_user_header_all_added_by (added_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Surrogate key from source (not PK in archive)',
  status INT COMMENT 'Status at time of archive',
  created_on DATETIME COMMENT 'Original creation timestamp',
  modified_on DATETIME COMMENT 'Original modification timestamp',
  user_id VARCHAR(20) COMMENT 'Business ID of the user',
  tenant_id INT COMMENT 'Tenant reference',
  added_by INT COMMENT 'Creator user ID',
  first_name VARCHAR(100) COMMENT 'User first name',
  last_name VARCHAR(100) COMMENT 'User last name',
  email VARCHAR(255) COMMENT 'User email address',
  phone VARCHAR(20) COMMENT 'Contact phone number',
  role VARCHAR(50) COMMENT 'Application role',
  is_admin TINYINT COMMENT 'Tenant administrator flag',
  password_hash VARCHAR(255) COMMENT 'Hashed password',
  password_last_changed_on DATETIME COMMENT 'Password last changed timestamp',
  last_login_on DATETIME COMMENT 'Last successful login timestamp',
  failed_login_count INT COMMENT 'Failed login attempts count',
  total_login_count INT COMMENT 'Total successful logins',
  wallet_balance DECIMAL(12,2) COMMENT 'Wallet balance at archive time',
  total_invitations_sent INT COMMENT 'Invitations sent count at archive time',
  total_api_keys INT COMMENT 'API keys count at archive time',
  last_invitation_sent_on DATETIME COMMENT 'Timestamp of last invitation sent',
  address_line1 VARCHAR(255) COMMENT 'Primary address line',
  city VARCHAR(100) COMMENT 'City',
  state VARCHAR(100) COMMENT 'State / Province',
  country VARCHAR(100) COMMENT 'Country',
  zip_code VARCHAR(20) COMMENT 'Postal code',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archive',
  archive_reason VARCHAR(255) COMMENT 'Reason for archiving this version',
  INDEX idx_user_archive_all_tenant_id (tenant_id),
  INDEX idx_user_archive_all_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_invitation_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=sent, 2=accepted, 3=expired, 4=revoked, 5=failed',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human-readable transaction ID',
  invitation_id VARCHAR(20) NOT NULL COMMENT 'Business ID for this invitation',
  inviter_user_id INT NOT NULL COMMENT 'User who sent the invitation',
  invitee_email VARCHAR(255) NOT NULL COMMENT 'Email of the prospective user',
  role_assigned VARCHAR(50) NOT NULL COMMENT 'Role to be granted upon acceptance',
  token VARCHAR(100) NOT NULL COMMENT 'Activation token sent to invitee',
  token_expires_on DATETIME NOT NULL COMMENT 'When the activation token expires',
  invitation_sent_on DATETIME NOT NULL COMMENT 'Timestamp when invitation was sent',
  invitation_accepted_on DATETIME COMMENT 'Timestamp when invitation was accepted',
  approval_1_by INT COMMENT 'User ID who performed first approval (if any)',
  approval_1_on DATETIME COMMENT 'Timestamp of first approval',
  approval_1_status INT COMMENT 'Status after first approval (1=approved,2=rejected)',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this transaction',
  added_by INT NOT NULL COMMENT 'User who recorded this transaction',
  device_id VARCHAR(50) COMMENT 'Device identifier from which action originated',
  ip_address VARCHAR(45) COMMENT 'IP address of the requester',
  CONSTRAINT fk_user_invitation_tx_inviter FOREIGN KEY (inviter_user_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_user_invitation_tx_addedby FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_user_invitation_tx_month_year (month_year),
  INDEX idx_user_invitation_tx_inviter_user_id (inviter_user_id),
  INDEX idx_user_invitation_tx_invitation_id (invitation_id),
  INDEX idx_user_invitation_tx_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_invitation_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  invitation_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the invitation',
  previous_status INT NOT NULL COMMENT '1=sent, 2=accepted, 3=expired, 4=revoked, 5=failed',
  new_status INT NOT NULL COMMENT '1=sent, 2=accepted, 3=expired, 4=revoked, 5=failed',
  reason VARCHAR(500) COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'When the change occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT COMMENT 'Additional remarks',
  CONSTRAINT fk_user_inv_lc_changedby FOREIGN KEY (changed_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_user_inv_lc_invitation_id (invitation_id),
  INDEX idx_user_inv_lc_changedby (changed_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE api_key_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=revoked, 3=expired, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  user_id INT NOT NULL COMMENT 'FK to user_header_all.id – owner of the API key',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id – tenant context for the key',
  sort_order INT NOT NULL COMMENT 'Line number / sequence for ordering multiple keys per user',
  api_key VARCHAR(64) NOT NULL UNIQUE COMMENT 'Public API key identifier',
  secret_hash VARCHAR(255) NOT NULL COMMENT 'Hashed secret used for HMAC verification',
  expires_on DATETIME NOT NULL COMMENT 'Expiration timestamp of the API key',
  is_active TINYINT NOT NULL DEFAULT 1 COMMENT '1=currently usable, 0=inactive',
  usage_counter BIGINT NOT NULL DEFAULT 0 COMMENT 'Number of successful calls made with this key',
  last_used_on DATETIME NULL COMMENT 'Timestamp of the most recent successful use',
  created_by INT NOT NULL COMMENT 'User ID who created this API key (FK to user_header_all.id)',
  month_year VARCHAR(7) NOT NULL COMMENT 'Pre‑tagged YYYY‑MM for analytics partitioning',
  CONSTRAINT fk_api_key_details_all_user FOREIGN KEY (user_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_api_key_details_all_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_api_key_details_all_user_id (user_id),
  INDEX idx_api_key_details_all_tenant_id (tenant_id),
  INDEX idx_api_key_details_all_month_year (month_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenant_administrator_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=revoked, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  ta_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID for tenant administrator (e.g. TA00001)',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id – tenant to which the admin belongs',
  user_id INT NOT NULL COMMENT 'FK to user_header_all.id – user granted admin role',
  role_code VARCHAR(30) NOT NULL COMMENT 'Code representing admin role level (e.g. SUPER, MANAGER, AUDITOR)',
  assigned_on DATETIME NOT NULL COMMENT 'Timestamp when admin rights were granted',
  revoked_on DATETIME NULL COMMENT 'Timestamp when admin rights were revoked, if any',
  is_primary TINYINT NOT NULL DEFAULT 0 COMMENT '1=primary admin for tenant, 0=secondary',
  total_api_keys INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of API keys issued to this admin',
  last_api_key_on DATETIME NULL COMMENT 'Timestamp of the most recent API key issuance',
  total_sessions INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of login sessions for this admin',
  last_login_on DATETIME NULL COMMENT 'Timestamp of the most recent successful login',
  notes VARCHAR(500) NULL COMMENT 'Free‑form notes about the admin assignment',
  added_by INT NOT NULL COMMENT 'User ID who created this admin record (FK to user_header_all.id)',
  CONSTRAINT fk_tenant_admin_header_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tenant_admin_header_user FOREIGN KEY (user_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tenant_admin_header_addedby FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_tenant_admin_header_tenant_id (tenant_id),
  INDEX idx_tenant_admin_header_user_id (user_id),
  INDEX idx_tenant_admin_header_added_by (added_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenant_administrator_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key (mirrored from header)',
  status INT COMMENT 'Status at time of archiving',
  created_on DATETIME COMMENT 'Original creation timestamp',
  modified_on DATETIME COMMENT 'Original last modification timestamp',
  ta_id VARCHAR(20) COMMENT 'Business ID of the tenant administrator',
  tenant_id INT COMMENT 'Tenant reference (mirrored)',
  user_id INT COMMENT 'User reference (mirrored)',
  role_code VARCHAR(30) COMMENT 'Role code at time of archiving',
  assigned_on DATETIME COMMENT 'When admin rights were originally granted',
  revoked_on DATETIME COMMENT 'When admin rights were revoked, if any',
  is_primary TINYINT COMMENT 'Primary admin flag at time of archiving',
  total_api_keys INT COMMENT 'API key count at time of archiving',
  last_api_key_on DATETIME COMMENT 'Most recent API key issuance timestamp',
  total_sessions INT COMMENT 'Session count at time of archiving',
  last_login_on DATETIME COMMENT 'Most recent login timestamp',
  notes VARCHAR(500) COMMENT 'Archived notes',
  added_by INT COMMENT 'User who originally added the record',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archival',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_tenant_administrator_archive_all_ta_id (ta_id),
  INDEX idx_tenant_administrator_archive_all_tenant_id (tenant_id),
  INDEX idx_tenant_administrator_archive_all_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- MODULE COMPLETE


-- ============================================================
-- MODULE: RBAC Engine  (3 tables)
-- ============================================================

CREATE TABLE role_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  role_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. ROL‑00001)',
  role_name VARCHAR(50) NOT NULL COMMENT 'Descriptive name of the role',
  role_description VARCHAR(255) NOT NULL COMMENT 'Full description of role responsibilities',
  role_scope VARCHAR(30) NOT NULL COMMENT 'Scope of role applicability (e.g. GLOBAL, TENANT, DEPARTMENT)',
  permission_codes VARCHAR(500) NOT NULL COMMENT 'Comma‑separated list of permission codes assigned to this role',
  is_default TINYINT NOT NULL DEFAULT 0 COMMENT '1=default role for new users, 0=non‑default',
  max_user_assignments INT NOT NULL DEFAULT 0 COMMENT 'Maximum number of users that can be assigned this role (0 = unlimited)',
  effective_from DATETIME NOT NULL COMMENT 'Date‑time when role becomes active',
  effective_to DATETIME NULL COMMENT 'Date‑time when role expires (NULL = indefinite)',
  total_user_assignments INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of total user assignments to this role',
  last_assigned_on DATETIME NULL COMMENT 'Timestamp of most recent user assignment',
  added_by INT NOT NULL COMMENT 'User ID who created this role record',
  tenant_id INT NOT NULL COMMENT 'Tenant to which this role belongs',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=archived',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  INDEX idx_role_header_all_role_name (role_name),
  INDEX idx_role_header_all_tenant_id (tenant_id),
  CONSTRAINT fk_role_header_all_added_by FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_role_header_all_tenant_id FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Surrogate key (mirrored from source)',
  role_id VARCHAR(20) COMMENT 'Business ID of the role',
  role_name VARCHAR(50) COMMENT 'Descriptive name of the role',
  role_description VARCHAR(255) COMMENT 'Full description of role responsibilities',
  role_scope VARCHAR(30) COMMENT 'Scope of role applicability',
  permission_codes VARCHAR(500) COMMENT 'Comma‑separated list of permission codes',
  is_default TINYINT COMMENT '1=default role, 0=non‑default',
  max_user_assignments INT COMMENT 'Maximum allowed user assignments',
  effective_from DATETIME COMMENT 'Activation timestamp',
  effective_to DATETIME COMMENT 'Expiration timestamp',
  total_user_assignments INT COMMENT 'Aggregate counter of assignments',
  last_assigned_on DATETIME COMMENT 'Most recent assignment timestamp',
  added_by INT COMMENT 'Creator user ID',
  tenant_id INT COMMENT 'Owning tenant ID',
  status INT COMMENT 'Status at time of archiving',
  created_on DATETIME COMMENT 'Original creation timestamp',
  modified_on DATETIME COMMENT 'Original modification timestamp',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_role_archive_all_role_id (role_id),
  INDEX idx_role_archive_all_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role_assignment_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  assignment_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID for the assignment (e.g. ASS‑00001)',
  user_id INT NOT NULL COMMENT 'User to which the role is assigned',
  role_id INT NOT NULL COMMENT 'Role being assigned',
  tenant_id INT NOT NULL COMMENT 'Tenant context of the assignment',
  assigned_on DATETIME NOT NULL COMMENT 'Timestamp when assignment became effective',
  assigned_by INT NOT NULL COMMENT 'User who performed the assignment',
  expires_on DATETIME NULL COMMENT 'Optional expiration timestamp for the assignment',
  assignment_status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=revoked, 3=expired, 4=pending',
  notes VARCHAR(255) NULL COMMENT 'Free‑form notes about the assignment',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  INDEX idx_role_assignment_all_user_id (user_id),
  INDEX idx_role_assignment_all_role_id (role_id),
  INDEX idx_role_assignment_all_tenant_id (tenant_id),
  INDEX idx_role_assignment_all_assigned_by (assigned_by),
  CONSTRAINT fk_role_assignment_all_user_id FOREIGN KEY (user_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_role_assignment_all_role_id FOREIGN KEY (role_id) REFERENCES role_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_role_assignment_all_tenant_id FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_role_assignment_all_assigned_by FOREIGN KEY (assigned_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Subscription & Billing  (11 tables)
-- ============================================================

CREATE TABLE subscription_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=suspended, 3=cancelled, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  subscription_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. SUB-00001)',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  plan_id INT NOT NULL COMMENT 'FK to plan_header_all (plan definition)',
  billing_cycle VARCHAR(20) NOT NULL COMMENT 'e.g. monthly, yearly',
  start_date DATE NOT NULL COMMENT 'Subscription start date',
  end_date DATE NULL COMMENT 'Subscription end date (null if ongoing)',
  next_renewal_date DATE NOT NULL COMMENT 'Next scheduled renewal date',
  currency_code CHAR(3) NOT NULL DEFAULT 'INR' COMMENT 'ISO currency code',
  base_amount DECIMAL(10,2) NOT NULL COMMENT 'Base subscription amount before taxes',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  igst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'IGST rate applied',
  total_usage BIGINT NOT NULL DEFAULT 0 COMMENT 'Aggregated usage units for the subscription',
  total_invoices INT NOT NULL DEFAULT 0 COMMENT 'Count of invoices generated for this subscription',
  last_invoice_on DATETIME NULL COMMENT 'Timestamp of the most recent invoice',
  added_by INT NOT NULL COMMENT 'User ID who created this subscription',
  CONSTRAINT fk_subscription_header_all_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_subscription_header_all_user FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_subscription_header_all_tenant (tenant_id),
  INDEX idx_subscription_header_all_plan (plan_id),
  INDEX idx_subscription_header_all_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subscription_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Surrogate key from source (not PK here)',
  status INT COMMENT 'Status at time of archive',
  created_on DATETIME COMMENT 'Original creation timestamp',
  modified_on DATETIME COMMENT 'Original last modification timestamp',
  subscription_id VARCHAR(20) COMMENT 'Business ID',
  tenant_id INT COMMENT 'Tenant reference',
  plan_id INT COMMENT 'Plan reference',
  billing_cycle VARCHAR(20) COMMENT 'Billing cycle type',
  start_date DATE COMMENT 'Subscription start date',
  end_date DATE COMMENT 'Subscription end date',
  next_renewal_date DATE COMMENT 'Next renewal date',
  currency_code CHAR(3) COMMENT 'Currency code',
  base_amount DECIMAL(10,2) COMMENT 'Base amount',
  sgst_amount DECIMAL(10,2) COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) COMMENT 'SGST rate',
  cgst_percentage DECIMAL(5,2) COMMENT 'CGST rate',
  igst_percentage DECIMAL(5,2) COMMENT 'IGST rate',
  total_usage BIGINT COMMENT 'Aggregated usage',
  total_invoices INT COMMENT 'Invoice count',
  last_invoice_on DATETIME COMMENT 'Most recent invoice timestamp',
  added_by INT COMMENT 'Creator user ID',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving',
  INDEX idx_subscription_archive_all_subscription_id (subscription_id),
  INDEX idx_subscription_archive_all_tenant (tenant_id),
  INDEX idx_subscription_archive_all_plan_id (plan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subscription_request_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=pending, 2=approved, 3=rejected, 4=processed',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  subscription_id VARCHAR(20) NULL COMMENT 'Target subscription business ID (if update)',
  tenant_id INT NOT NULL COMMENT 'Tenant requesting the change',
  requested_by INT NOT NULL COMMENT 'User ID who initiated the request',
  device_id VARCHAR(50) NULL COMMENT 'Device identifier of the requester',
  ip_address VARCHAR(45) NULL COMMENT 'IP address of the requester',
  request_type VARCHAR(20) NOT NULL COMMENT 'CREATE, UPDATE, CANCEL',
  before_plan_id INT NULL COMMENT 'Plan ID before change',
  after_plan_id INT NULL COMMENT 'Plan ID after change',
  before_amount DECIMAL(10,2) NULL COMMENT 'Amount before change',
  after_amount DECIMAL(10,2) NULL COMMENT 'Amount after change',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount for this request',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount for this request',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount for this request',
  approval_1_by INT NULL COMMENT 'User ID of first approver',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT '1=approved, 2=rejected, 3=escalated',
  approval_2_by INT NULL COMMENT 'User ID of second approver',
  approval_2_on DATETIME NULL COMMENT 'Timestamp of second approval',
  approval_2_status INT NULL COMMENT '1=approved, 2=rejected, 3=escalated',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this transaction',
  CONSTRAINT fk_sub_req_txn_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_sub_req_txn_requested_by FOREIGN KEY (requested_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_sub_req_txn_tenant (tenant_id),
  INDEX idx_sub_req_txn_requested_by (requested_by),
  INDEX idx_sub_req_txn_month_year (month_year),
  INDEX idx_sub_req_txn_device_id (device_id),
  INDEX idx_sub_req_txn_approval_1_by (approval_1_by),
  INDEX idx_sub_req_txn_approval_2_by (approval_2_by),
  INDEX idx_sub_req_txn_before_plan_id (before_plan_id),
  INDEX idx_sub_req_txn_after_plan_id (after_plan_id),
  INDEX idx_sub_req_txn_subscription_id (subscription_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subscription_request_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  subscription_request_id INT NOT NULL COMMENT 'FK to subscription_request_transaction_all.id',
  previous_status INT NOT NULL COMMENT 'Status before this change (1=pending,2=approved,3=rejected,4=processed)',
  new_status INT NOT NULL COMMENT 'Status after this change (same codes as previous_status)',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who performed the transition',
  changed_on DATETIME NOT NULL COMMENT 'When the transition occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition (e.g., approval, timeout)',
  remarks TEXT NULL COMMENT 'Additional remarks',
  CONSTRAINT fk_sub_req_lc_txn FOREIGN KEY (subscription_request_id) REFERENCES subscription_request_transaction_all(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_sub_req_lc_changed_by FOREIGN KEY (changed_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_sub_req_lc_request (subscription_request_id),
  INDEX idx_sub_req_lc_changed_by (changed_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE plan_change_request_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=pending, 2=approved, 3=rejected, 4=cancelled',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  subscription_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the subscription being changed',
  requestor_user_id INT NOT NULL COMMENT 'User who initiated the plan change',
  previous_plan_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the current plan before change',
  new_plan_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the target plan after change',
  previous_amount DECIMAL(10,2) NOT NULL COMMENT 'Amount of current plan',
  new_amount DECIMAL(10,2) NOT NULL COMMENT 'Amount of target plan',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  approval_1_by INT NULL COMMENT 'User ID of first approver',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT '1=approved, 2=rejected',
  added_by INT NOT NULL COMMENT 'User ID who inserted this record',
  device_id VARCHAR(50) NULL COMMENT 'Device identifier used for the request',
  ip_address VARCHAR(45) NULL COMMENT 'IP address of the requester',
  INDEX idx_plan_change_request_transaction_all_month_year (month_year),
  INDEX idx_plan_change_request_transaction_all_tenant_id (tenant_id),
  INDEX idx_plan_change_request_transaction_all_device_id (device_id),
  INDEX idx_plan_change_request_transaction_all_previous_plan_id (previous_plan_id),
  INDEX idx_plan_change_request_transaction_all_new_plan_id (new_plan_id),
  INDEX idx_plan_change_request_transaction_all_requestor_user_id (requestor_user_id),
  INDEX idx_plan_change_request_transaction_all_approval_1_by (approval_1_by),
  INDEX idx_plan_change_request_transaction_all_subscription_id (subscription_id),
  CONSTRAINT fk_plan_change_request_transaction_all_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE usage_record_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=recorded, 2=adjusted, 3=invalidated',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all',
  subscription_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the subscription',
  usage_metric VARCHAR(50) NOT NULL COMMENT 'Name of the usage metric (e.g., API_CALLS)',
  usage_quantity DECIMAL(12,2) NOT NULL COMMENT 'Aggregated quantity for the period',
  unit_price DECIMAL(10,2) NOT NULL COMMENT 'Price per unit of the metric',
  total_amount DECIMAL(10,2) NOT NULL COMMENT 'Total amount = quantity * unit_price',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  added_by INT NOT NULL COMMENT 'User ID who recorded the usage',
  device_id VARCHAR(50) COMMENT 'Device identifier used for recording',
  ip_address VARCHAR(45) COMMENT 'IP address of the source system',
  INDEX idx_usage_record_transaction_all_month_year (month_year),
  INDEX idx_usage_record_transaction_all_tenant_id (tenant_id),
  INDEX idx_usage_record_transaction_all_device_id (device_id),
  INDEX idx_usage_record_transaction_all_subscription_id (subscription_id),
  CONSTRAINT fk_usage_record_transaction_all_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE invoice_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=issued, 2=paid, 3=overdue, 4=cancelled',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable invoice ID',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  subscription_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the subscription billed',
  invoice_number VARCHAR(30) NOT NULL COMMENT 'Official invoice number',
  invoice_date DATETIME NOT NULL COMMENT 'Date the invoice was generated',
  due_date DATETIME NOT NULL COMMENT 'Payment due date',
  subtotal_amount DECIMAL(10,2) NOT NULL COMMENT 'Sum of line items before tax',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  total_amount DECIMAL(10,2) NOT NULL COMMENT 'Grand total payable',
  pdf_url VARCHAR(255) NULL COMMENT 'Link to stored PDF version of the invoice',
  approval_1_by INT NULL COMMENT 'User ID of first approver (if manual approval required)',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT '1=approved, 2=rejected',
  added_by INT NOT NULL COMMENT 'User ID who created the invoice record',
  device_id VARCHAR(50) NULL COMMENT 'Device identifier used for creation',
  ip_address VARCHAR(45) NULL COMMENT 'IP address of the creator',
  INDEX idx_invoice_transaction_all_month_year (month_year),
  INDEX idx_invoice_transaction_all_tenant_id (tenant_id),
  INDEX idx_invoice_transaction_all_device_id (device_id),
  INDEX idx_invoice_transaction_all_subscription_id (subscription_id),
  CONSTRAINT fk_invoice_transaction_all_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_entry_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=posted, 2=reversed, 3=failed',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable ledger entry ID',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  invoice_id VARCHAR(30) NULL COMMENT 'Business ID of related invoice, if any',
  entry_type VARCHAR(20) NOT NULL COMMENT 'Debit or Credit',
  amount DECIMAL(10,2) NOT NULL COMMENT 'Transaction amount',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  opening_balance DECIMAL(12,2) NOT NULL COMMENT 'Balance before this entry',
  closing_balance DECIMAL(12,2) NOT NULL COMMENT 'Balance after this entry',
  batch_id VARCHAR(30) NULL COMMENT 'Reconciliation batch identifier',
  approval_1_by INT NULL COMMENT 'User ID of first approver',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT '1=approved, 2=rejected',
  added_by INT NOT NULL COMMENT 'User ID who posted the ledger entry',
  device_id VARCHAR(50) NULL COMMENT 'Device identifier used for posting',
  ip_address VARCHAR(45) NULL COMMENT 'IP address of the posting system',
  INDEX idx_ledger_entry_transaction_all_month_year (month_year),
  INDEX idx_ledger_entry_transaction_all_tenant_id (tenant_id),
  INDEX idx_ledger_entry_transaction_all_batch_id (batch_id),
  INDEX idx_ledger_entry_transaction_all_device_id (device_id),
  INDEX idx_ledger_entry_transaction_all_invoice_id (invoice_id),
  CONSTRAINT fk_ledger_entry_transaction_all_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE ledger_entry_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  ledger_entry_id INT NOT NULL COMMENT 'FK to ledger_entry_transaction_all.id',
  previous_status INT NOT NULL COMMENT 'Previous state of the ledger entry (1=created,2=posted,3=reversed,4=failed)',
  new_status INT NOT NULL COMMENT 'New state of the ledger entry (1=created,2=posted,3=reversed,4=failed)',
  reason VARCHAR(500) COMMENT 'Reason for state change',
  changed_by INT NOT NULL COMMENT 'User ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the state change',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active,2=inactive,3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_ledger_entry_life_cycle_all_ledger_entry_transaction_all FOREIGN KEY (ledger_entry_id) REFERENCES ledger_entry_transaction_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_ledger_entry_life_cycle_all_ledger_entry_id (ledger_entry_id),
  INDEX idx_ledger_entry_life_cycle_all_changed_on (changed_on)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE account_balance_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  sort_order INT NOT NULL COMMENT 'Sequence number for line‑item ordering',
  balance_type VARCHAR(30) NOT NULL COMMENT 'Type of balance (e.g., prepaid, credit, escrow)',
  amount DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Monetary amount for this line item',
  description VARCHAR(255) COMMENT 'Human‑readable description of the balance line',
  effective_date DATE COMMENT 'Date from which this balance line is effective',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active,2=inactive,3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_account_balance_details_all_tenant_header_all FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_account_balance_details_all_tenant_id (tenant_id),
  INDEX idx_account_balance_details_all_balance_type (balance_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE credit_adjustment_request_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning and analytics',
  request_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable request ID (e.g., CADJ-00001)',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  requested_by_user_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  approved_by_user_id INT NULL COMMENT 'FK to user_header_all.id',
  before_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Tenant balance before adjustment',
  adjustment_amount DECIMAL(10,2) NOT NULL COMMENT 'Amount to be added (positive) or deducted (negative)',
  after_balance DECIMAL(12,2) NOT NULL COMMENT 'Tenant balance after adjustment',
  adjustment_type VARCHAR(30) NOT NULL COMMENT 'Type of adjustment (e.g., credit_note, manual_refund)',
  approval_status INT NOT NULL DEFAULT 0 COMMENT '0=pending,1=approved,2=rejected',
  approval_1_by INT NULL COMMENT 'User ID of first approver',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT 'Status of first approval (1=approved,2=rejected)',
  added_by INT NOT NULL COMMENT 'User ID who created the record',
  device_id VARCHAR(50) NULL COMMENT 'Device identifier from which request originated',
  ip_address VARCHAR(45) NULL COMMENT 'IP address of the requester',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active,2=inactive,3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_credit_adjustment_request_transaction_all_tenant_header_all FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_credit_adjustment_request_transaction_all_requested_by_user FOREIGN KEY (requested_by_user_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_credit_adjustment_request_transaction_all_approved_by_user FOREIGN KEY (approved_by_user_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_credit_adjustment_request_transaction_all_tenant_id (tenant_id),
  INDEX idx_credit_adjustment_request_transaction_all_month_year (month_year),
  INDEX idx_credit_adjustment_request_transaction_all_approval_status (approval_status),
  INDEX idx_credit_adjustment_request_transaction_all_approval_1_by (approval_1_by),
  INDEX idx_credit_adjustment_request_transaction_all_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Approval Engine  (3 tables)
-- ============================================================

CREATE TABLE approver_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=suspended',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  approver_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. APR-00001)',
  user_id INT NOT NULL COMMENT 'FK to user_header_all.id who is the approver',
  role_id INT NOT NULL COMMENT 'FK to role_header_all.id defining approver role',
  department VARCHAR(100) NOT NULL COMMENT 'Department to which the approver belongs',
  approval_limit DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Maximum monetary amount the approver can authorize',
  approval_level INT NOT NULL COMMENT 'Sequential level in multi‑stage approval chain (1=first, 2=second, …)',
  notification_email VARCHAR(255) NOT NULL COMMENT 'Email address for approval notifications',
  phone_number VARCHAR(20) NULL COMMENT 'Contact phone number',
  is_default_approver TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=default approver for its level, 0=otherwise',
  effective_from DATETIME NOT NULL COMMENT 'Date from which approver is active',
  effective_to DATETIME NULL COMMENT 'Date after which approver is inactive (null = indefinite)',
  added_by INT NOT NULL COMMENT 'User ID who created this approver record',
  device_id VARCHAR(50) NULL COMMENT 'Device identifier used at creation',
  ip_address VARCHAR(45) NULL COMMENT 'IP address of creator',
  INDEX idx_approver_all_user_id (user_id),
  INDEX idx_approver_all_role_id (role_id),
  INDEX idx_approver_all_device_id (device_id),
  CONSTRAINT fk_approver_all_user_header_all FOREIGN KEY (user_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_approver_all_role_header_all FOREIGN KEY (role_id) REFERENCES role_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE approval_request_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=pending, 2=partially_approved, 3=approved, 4=rejected, 5=cancelled',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  approval_request_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. ARQ-00001)',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY‑MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL COMMENT 'External reference number for the request',
  requester_id INT NOT NULL COMMENT 'FK to user_header_all.id who initiated the request',
  target_entity VARCHAR(50) NOT NULL COMMENT 'Entity type being acted upon (e.g. subscription, credit_adjustment)',
  target_entity_id VARCHAR(20) NOT NULL COMMENT 'Business ID of the target entity',
  amount_before DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Value before change',
  amount_after DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Value after change',
  currency_code VARCHAR(3) NOT NULL DEFAULT 'INR' COMMENT 'ISO currency code',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this transaction',
  approval_1_by INT NULL COMMENT 'FK to approver_all.id who performed first approval',
  approval_1_on DATETIME NULL COMMENT 'Timestamp of first approval',
  approval_1_status INT NULL COMMENT '1=approved, 2=rejected, 3=escalated',
  approval_2_by INT NULL COMMENT 'FK to approver_all.id who performed second approval',
  approval_2_on DATETIME NULL COMMENT 'Timestamp of second approval',
  approval_2_status INT NULL COMMENT '1=approved, 2=rejected, 3=escalated',
  approval_3_by INT NULL COMMENT 'FK to approver_all.id who performed third approval',
  approval_3_on DATETIME NULL COMMENT 'Timestamp of third approval',
  approval_3_status INT NULL COMMENT '1=approved, 2=rejected, 3=escalated',
  added_by INT NOT NULL COMMENT 'User ID who created this request',
  device_id VARCHAR(50) NULL COMMENT 'Device identifier used at creation',
  ip_address VARCHAR(45) NULL COMMENT 'IP address of creator',
  INDEX idx_approval_req_trans_month_year (month_year),
  INDEX idx_approval_req_trans_requester_id (requester_id),
  INDEX idx_approval_req_trans_target_entity (target_entity),
  INDEX idx_approval_req_trans_target_entity_id (target_entity_id),
  INDEX idx_approval_req_trans_device_id (device_id),
  INDEX idx_approval_req_trans_approval_1_by (approval_1_by),
  INDEX idx_approval_req_trans_approval_2_by (approval_2_by),
  INDEX idx_approval_req_trans_approval_3_by (approval_3_by),
  CONSTRAINT fk_approval_req_trans_requester_user_header_all FOREIGN KEY (requester_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_approval_req_trans_approval_1_approver_all FOREIGN KEY (approval_1_by) REFERENCES approver_all(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_approval_req_trans_approval_2_approver_all FOREIGN KEY (approval_2_by) REFERENCES approver_all(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_approval_req_trans_approval_3_approver_all FOREIGN KEY (approval_3_by) REFERENCES approver_all(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE approval_request_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  approval_request_id INT NOT NULL COMMENT 'FK to approval_request_transaction_all.id',
  previous_status INT NOT NULL COMMENT '1=pending, 2=partially_approved, 3=approved, 4=rejected, 5=cancelled',
  new_status INT NOT NULL COMMENT '1=pending, 2=partially_approved, 3=approved, 4=rejected, 5=cancelled',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of status change',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition (e.g., approval_1, timeout)',
  remarks TEXT NULL COMMENT 'Additional remarks',
  CONSTRAINT fk_approval_lc_approval_req_trans FOREIGN KEY (approval_request_id) REFERENCES approval_request_transaction_all(id) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_approval_lc_approval_request_id (approval_request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Audit & Compliance  (5 tables)
-- ============================================================

CREATE TABLE audit_log_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted [document all values]',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  table_name VARCHAR(100) NOT NULL COMMENT 'Name of the table being audited',
  row_id VARCHAR(36) NOT NULL COMMENT 'Primary key of the audited row (UUID if applicable)',
  action VARCHAR(10) NOT NULL COMMENT 'INSERT|UPDATE|DELETE',
  before_state JSON COMMENT 'JSON snapshot of row before change',
  after_state JSON COMMENT 'JSON snapshot of row after change',
  actor_user_id INT NOT NULL COMMENT 'User ID who performed the action',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier used for the action',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the actor',
  user_agent VARCHAR(255) NOT NULL COMMENT 'User‑agent string of the client',
  added_by INT NOT NULL COMMENT 'User ID who created this audit record',
  INDEX idx_audit_log_transaction_all_month_year (month_year),
  INDEX idx_audit_log_transaction_all_table_name (table_name),
  INDEX idx_audit_log_transaction_all_actor_user_id (actor_user_id),
  INDEX idx_audit_log_transaction_all_device_id (device_id),
  INDEX idx_audit_log_transaction_all_row_id (row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_query_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted [document all values]',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  tenant_id INT NOT NULL COMMENT 'Tenant for which audit query is scoped',
  query_name VARCHAR(100) NOT NULL COMMENT 'Descriptive name of the saved query',
  month_year_start VARCHAR(7) NOT NULL COMMENT 'Start month (YYYY‑MM) for query range',
  month_year_end VARCHAR(7) NOT NULL COMMENT 'End month (YYYY‑MM) for query range',
  table_filter VARCHAR(200) NOT NULL COMMENT 'Comma‑separated list of tables to include',
  action_filter VARCHAR(100) NOT NULL COMMENT 'Comma‑separated list of actions (INSERT,UPDATE,DELETE)',
  user_id_filter INT COMMENT 'Filter by actor user ID (optional)',
  ip_address_filter VARCHAR(45) COMMENT 'Filter by IP address (optional)',
  additional_criteria JSON COMMENT 'Arbitrary extra criteria in JSON',
  added_by INT NOT NULL COMMENT 'User ID who saved this query',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier used to create the query',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the creator',
  INDEX idx_audit_query_all_tenant_id (tenant_id),
  INDEX idx_audit_query_all_month_year_start (month_year_start),
  INDEX idx_audit_query_all_month_year_end (month_year_end),
  INDEX idx_audit_query_all_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE security_event_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted [document all values]',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  event_type VARCHAR(50) NOT NULL COMMENT 'Type of security event (e.g., suspicious_login, brute_force)',
  severity INT NOT NULL COMMENT 'Severity level (1=low, 5=critical) [document all values]',
  source_ip VARCHAR(45) NOT NULL COMMENT 'IP address where event originated',
  destination_ip VARCHAR(45) NOT NULL COMMENT 'Target IP address (if applicable)',
  user_id INT NOT NULL COMMENT 'User ID involved in the event',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier involved',
  user_agent VARCHAR(255) NOT NULL COMMENT 'User‑agent string of the client',
  event_timestamp DATETIME NOT NULL COMMENT 'Exact time the event was detected',
  description TEXT COMMENT 'Detailed description of the security incident',
  remediation_status VARCHAR(30) NOT NULL COMMENT 'Current remediation status (e.g., pending, resolved)',
  remediation_by INT COMMENT 'User ID who performed remediation',
  remediation_on DATETIME COMMENT 'Timestamp when remediation was applied',
  added_by INT NOT NULL COMMENT 'User ID who logged the security event',
  device_id_logger VARCHAR(50) NOT NULL COMMENT 'Device that logged the event',
  ip_address_logger VARCHAR(45) NOT NULL COMMENT 'IP address of the logging device',
  INDEX idx_security_event_transaction_all_month_year (month_year),
  INDEX idx_security_event_transaction_all_event_type (event_type),
  INDEX idx_security_event_transaction_all_user_id (user_id),
  INDEX idx_security_event_transaction_all_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE alert_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted [document all values]',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  alert_type VARCHAR(50) NOT NULL COMMENT 'Type of alert (e.g., security_breach, compliance_violation)',
  severity INT NOT NULL COMMENT 'Severity level (1=low, 5=critical) [document all values]',
  related_event_id INT NOT NULL COMMENT 'FK to security_event_transaction_all.id',
  recipient_user_id INT NOT NULL COMMENT 'User ID of alert recipient',
  channel VARCHAR(30) NOT NULL COMMENT 'Delivery channel (email, sms, push)',
  delivery_status VARCHAR(30) NOT NULL COMMENT 'Current delivery status (queued, sent, failed)',
  delivery_attempts INT NOT NULL DEFAULT 0 COMMENT 'Number of delivery attempts made',
  last_attempt_on DATETIME NULL COMMENT 'Timestamp of the last delivery attempt',
  message_subject VARCHAR(200) NOT NULL COMMENT 'Subject line of the alert message',
  message_body TEXT NOT NULL COMMENT 'Full alert message content',
  added_by INT NOT NULL COMMENT 'User ID who generated the alert',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier that generated the alert',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the device generating the alert',
  INDEX idx_alert_transaction_all_month_year (month_year),
  INDEX idx_alert_transaction_all_alert_type (alert_type),
  INDEX idx_alert_transaction_all_recipient_user_id (recipient_user_id),
  INDEX idx_alert_transaction_all_device_id (device_id),
  CONSTRAINT fk_alert_transaction_all_related_event FOREIGN KEY (related_event_id) REFERENCES security_event_transaction_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE alert_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  alert_id INT NOT NULL COMMENT 'FK to alert_transaction_all.id',
  previous_status INT NOT NULL COMMENT 'Previous status code (e.g., 1=active, 2=resolved, 3=escalated, 4=closed)',
  new_status INT NOT NULL COMMENT 'New status code after transition (e.g., 1=active, 2=resolved, 3=escalated, 4=closed)',
  reason VARCHAR(500) COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp when the status change occurred',
  trigger_event VARCHAR(100) NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted [document all values]',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_alert_life_cycle_all_alert_transaction_all FOREIGN KEY (alert_id) REFERENCES alert_transaction_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_alert_life_cycle_all_alert_id (alert_id),
  INDEX idx_alert_life_cycle_all_previous_status (previous_status),
  INDEX idx_alert_life_cycle_all_new_status (new_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- MODULE COMPLETE

CREATE TABLE tenant_administrator_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  user_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  previous_is_admin TINYINT NOT NULL COMMENT 'Previous admin flag (0/1)',
  new_is_admin TINYINT NOT NULL COMMENT 'New admin flag (0/1)',
  changed_by INT NOT NULL COMMENT 'User ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the change',
  reason VARCHAR(500) NULL COMMENT 'Reason for change',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_tenant_admin_lc_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tenant_admin_lc_user FOREIGN KEY (user_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_tenant_admin_lc_tenant_id (tenant_id),
  INDEX idx_tenant_admin_lc_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenant_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  tenant_id INT NOT NULL COMMENT 'FK to tenant_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous tenant status',
  new_status INT NOT NULL COMMENT 'New tenant status',
  changed_by INT NOT NULL COMMENT 'User ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the change',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_tenant_life_cycle_all_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_tenant_life_cycle_all_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subscription_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  subscription_id INT NOT NULL COMMENT 'FK to subscription_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous subscription status',
  new_status INT NOT NULL COMMENT 'New subscription status',
  changed_by INT NOT NULL COMMENT 'User ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the change',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_subscription_life_cycle_all_subscription_header FOREIGN KEY (subscription_id) REFERENCES subscription_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_subscription_life_cycle_all_subscription_id (subscription_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  role_id INT NOT NULL COMMENT 'FK to role_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous role status',
  new_status INT NOT NULL COMMENT 'New role status',
  changed_by INT NOT NULL COMMENT 'User ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the change',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_role_life_cycle_all_role_header FOREIGN KEY (role_id) REFERENCES role_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_role_life_cycle_all_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  user_id INT NOT NULL COMMENT 'FK to user_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous user status',
  new_status INT NOT NULL COMMENT 'New user status',
  changed_by INT NOT NULL COMMENT 'User ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp of the change',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  remarks TEXT NULL COMMENT 'Additional remarks',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_user_life_cycle_all_user FOREIGN KEY (user_id) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_user_life_cycle_all_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
-- ============================================================
-- End of schema
-- ============================================================
