-- ============================================================
-- Project  : National Parcel and Freight Carrier Operational Database
-- Generated: 2026-09-05 10:19:33
-- Engine   : AI DB Schema Generator
-- Rules    : 98 production rules applied
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
START TRANSACTION;

-- ============================================================
-- Project  : National Parcel and Freight Carrier Operational Database
-- Generated: 2026-09-05 10:14:10
-- Modules  : 7
-- Tables   : 31
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
  id_for VARCHAR(50) NOT NULL COMMENT 'Entity this ID represents (e.g. USER, VEHICLE, SHIPMENT)',
  prefix VARCHAR(20) NOT NULL COMMENT 'Business ID prefix (e.g. UI, VHC, SHP)',
  last_id VARCHAR(15) NOT NULL DEFAULT '00000' COMMENT 'Last issued numeric sequence',
  business_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. UI‑00001)',
  domain_code VARCHAR(10) NOT NULL COMMENT 'Domain specific code (e.g. LOG‑01)',
  effective_from DATETIME NOT NULL COMMENT 'Date‑time from which this ID is valid',
  effective_to DATETIME NULL COMMENT 'Date‑time until which this ID is valid (NULL = indefinite)',
  allocation_date DATETIME NOT NULL COMMENT 'When the ID was allocated to the entity',
  allocated_by INT NOT NULL COMMENT 'User ID who performed the allocation',
  total_child_records INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of child records linked to this entity',
  last_child_created_on DATETIME NULL COMMENT 'Timestamp of the most recent child record creation',
  last_child_id VARCHAR(20) NULL COMMENT 'Business ID of the most recent child record',
  flag_active TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=active, 0=inactive flag for quick lookup',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=retired, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_uniqueid_allocatedby FOREIGN KEY (allocated_by) REFERENCES user_header_all(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_uniqueid_table_name (table_name),
  INDEX idx_uniqueid_prefix (prefix),
  INDEX idx_uniqueid_status (status),
  INDEX idx_unique_id_header_all_last_id (last_id),
  INDEX idx_unique_id_header_all_last_child_id (last_child_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE factory_reset_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  app_version VARCHAR(20) NOT NULL COMMENT 'Current deployed application version',
  maintenance_mode TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=maintenance mode ON, 0=OFF',
  api_throttle_enabled TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=API throttling active, 0=disabled',
  feature_flag_batch_processing TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Enable/disable batch processing subsystem',
  feature_flag_real_time_tracking TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Enable/disable real‑time shipment tracking',
  feature_flag_dynamic_routing TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Enable/disable dynamic route optimisation',
  feature_flag_driver_alerts TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Enable/disable driver alert notifications',
  feature_flag_cargo_insurance TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Enable/disable optional cargo insurance',
  feature_flag_multi_currency TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Enable/disable multi‑currency support',
  feature_flag_gst_compliance TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Enforce GST breakdown on all billing tables',
  max_concurrent_jobs INT NOT NULL DEFAULT 50 COMMENT 'Maximum number of concurrent background jobs',
  job_retry_limit INT NOT NULL DEFAULT 3 COMMENT 'Number of retries before a job is marked failed',
  default_retry_interval_seconds INT NOT NULL DEFAULT 300 COMMENT 'Default wait time between job retries',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=archived, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT uq_factory_reset_singleton UNIQUE (id),
  INDEX idx_factory_version (app_version),
  INDEX idx_factory_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Shipment Management  (13 tables)
-- ============================================================

CREATE TABLE shipment_request_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=pending, 2=approved, 3=rejected, 4=cancelled, 5=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  shipment_request_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. SR‑00001)',
  shipper_id INT NOT NULL COMMENT 'FK to shipper_header_all.id',
  origin_location VARCHAR(255) NOT NULL COMMENT 'Pickup address or location code',
  destination_location VARCHAR(255) NOT NULL COMMENT 'Delivery address or location code',
  weight_kg DECIMAL(10,2) NOT NULL COMMENT 'Total weight of the shipment in kilograms',
  volume_cbm DECIMAL(10,2) NOT NULL COMMENT 'Total volume of the shipment in cubic meters',
  declared_value DECIMAL(10,2) NOT NULL COMMENT 'Monetary value declared for customs/insurance',
  service_level_id INT NOT NULL COMMENT 'FK to service_level_header_all.id',
  pickup_date DATETIME NOT NULL COMMENT 'Requested pickup date and time',
  delivery_deadline DATETIME NOT NULL COMMENT 'Promised delivery deadline',
  special_handling_flag TINYINT NOT NULL DEFAULT 0 COMMENT '1=requires special handling, 0=normal',
  insurance_required TINYINT NOT NULL DEFAULT 0 COMMENT '1=insurance purchased, 0=none',
  total_items INT NOT NULL DEFAULT 0 COMMENT 'Aggregate count of line‑item packages in this request',
  total_weight_kg DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Aggregate weight of all items (kg)',
  last_item_added_on DATETIME NULL COMMENT 'Timestamp of the most recent item added to the request',
  added_by INT NOT NULL COMMENT 'User ID who created this record',
  CONSTRAINT fk_shipmentrequest_shipper FOREIGN KEY (shipper_id) REFERENCES shipper_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_shipmentrequest_servicelevel FOREIGN KEY (service_level_id) REFERENCES service_level_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_shipmentrequest_addedby FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_shipmentrequest_shipper (shipper_id),
  INDEX idx_shipmentrequest_servicelevel (service_level_id),
  INDEX idx_shipmentrequest_addedby (added_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipment_request_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL COMMENT '1=pending, 2=approved, 3=rejected, 4=cancelled, 5=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  shipment_request_id VARCHAR(20) NOT NULL COMMENT 'Human‑readable business ID (e.g. SR‑00001)',
  shipper_id INT NOT NULL COMMENT 'FK to shipper (customer) entity',
  origin_location VARCHAR(255) NOT NULL COMMENT 'Pickup address or location code',
  destination_location VARCHAR(255) NOT NULL COMMENT 'Delivery address or location code',
  weight_kg DECIMAL(10,2) NOT NULL COMMENT 'Total weight of the shipment in kilograms',
  volume_cbm DECIMAL(10,2) NOT NULL COMMENT 'Total volume of the shipment in cubic meters',
  declared_value DECIMAL(10,2) NOT NULL COMMENT 'Monetary value declared for customs/insurance',
  service_level_id INT NOT NULL COMMENT 'FK to service level (e.g., standard, express)',
  pickup_date DATETIME NOT NULL COMMENT 'Requested pickup date and time',
  delivery_deadline DATETIME NOT NULL COMMENT 'Promised delivery deadline',
  special_handling_flag TINYINT NOT NULL COMMENT '1=requires special handling, 0=normal',
  insurance_required TINYINT NOT NULL COMMENT '1=insurance purchased, 0=none',
  total_items INT NOT NULL COMMENT 'Aggregate count of line‑item packages in this request',
  total_weight_kg DECIMAL(12,2) NOT NULL COMMENT 'Aggregate weight of all items (kg)',
  last_item_added_on DATETIME NULL COMMENT 'Timestamp of the most recent item added to the request',
  added_by INT NOT NULL COMMENT 'User ID who created this record',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User ID who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_shipment_request_archive_all_service_level_id (service_level_id),
  INDEX idx_shipment_request_archive_all_shipment_request_id (shipment_request_id),
  INDEX idx_shipment_request_archive_all_shipper_id (shipper_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipment_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=created, 2=in_transit, 3=delivered, 4=exception, 5=closed, 6=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  shipment_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. S‑00001)',
  shipment_request_id INT NOT NULL COMMENT 'Reference to originating shipment request (shipment_request_header_all.id)',
  carrier_id INT NOT NULL COMMENT 'FK to carrier_header_all.id',
  vehicle_id INT NOT NULL COMMENT 'FK to vehicle_header_all.id',
  driver_id INT NOT NULL COMMENT 'FK to driver_header_all.id',
  origin_location VARCHAR(255) NOT NULL COMMENT 'Actual pickup location',
  destination_location VARCHAR(255) NOT NULL COMMENT 'Actual delivery location',
  weight_kg DECIMAL(10,2) NOT NULL COMMENT 'Weight of the shipment (kg)',
  volume_cbm DECIMAL(10,2) NOT NULL COMMENT 'Volume of the shipment (cbm)',
  declared_value DECIMAL(10,2) NOT NULL COMMENT 'Declared monetary value',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  total_distance_km DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Cumulative distance travelled (km)',
  total_fuel_consumed_liters DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Fuel consumed for the shipment',
  total_items INT NOT NULL DEFAULT 0 COMMENT 'Number of line‑item packages in the shipment',
  last_status_update_on DATETIME NOT NULL COMMENT 'Timestamp of the most recent status change',
  expected_delivery_on DATETIME NOT NULL COMMENT 'System‑calculated expected delivery datetime',
  actual_delivery_on DATETIME NULL COMMENT 'Actual delivery datetime when completed',
  added_by INT NOT NULL COMMENT 'User ID who created this record',
  CONSTRAINT fk_shipment_request FOREIGN KEY (shipment_request_id) REFERENCES shipment_request_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_shipment_carrier FOREIGN KEY (carrier_id) REFERENCES carrier_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_shipment_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicle_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_shipment_driver FOREIGN KEY (driver_id) REFERENCES driver_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_shipment_addedby FOREIGN KEY (added_by) REFERENCES user_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_shipment_request (shipment_request_id),
  INDEX idx_shipment_carrier (carrier_id),
  INDEX idx_shipment_vehicle (vehicle_id),
  INDEX idx_shipment_driver (driver_id),
  INDEX idx_shipment_addedby (added_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipment_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL COMMENT '1=created, 2=in_transit, 3=delivered, 4=exception, 5=closed, 6=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  shipment_id VARCHAR(20) NOT NULL COMMENT 'Human‑readable business ID (e.g. S‑00001)',
  shipment_request_id VARCHAR(20) NOT NULL COMMENT 'Reference to originating shipment request',
  carrier_id INT NOT NULL COMMENT 'FK to carrier (logistics provider) entity',
  vehicle_id INT NOT NULL COMMENT 'FK to vehicle used for the shipment',
  driver_id INT NOT NULL COMMENT 'FK to driver assigned to the shipment',
  origin_location VARCHAR(255) NOT NULL COMMENT 'Actual pickup location',
  destination_location VARCHAR(255) NOT NULL COMMENT 'Actual delivery location',
  weight_kg DECIMAL(10,2) NOT NULL COMMENT 'Weight of the shipment (kg)',
  volume_cbm DECIMAL(10,2) NOT NULL COMMENT 'Volume of the shipment (cbm)',
  declared_value DECIMAL(10,2) NOT NULL COMMENT 'Declared monetary value',
  sgst_amount DECIMAL(10,2) NOT NULL COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL COMMENT 'CGST rate applied',
  total_distance_km DECIMAL(12,2) NOT NULL COMMENT 'Cumulative distance travelled (km)',
  total_fuel_consumed_liters DECIMAL(12,2) NOT NULL COMMENT 'Fuel consumed for the shipment',
  total_items INT NOT NULL COMMENT 'Number of line‑item packages in the shipment',
  last_status_update_on DATETIME NOT NULL COMMENT 'Timestamp of the most recent status change',
  expected_delivery_on DATETIME NOT NULL COMMENT 'System‑calculated expected delivery datetime',
  actual_delivery_on DATETIME NULL COMMENT 'Actual delivery datetime when completed',
  added_by INT NOT NULL COMMENT 'User ID who created this record',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User ID who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this version',
  INDEX idx_shipment_archive_all_shipment_id (shipment_id),
  INDEX idx_shipment_archive_all_shipment_request_id (shipment_request_id),
  INDEX idx_shipment_archive_all_carrier_id (carrier_id),
  INDEX idx_shipment_archive_all_vehicle_id (vehicle_id),
  INDEX idx_shipment_archive_all_driver_id (driver_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE shipment_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  shipment_id INT NOT NULL COMMENT 'FK to shipment_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous status code of the shipment (1=created,2=planned,3=in_transit,4=delivered,5=cancelled)',
  new_status INT NOT NULL COMMENT 'New status code after transition (same code set as previous_status)',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User/employee ID who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'Timestamp when the change occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition (e.g. scan, system_job, manual_override)',
  remarks TEXT NULL COMMENT 'Additional remarks for the transition',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_shipment_life_cycle_all_shipment_header_all FOREIGN KEY (shipment_id) REFERENCES shipment_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_shipment_life_cycle_all_shipment_id (shipment_id),
  INDEX idx_shipment_life_cycle_all_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE route_plan_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  shipment_id INT NOT NULL COMMENT 'FK to shipment_header_all.id',
  sort_order INT NOT NULL COMMENT 'Sequence number of the route plan line item',
  carrier_id INT NOT NULL COMMENT 'FK to carrier_header_all.id',
  vehicle_id INT NOT NULL COMMENT 'FK to vehicle_header_all.id',
  optimal_path VARCHAR(500) NOT NULL COMMENT 'Serialized optimal path (e.g. waypoint IDs or encoded polyline)',
  distance_km DECIMAL(10,2) NOT NULL COMMENT 'Total distance of this route segment in kilometers',
  estimated_time_minutes INT NOT NULL COMMENT 'Estimated travel time for this segment in minutes',
  alternative_path VARCHAR(500) NULL COMMENT 'Serialized alternative path if primary fails',
  remarks TEXT NULL COMMENT 'Additional notes for the route segment',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  added_by INT NOT NULL COMMENT 'User ID who created this route detail',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_route_plan_details_all_shipment_header_all FOREIGN KEY (shipment_id) REFERENCES shipment_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_route_plan_details_all_carrier FOREIGN KEY (carrier_id) REFERENCES carrier_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_route_plan_details_all_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicle_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_route_plan_details_all_shipment_id (shipment_id),
  INDEX idx_route_plan_details_all_carrier_id (carrier_id),
  INDEX idx_route_plan_details_all_vehicle_id (vehicle_id),
  INDEX idx_route_plan_details_all_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipment_event_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  shipment_id INT NOT NULL COMMENT 'FK to shipment_header_all.id',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning and analytics',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID (e.g. SHPEVT-00001)',
  event_type VARCHAR(50) NOT NULL COMMENT 'Type of event (SCAN, GPS_PING, STATUS_CHANGE, etc.)',
  event_timestamp DATETIME NOT NULL COMMENT 'Exact time the event was generated',
  location_lat DECIMAL(9,6) NULL COMMENT 'Latitude of the event location',
  location_long DECIMAL(9,6) NULL COMMENT 'Longitude of the event location',
  status_before INT NULL COMMENT 'Shipment status before this event (integer code)',
  status_after INT NULL COMMENT 'Shipment status after this event (integer code)',
  device_id VARCHAR(50) NULL COMMENT 'Identifier of the device that generated the event',
  ip_address VARCHAR(45) NULL COMMENT 'IP address of the source system/device',
  amount DECIMAL(10,2) NULL COMMENT 'Financial amount associated with the event, if any',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount for the event, if applicable',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount for the event, if applicable',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount for the event, if applicable',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  added_by INT NOT NULL COMMENT 'User ID who recorded this event',
  remarks TEXT NULL COMMENT 'Free‑form notes about the event',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_shipment_event_transaction_all_shipment_header_all FOREIGN KEY (shipment_id) REFERENCES shipment_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_shipment_event_transaction_all_shipment_id (shipment_id),
  INDEX idx_shipment_event_transaction_all_month_year (month_year),
  INDEX idx_shipment_event_transaction_all_event_type (event_type),
  INDEX idx_shipment_event_transaction_all_status (status),
  INDEX idx_shipment_event_transaction_all_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipment_tracking_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  shipment_id INT NOT NULL COMMENT 'FK to shipment_header_all.id',
  sort_order INT NOT NULL COMMENT 'Sequence number for tracking detail rows (e.g., latest first = 1)',
  latest_event_type VARCHAR(50) NOT NULL COMMENT 'Most recent event type recorded for the shipment',
  latest_event_timestamp DATETIME NOT NULL COMMENT 'Timestamp of the most recent event',
  current_location VARCHAR(200) NOT NULL COMMENT 'Human‑readable description of current location',
  eta_timestamp DATETIME NULL COMMENT 'Estimated time of arrival at final destination',
  total_distance_km DECIMAL(10,2) NOT NULL COMMENT 'Cumulative distance travelled by the shipment in km',
  remarks TEXT NULL COMMENT 'Additional tracking notes or exceptions',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  added_by INT NOT NULL COMMENT 'User ID who generated this tracking summary',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_shipment_tracking_details_all_shipment_header_all FOREIGN KEY (shipment_id) REFERENCES shipment_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_shipment_tracking_details_all_shipment_id (shipment_id),
  INDEX idx_shipment_tracking_details_all_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE shipment_status_lookup_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  status_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Short code for status (e.g. IN_TRANSIT)',
  status_description VARCHAR(255) NOT NULL COMMENT 'Full description of shipment status',
  is_terminal TINYINT NOT NULL DEFAULT 0 COMMENT '1=terminal status (Delivered, Cancelled), 0=non‑terminal',
  requires_customer_notification TINYINT NOT NULL DEFAULT 0 COMMENT '1=notify customer when status reached',
  estimated_max_days INT NULL COMMENT 'Maximum days expected for this status',
  escalation_level INT NOT NULL DEFAULT 0 COMMENT '0=none, 1=low, 2=medium, 3=high',
  color_hex CHAR(7) NULL COMMENT 'UI colour code for status badge',
  display_order INT NOT NULL DEFAULT 0 COMMENT 'Order in UI lists',
  created_by INT NOT NULL COMMENT 'User ID who created this lookup entry',
  modified_by INT NOT NULL COMMENT 'User ID who last modified this lookup entry',
  CONSTRAINT fk_shipment_status_lookup_all_createdby FOREIGN KEY (created_by) REFERENCES employee_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_shipment_status_lookup_all_modifiedby FOREIGN KEY (modified_by) REFERENCES employee_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_shipment_status_lookup_all_display_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exception_type_lookup_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  exception_code VARCHAR(30) NOT NULL UNIQUE COMMENT 'Short code for exception type (e.g. DELAY, DAMAGE)',
  exception_name VARCHAR(100) NOT NULL COMMENT 'Human readable name of exception type',
  description TEXT NULL COMMENT 'Detailed description of the exception category',
  default_severity INT NOT NULL COMMENT '1=low, 2=medium, 3=high, 4=critical',
  is_financial_impact TINYINT NOT NULL DEFAULT 0 COMMENT '1=exception may involve monetary claim',
  compensation_policy VARCHAR(255) NULL COMMENT 'Reference to compensation policy document',
  auto_escalate TINYINT NOT NULL DEFAULT 0 COMMENT '1=auto‑escalate to higher authority',
  escalation_time_hours INT NULL COMMENT 'Hours after which auto‑escalation occurs',
  created_by INT NOT NULL COMMENT 'User ID who created this exception type',
  modified_by INT NOT NULL COMMENT 'User ID who last modified this exception type',
  CONSTRAINT fk_exception_type_lookup_all_createdby FOREIGN KEY (created_by) REFERENCES employee_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_exception_type_lookup_all_modifiedby FOREIGN KEY (modified_by) REFERENCES employee_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_exception_type_lookup_all_default_severity (default_severity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exception_record_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=resolved, 3=closed, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  shipment_id INT NOT NULL COMMENT 'FK to shipment_header_all.id',
  exception_type_id INT NOT NULL COMMENT 'FK to exception_type_lookup_all.id',
  detected_by_user_id INT NOT NULL COMMENT 'User who recorded the exception',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier used for entry',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the device',
  exception_timestamp DATETIME NOT NULL COMMENT 'When the exception was detected',
  severity_level INT NOT NULL COMMENT '1=low, 2=medium, 3=high, 4=critical',
  location_latitude DECIMAL(9,6) NULL COMMENT 'Latitude of incident location',
  location_longitude DECIMAL(9,6) NULL COMMENT 'Longitude of incident location',
  before_status INT NOT NULL COMMENT 'Shipment status before exception (see shipment_status_lookup_all)',
  after_status INT NOT NULL COMMENT 'Shipment status after exception (see shipment_status_lookup_all)',
  affected_weight_kg DECIMAL(10,2) NULL COMMENT 'Weight of cargo affected by exception',
  affected_value DECIMAL(10,2) NULL COMMENT 'Monetary value impacted by exception',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount if financial claim',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount if financial claim',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount if financial claim',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  notes TEXT NULL COMMENT 'Free‑form notes describing the exception',
  added_by INT NOT NULL COMMENT 'User ID who added this record',
  CONSTRAINT fk_exception_record_transaction_all_shipment FOREIGN KEY (shipment_id) REFERENCES shipment_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_exception_record_transaction_all_type FOREIGN KEY (exception_type_id) REFERENCES exception_type_lookup_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_exception_record_transaction_all_addedby FOREIGN KEY (added_by) REFERENCES employee_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_exception_record_transaction_all_month_year (month_year),
  INDEX idx_exception_record_transaction_all_shipment_id (shipment_id),
  INDEX idx_exception_record_transaction_all_severity (severity_level),
  INDEX idx_exception_record_transaction_all_detected_by_user_id (detected_by_user_id),
  INDEX idx_exception_record_transaction_all_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exception_record_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  exception_record_id INT NOT NULL COMMENT 'FK to exception_record_transaction_all.id',
  previous_status INT NOT NULL COMMENT '1=active, 2=resolved, 3=closed, 4=deleted – status before change',
  new_status INT NOT NULL COMMENT '1=active, 2=resolved, 3=closed, 4=deleted – status after change',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'When the change occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition (e.g. USER_ACK, AUTO_ESCALATE)',
  remarks TEXT NULL COMMENT 'Additional remarks',
  CONSTRAINT fk_exception_record_life_cycle_all_exception FOREIGN KEY (exception_record_id) REFERENCES exception_record_transaction_all(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_exception_record_life_cycle_all_changedby FOREIGN KEY (changed_by) REFERENCES employee_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_exception_record_life_cycle_all_exception_record_id (exception_record_id),
  INDEX idx_exception_record_life_cycle_all_new_status (new_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE route_plan_exception_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  route_plan_exception_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Business ID for route plan exception (e.g. RPE-00001)',
  exception_transaction_id INT NOT NULL COMMENT 'FK to exception_record_transaction_all.id',
  original_route_id INT NOT NULL COMMENT 'FK to route_plan_details_all.id (original route)',
  alternative_route_id INT NOT NULL COMMENT 'FK to route_plan_details_all.id (alternative route)',
  generated_by INT NOT NULL COMMENT 'User ID who generated the alternative route',
  generated_on DATETIME NOT NULL COMMENT 'Timestamp when alternative route was generated',
  reason VARCHAR(500) COMMENT 'Reason for generating alternative route',
  priority INT NOT NULL DEFAULT 1 COMMENT '1=high, 2=medium, 3=low priority',
  estimated_delay_minutes INT COMMENT 'Estimated delay in minutes due to exception',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount associated with any surcharge',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount associated with any surcharge',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount associated with any surcharge',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  added_by INT NOT NULL COMMENT 'User ID who created this record',
  CONSTRAINT fk_route_plan_exception_all_exception_transaction FOREIGN KEY (exception_transaction_id) REFERENCES exception_record_transaction_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_route_plan_exception_all_original_route FOREIGN KEY (original_route_id) REFERENCES route_plan_details_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_route_plan_exception_all_alternative_route FOREIGN KEY (alternative_route_id) REFERENCES route_plan_details_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_route_plan_exception_all_exception_transaction_id (exception_transaction_id),
  INDEX idx_route_plan_exception_all_original_route_id (original_route_id),
  INDEX idx_route_plan_exception_all_alternative_route_id (alternative_route_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Finance & Billing  (4 tables)
-- ============================================================

CREATE TABLE invoice_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=archived',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  invoice_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Business ID of the invoice (e.g. INV‑00001)',
  shipment_id INT NOT NULL COMMENT 'FK to shipment_header_all.id',
  shipper_id INT NOT NULL COMMENT 'FK to factory_reset_all.id (business entity that ships the goods)',
  consignee_id INT NOT NULL COMMENT 'FK to factory_reset_all.id (business entity receiving the goods)',
  billing_address_id INT NOT NULL COMMENT 'Reference to address used for billing',
  issue_date DATE NOT NULL COMMENT 'Date invoice was issued',
  due_date DATE NOT NULL COMMENT 'Payment due date',
  sub_total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Sum of line item amounts before taxes',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  total_tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total tax (SGST+CGST+IGST)',
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Grand total payable',
  previous_total_amount DECIMAL(10,2) NULL COMMENT 'Previous total before amendment',
  after_total_amount DECIMAL(10,2) NULL COMMENT 'Total after amendment',
  added_by INT NOT NULL COMMENT 'User ID who created this record',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier used at creation',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of creator',
  CONSTRAINT fk_invoice_shipment FOREIGN KEY (shipment_id) REFERENCES shipment_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_invoice_shipper FOREIGN KEY (shipper_id) REFERENCES factory_reset_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_invoice_consignee FOREIGN KEY (consignee_id) REFERENCES factory_reset_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_invoice_month_year (month_year),
  INDEX idx_invoice_shipment_id (shipment_id),
  INDEX idx_invoice_shipper_id (shipper_id),
  INDEX idx_invoice_consignee_id (consignee_id),
  INDEX idx_invoice_billing_address_id (billing_address_id),
  INDEX idx_invoice_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE invoice_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  invoice_id INT NOT NULL COMMENT 'FK to invoice_transaction_all.id',
  previous_status INT NOT NULL COMMENT '1=generated, 2=sent, 3=paid, 4=cancelled, 5=adjusted',
  new_status INT NOT NULL COMMENT '1=generated, 2=sent, 3=paid, 4=cancelled, 5=adjusted',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who made the change',
  changed_on DATETIME NOT NULL COMMENT 'When the change occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  CONSTRAINT fk_lc_invoice FOREIGN KEY (invoice_id) REFERENCES invoice_transaction_all(id) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_lc_invoice_id (invoice_id),
  INDEX idx_lc_changed_on (changed_on)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_entry_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID',
  ledger_entry_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Business ID of the ledger entry (e.g. LED‑00001)',
  shipment_id INT NOT NULL COMMENT 'FK to shipment_header_all.id',
  account_id INT NOT NULL COMMENT 'FK to factory_reset_all.id (financial account impacted)',
  entry_type VARCHAR(20) NOT NULL COMMENT 'Debit or Credit',
  entry_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Amount of this ledger entry',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this transaction',
  previous_closing_balance DECIMAL(12,2) NULL COMMENT 'Balance before this entry',
  after_closing_balance DECIMAL(12,2) NULL COMMENT 'Balance after this entry',
  added_by INT NOT NULL COMMENT 'User ID who created this record',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier used at creation',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of creator',
  CONSTRAINT fk_ledger_shipment FOREIGN KEY (shipment_id) REFERENCES shipment_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ledger_account FOREIGN KEY (account_id) REFERENCES factory_reset_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_ledger_month_year (month_year),
  INDEX idx_ledger_shipment_id (shipment_id),
  INDEX idx_ledger_account_id (account_id),
  INDEX idx_ledger_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_log_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  audit_uuid VARCHAR(36) NOT NULL COMMENT 'UUID primary key for audit log entry',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID for audit entry',
  table_name VARCHAR(100) NOT NULL COMMENT 'Name of the table being audited',
  row_id VARCHAR(36) NOT NULL COMMENT 'Primary key value of the affected row',
  action VARCHAR(10) NOT NULL COMMENT 'INSERT|UPDATE|DELETE',
  before_state JSON NULL COMMENT 'JSON snapshot of row before change',
  after_state JSON NULL COMMENT 'JSON snapshot of row after change',
  actor_user_id VARCHAR(36) NOT NULL COMMENT 'User who performed the action',
  ip_address VARCHAR(45) NOT NULL COMMENT 'IP address of the actor',
  user_agent VARCHAR(255) NULL COMMENT 'User‑agent string of the client',
  device_id VARCHAR(50) NOT NULL COMMENT 'Device identifier used for the action',
  added_by INT NOT NULL COMMENT 'System user ID that logged this audit entry',
  INDEX idx_audit_month_year (month_year),
  INDEX idx_audit_table_name (table_name),
  INDEX idx_audit_row_id (row_id),
  INDEX idx_audit_actor_user_id (actor_user_id),
  INDEX idx_audit_device_id (device_id),
  UNIQUE KEY uk_audit_uuid (audit_uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Exception & Approval  (1 tables)
-- ============================================================

CREATE TABLE approval_task_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  approval_task_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID for the approval task (e.g. APR-00001)',
  exception_id INT NOT NULL COMMENT 'FK to exception_record_transaction_all.id',
  sort_order INT NOT NULL COMMENT 'Sequence number of the task within the approval workflow',
  task_name VARCHAR(100) NOT NULL COMMENT 'Descriptive name of the approval step',
  approver_role VARCHAR(50) NOT NULL COMMENT 'Role responsible for this approval (e.g. MANAGER, SUPERVISOR)',
  approver_id INT NOT NULL COMMENT 'User ID of the assigned approver',
  approval_status INT NOT NULL DEFAULT 1 COMMENT '1=pending, 2=approved, 3=rejected, 4=escalated',
  approval_comment VARCHAR(500) NULL COMMENT 'Approver remarks for this step',
  approval_timestamp DATETIME NULL COMMENT 'Date‑time when the approval decision was recorded',
  escalation_level INT NOT NULL DEFAULT 0 COMMENT 'Number of times this task has been escalated',
  due_date DATETIME NOT NULL COMMENT 'Deadline by which the task must be completed',
  reminder_sent_flag TINYINT NOT NULL DEFAULT 0 COMMENT '1=reminder sent, 0=not sent',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=archived',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  created_by INT NOT NULL COMMENT 'User ID who created this record',
  modified_by INT NOT NULL COMMENT 'User ID who last modified this record',
  CONSTRAINT fk_approval_task_details_all_exception_record_transaction_all FOREIGN KEY (exception_id) REFERENCES exception_record_transaction_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_approval_task_details_all_exception_id (exception_id),
  INDEX idx_approval_task_details_all_sort_order (sort_order),
  INDEX idx_approval_task_details_all_approver_id (approver_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- MODULE COMPLETE


-- ============================================================
-- MODULE: User & Security  (3 tables)
-- ============================================================

CREATE TABLE user_account_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=locked, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  user_account_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. UA‑00001)',
  username VARCHAR(50) NOT NULL COMMENT 'Login username',
  email VARCHAR(100) NOT NULL COMMENT 'User e‑mail address',
  password_hash VARCHAR(255) NOT NULL COMMENT 'Hashed password',
  first_name VARCHAR(50) NOT NULL COMMENT 'First name of the user',
  last_name VARCHAR(50) NOT NULL COMMENT 'Last name of the user',
  phone_number VARCHAR(20) COMMENT 'Contact phone number',
  role_id INT NOT NULL COMMENT 'FK to role definition (role_header_all)',
  organization_id INT NOT NULL COMMENT 'FK to organization the user belongs to (organization_header_all)',
  added_by INT NOT NULL COMMENT 'User ID who created this record (FK to user_account_header_all.id)',
  last_login_on DATETIME COMMENT 'Timestamp of last successful login',
  failed_login_attempts INT NOT NULL DEFAULT 0 COMMENT 'Consecutive failed login attempts',
  is_locked INT NOT NULL DEFAULT 0 COMMENT '1=account locked, 0=not locked',
  total_api_credentials INT NOT NULL DEFAULT 0 COMMENT 'Aggregate counter of API credentials issued to this user',
  last_api_credential_on DATETIME COMMENT 'Timestamp of most recent API credential issuance',
  address_line1 VARCHAR(150) COMMENT 'Primary address line',
  address_line2 VARCHAR(150) COMMENT 'Secondary address line',
  city VARCHAR(100) COMMENT 'City of residence',
  state VARCHAR(100) COMMENT 'State/Province',
  postal_code VARCHAR(20) COMMENT 'Postal/ZIP code',
  country VARCHAR(100) COMMENT 'Country',
  INDEX idx_user_account_header_all_username (username),
  INDEX idx_user_account_header_all_email (email),
  INDEX idx_user_account_header_all_role_id (role_id),
  INDEX idx_user_account_header_all_organization_id (organization_id),
  CONSTRAINT fk_user_account_header_all_added_by FOREIGN KEY (added_by) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_user_account_header_all_role_id FOREIGN KEY (role_id) REFERENCES role_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_user_account_header_all_organization_id FOREIGN KEY (organization_id) REFERENCES organization_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_account_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key (archived version)',
  status INT COMMENT '1=active, 2=inactive, 3=locked, 4=deleted',
  created_on DATETIME COMMENT 'Record creation timestamp (original)',
  modified_on DATETIME COMMENT 'Last modification timestamp (original)',
  user_account_id VARCHAR(20) COMMENT 'Human‑readable business ID (e.g. UA‑00001)',
  username VARCHAR(50) COMMENT 'Login username',
  email VARCHAR(100) COMMENT 'User e‑mail address',
  password_hash VARCHAR(255) COMMENT 'Hashed password',
  first_name VARCHAR(50) COMMENT 'First name of the user',
  last_name VARCHAR(50) COMMENT 'Last name of the user',
  phone_number VARCHAR(20) COMMENT 'Contact phone number',
  role_id INT COMMENT 'FK to role definition (role_header_all)',
  organization_id INT COMMENT 'FK to organization the user belongs to (organization_header_all)',
  added_by INT COMMENT 'User ID who created this record (FK to user_account_header_all.id)',
  last_login_on DATETIME COMMENT 'Timestamp of last successful login',
  failed_login_attempts INT COMMENT 'Consecutive failed login attempts',
  is_locked INT COMMENT '1=account locked, 0=not locked',
  total_api_credentials INT COMMENT 'Aggregate counter of API credentials issued to this user',
  last_api_credential_on DATETIME COMMENT 'Timestamp of most recent API credential issuance',
  address_line1 VARCHAR(150) COMMENT 'Primary address line',
  address_line2 VARCHAR(150) COMMENT 'Secondary address line',
  city VARCHAR(100) COMMENT 'City of residence',
  state VARCHAR(100) COMMENT 'State/Province',
  postal_code VARCHAR(20) COMMENT 'Postal/ZIP code',
  country VARCHAR(100) COMMENT 'Country',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User who performed the archive',
  archive_reason VARCHAR(255) COMMENT 'Reason for archiving this version',
  INDEX idx_user_account_archive_all_role_id (role_id),
  INDEX idx_user_account_archive_all_organization_id (organization_id),
  INDEX idx_user_account_archive_all_user_account_id (user_account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE api_credential_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=revoked, 3=expired, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  user_account_id INT NOT NULL COMMENT 'FK to user_account_header_all.id',
  sort_order INT NOT NULL COMMENT 'Sequence order of credentials for the user',
  api_key VARCHAR(100) NOT NULL COMMENT 'Public API key',
  token VARCHAR(255) NOT NULL COMMENT 'Secret token associated with the API key',
  expires_on DATETIME COMMENT 'Expiration datetime of the credential',
  is_active INT NOT NULL DEFAULT 1 COMMENT '1=currently active, 0=inactive',
  created_by INT NOT NULL COMMENT 'User ID who created the credential (FK to user_account_header_all.id)',
  last_used_on DATETIME COMMENT 'Timestamp of last successful API call using this credential',
  usage_count INT NOT NULL DEFAULT 0 COMMENT 'Number of times this credential has been used',
  description VARCHAR(255) COMMENT 'Human readable description of the credential purpose',
  CONSTRAINT fk_api_credential_details_all_user_account_id FOREIGN KEY (user_account_id) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_api_credential_details_all_created_by FOREIGN KEY (created_by) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_api_credential_details_all_user_account_id (user_account_id),
  INDEX idx_api_credential_details_all_api_key (api_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Notification Service  (3 tables)
-- ============================================================

CREATE TABLE notification_event_transaction_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=failed',
  month_year VARCHAR(7) NOT NULL COMMENT 'YYYY-MM for partitioning',
  transaction_ref VARCHAR(30) NOT NULL UNIQUE COMMENT 'Human‑readable transaction ID for this notification event',
  initiator_user_id INT NOT NULL COMMENT 'User who triggered the event',
  recipient_user_id INT NOT NULL COMMENT 'User who should receive the notification',
  shipment_id INT NOT NULL COMMENT 'Related shipment (FK to shipment_header_all.id)',
  event_type VARCHAR(50) NOT NULL COMMENT 'Type of event (e.g., STATUS_CHANGE, INVOICE_GENERATED)',
  before_status INT COMMENT 'Previous status value (integer code)',
  after_status INT COMMENT 'New status value (integer code)',
  invoice_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Financial amount associated with the event, if any',
  sgst_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'State GST amount (if financial event)',
  cgst_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Central GST amount (if financial event)',
  igst_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Integrated GST amount (if financial event)',
  sgst_percentage DECIMAL(5,2) DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) DEFAULT 0.00 COMMENT 'CGST rate applied',
  added_by INT NOT NULL COMMENT 'User ID who created this event record',
  device_id VARCHAR(50) COMMENT 'Device identifier from which the event originated',
  ip_address VARCHAR(45) COMMENT 'IP address of the source',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_notification_event_shipment FOREIGN KEY (shipment_id) REFERENCES shipment_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_notification_event_initiator_user FOREIGN KEY (initiator_user_id) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_notification_event_recipient_user FOREIGN KEY (recipient_user_id) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_notification_event_month_year (month_year),
  INDEX idx_notification_event_shipment_id (shipment_id),
  INDEX idx_notification_event_initiator_user_id (initiator_user_id),
  INDEX idx_notification_event_recipient_user_id (recipient_user_id),
  INDEX idx_notification_event_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notification_message_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=queued, 2=sent, 3=failed, 4=cancelled',
  event_id INT NOT NULL COMMENT 'FK to notification_event_transaction_all.id',
  sort_order INT NOT NULL COMMENT 'Sequence number of the message for the same event',
  template_id VARCHAR(30) NOT NULL COMMENT 'Identifier of the message template used',
  channel_id INT NOT NULL COMMENT 'FK to notification_channel_lookup_all.id',
  recipient_user_id INT NOT NULL COMMENT 'User who will receive the notification',
  recipient_contact VARCHAR(255) NOT NULL COMMENT 'Contact detail (email, phone, device token) used for delivery',
  payload JSON COMMENT 'Rendered message payload (JSON for dynamic fields)',
  delivery_status INT NOT NULL DEFAULT 0 COMMENT '0=pending, 1=delivered, 2=failed',
  failure_reason VARCHAR(500) COMMENT 'Reason for delivery failure, if any',
  sent_on DATETIME COMMENT 'Timestamp when the message was actually sent',
  added_by INT NOT NULL COMMENT 'User ID who queued this message',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  CONSTRAINT fk_message_event FOREIGN KEY (event_id) REFERENCES notification_event_transaction_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_message_channel FOREIGN KEY (channel_id) REFERENCES notification_channel_lookup_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_message_recipient_user FOREIGN KEY (recipient_user_id) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_message_event_id (event_id),
  INDEX idx_message_channel_id (channel_id),
  INDEX idx_message_recipient_user_id (recipient_user_id),
  INDEX idx_message_sort_order (sort_order),
  INDEX idx_message_template_id (template_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notification_channel_lookup_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deprecated',
  channel_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Short code for the channel (e.g., EMAIL, SMS, PUSH)',
  channel_name VARCHAR(100) NOT NULL COMMENT 'Human readable name of the channel',
  description VARCHAR(255) COMMENT 'Detailed description of the channel capabilities',
  is_active TINYINT NOT NULL DEFAULT 1 COMMENT '1=channel can be used, 0=channel disabled',
  max_daily_limit INT NOT NULL DEFAULT 1000 COMMENT 'Maximum number of messages allowed per day for this channel',
  priority INT NOT NULL DEFAULT 1 COMMENT 'Priority order when multiple channels are eligible (lower = higher priority)',
  provider_name VARCHAR(100) COMMENT 'External service provider name (e.g., Twilio, SendGrid)',
  provider_endpoint VARCHAR(255) COMMENT 'API endpoint URL of the provider',
  retry_attempts INT NOT NULL DEFAULT 3 COMMENT 'Number of retry attempts on failure',
  created_by INT NOT NULL COMMENT 'User ID who created this channel record',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  INDEX idx_channel_is_active (is_active),
  INDEX idx_channel_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE


-- ============================================================
-- MODULE: Reporting & Analytics  (5 tables)
-- ============================================================

CREATE TABLE report_request_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=pending, 2=processing, 3=completed, 4=failed, 5=cancelled',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  report_request_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. RR-00001)',
  report_type VARCHAR(50) NOT NULL COMMENT 'Type of report requested (e.g. ShipmentSummary, DriverPerformance)',
  output_format VARCHAR(20) NOT NULL COMMENT 'Desired output format (PDF, CSV, XLSX, JSON)',
  filters JSON NOT NULL COMMENT 'JSON object containing filter criteria supplied by the user',
  parameters TEXT COMMENT 'Additional free‑form parameters for the reporting engine',
  requested_on DATETIME NOT NULL COMMENT 'Timestamp when the request was submitted',
  scheduled_run DATETIME NULL COMMENT 'If set, the report is scheduled to run at this time',
  total_records_expected BIGINT COMMENT 'Estimated total records that will be processed for this report',
  count_generated INT COMMENT 'Number of result rows actually generated',
  last_generated_on DATETIME NULL COMMENT 'Timestamp of the most recent generation attempt',
  priority INT NOT NULL DEFAULT 2 COMMENT '1=low, 2=medium, 3=high – processing priority',
  is_async TINYINT NOT NULL DEFAULT 1 COMMENT '1=run asynchronously, 0=run synchronously',
  notification_channel_id INT NULL COMMENT 'FK to notification_channel_lookup_all.id for delivery',
  added_by INT NOT NULL COMMENT 'User ID who created this request',
  shipment_id VARCHAR(20) NULL COMMENT 'Related shipment business ID, if report is shipment‑specific',
  driver_id VARCHAR(20) NULL COMMENT 'Related driver business ID, if report is driver‑specific',
  vehicle_id VARCHAR(20) NULL COMMENT 'Related vehicle business ID, if report is vehicle‑specific',
  total_items INT COMMENT 'Aggregate counter: total line items produced',
  count_errors INT COMMENT 'Aggregate counter: number of errors encountered during generation',
  last_error_on DATETIME NULL COMMENT 'Timestamp of the most recent error, if any',
  CONSTRAINT fk_reportrequest_user FOREIGN KEY (added_by) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reportrequest_notification FOREIGN KEY (notification_channel_id) REFERENCES notification_channel_lookup_all(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_reportrequest_report_type (report_type),
  INDEX idx_reportrequest_status (status),
  INDEX idx_reportrequest_added_by (added_by),
  INDEX idx_reportrequest_driver_id (driver_id),
  INDEX idx_reportrequest_shipment_id (shipment_id),
  INDEX idx_reportrequest_vehicle_id (vehicle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE report_request_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key (archived version)',
  status INT COMMENT 'Status at time of archive',
  created_on DATETIME COMMENT 'Record creation timestamp (original)',
  modified_on DATETIME COMMENT 'Last modification timestamp (original)',
  report_request_id VARCHAR(20) COMMENT 'Human‑readable business ID (e.g. RR-00001)',
  report_type VARCHAR(50) COMMENT 'Type of report requested',
  output_format VARCHAR(20) COMMENT 'Desired output format',
  filters JSON COMMENT 'Filter criteria supplied by the user',
  parameters TEXT COMMENT 'Additional free‑form parameters',
  requested_on DATETIME COMMENT 'Timestamp when the request was submitted',
  scheduled_run DATETIME COMMENT 'Scheduled run timestamp, if any',
  total_records_expected BIGINT COMMENT 'Estimated total records for the report',
  count_generated INT COMMENT 'Number of result rows generated',
  last_generated_on DATETIME COMMENT 'Timestamp of most recent generation',
  priority INT COMMENT 'Processing priority (1=low,2=medium,3=high)',
  is_async TINYINT COMMENT 'Async flag (1=async,0=sync)',
  notification_channel_id INT COMMENT 'FK to notification_channel_lookup_all',
  added_by INT COMMENT 'User ID who created the request',
  shipment_id VARCHAR(20) COMMENT 'Related shipment business ID',
  driver_id VARCHAR(20) COMMENT 'Related driver business ID',
  vehicle_id VARCHAR(20) COMMENT 'Related vehicle business ID',
  total_items INT COMMENT 'Aggregate counter: total line items produced',
  count_errors INT COMMENT 'Aggregate counter: number of errors encountered',
  last_error_on DATETIME COMMENT 'Timestamp of most recent error',
  archived_on DATETIME NOT NULL COMMENT 'When this version was archived',
  archived_by INT NOT NULL COMMENT 'User ID who performed the archive',
  archive_reason VARCHAR(255) COMMENT 'Reason for archiving this version',
  INDEX idx_report_request_archive_all_report_request_id (report_request_id),
  INDEX idx_report_request_archive_all_notification_channel_id (notification_channel_id),
  INDEX idx_report_request_archive_all_shipment_id (shipment_id),
  INDEX idx_report_request_archive_all_driver_id (driver_id),
  INDEX idx_report_request_archive_all_vehicle_id (vehicle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE report_result_details_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  report_request_id INT NOT NULL COMMENT 'FK to report_request_header_all.id',
  sort_order INT NOT NULL COMMENT 'Sequence number for ordering result rows',
  column_name VARCHAR(100) NOT NULL COMMENT 'Name of the data column represented in this row',
  column_value TEXT COMMENT 'String representation of the column value',
  numeric_value DECIMAL(10,2) NULL COMMENT 'Numeric value when applicable (e.g., amount, weight)',
  date_value DATETIME NULL COMMENT 'Date/time value when applicable',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount (if applicable)',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount (if applicable)',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount (if applicable)',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance after this result row (if ledger‑type report)',
  added_by INT NOT NULL COMMENT 'User ID who triggered the generation of this row',
  CONSTRAINT fk_resultdetail_reportrequest FOREIGN KEY (report_request_id) REFERENCES report_request_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_resultdetail_addedby FOREIGN KEY (added_by) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_resultdetail_reportrequest (report_request_id),
  INDEX idx_resultdetail_sortorder (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE scheduled_report_header_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=paused, 4=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  scheduled_report_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human‑readable business ID (e.g. SR-00001)',
  report_type VARCHAR(50) NOT NULL COMMENT 'Type of report to be generated on schedule',
  output_format VARCHAR(20) NOT NULL COMMENT 'Desired output format for scheduled deliveries',
  schedule_cron VARCHAR(100) NOT NULL COMMENT 'Cron expression defining execution frequency',
  next_run_on DATETIME NOT NULL COMMENT 'Timestamp of the next scheduled execution',
  last_run_on DATETIME NULL COMMENT 'Timestamp of the most recent execution',
  last_success_on DATETIME NULL COMMENT 'Timestamp of the most recent successful execution',
  last_failure_on DATETIME NULL COMMENT 'Timestamp of the most recent failure',
  delivery_email VARCHAR(255) NULL COMMENT 'Email address to which the report will be sent',
  delivery_channel_id INT NULL COMMENT 'FK to notification_channel_lookup_all.id for alternative delivery',
  is_active TINYINT NOT NULL DEFAULT 1 COMMENT '1=enabled, 0=disabled',
  added_by INT NOT NULL COMMENT 'User ID who created the scheduled report definition',
  shipment_id VARCHAR(20) NULL COMMENT 'Related shipment business ID, if schedule is shipment‑specific',
  driver_id VARCHAR(20) NULL COMMENT 'Related driver business ID, if schedule is driver‑specific',
  vehicle_id VARCHAR(20) NULL COMMENT 'Related vehicle business ID, if schedule is vehicle‑specific',
  total_executions INT COMMENT 'Aggregate counter: total number of times the schedule has run',
  successful_executions INT COMMENT 'Aggregate counter: number of successful executions',
  failed_executions INT COMMENT 'Aggregate counter: number of failed executions',
  last_error_message VARCHAR(500) NULL COMMENT 'Error message from the most recent failure, if any',
  sgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'State GST amount (if report includes financial data)',
  cgst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Central GST amount (if report includes financial data)',
  igst_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Integrated GST amount (if report includes financial data)',
  sgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'SGST rate applied',
  cgst_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'CGST rate applied',
  closing_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Running balance snapshot after each execution (if applicable)',
  CONSTRAINT fk_schedreport_user FOREIGN KEY (added_by) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_schedreport_deliverychannel FOREIGN KEY (delivery_channel_id) REFERENCES notification_channel_lookup_all(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_schedreport_type (report_type),
  INDEX idx_schedreport_status (status),
  INDEX idx_schedreport_nextrun (next_run_on),
  INDEX idx_schedreport_driver_id (driver_id),
  INDEX idx_schedreport_shipment_id (shipment_id),
  INDEX idx_schedreport_vehicle_id (vehicle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE scheduled_report_archive_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted, 4=archived',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  scheduled_report_id VARCHAR(20) NOT NULL COMMENT 'Human‑readable business ID (e.g. SRPT-00001)',
  report_name VARCHAR(255) NOT NULL COMMENT 'Descriptive name of the report',
  report_type VARCHAR(100) NOT NULL COMMENT 'Type/category of the report (e.g. shipment_summary, financial)',
  schedule_expression VARCHAR(100) NOT NULL COMMENT 'Cron‑style expression defining schedule',
  next_run_on DATETIME NULL COMMENT 'Planned next execution datetime',
  last_run_on DATETIME NULL COMMENT 'Datetime when the report was last executed',
  is_active TINYINT NOT NULL DEFAULT 1 COMMENT '1=scheduled, 0=paused',
  parameters_json TEXT NULL COMMENT 'JSON string of report parameters',
  output_format VARCHAR(50) NOT NULL COMMENT 'File format of generated report (e.g. CSV, PDF, XLSX)',
  destination_path VARCHAR(500) NOT NULL COMMENT 'Filesystem or S3 path where report is stored',
  generated_by INT NOT NULL COMMENT 'User ID who created the schedule',
  retention_days INT NOT NULL DEFAULT 30 COMMENT 'Number of days to retain generated reports',
  priority INT NOT NULL DEFAULT 5 COMMENT 'Execution priority (lower = higher priority)',
  added_by INT NOT NULL COMMENT 'User ID who added this schedule',
  archived_on DATETIME NOT NULL COMMENT 'Timestamp when this version was archived',
  archived_by INT NOT NULL COMMENT 'User ID who performed the archive',
  archive_reason VARCHAR(255) NULL COMMENT 'Reason for archiving this record',
  INDEX idx_scheduled_report_archive_all_report_id (scheduled_report_id),
  INDEX idx_scheduled_report_archive_all_next_run_on (next_run_on)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- MODULE COMPLETE

CREATE TABLE user_account_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  user_account_id INT NOT NULL COMMENT 'FK to user_account_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous account status',
  new_status INT NOT NULL COMMENT 'New account status',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'When the change occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  CONSTRAINT fk_useraccount_lifecycle_useraccount FOREIGN KEY (user_account_id) REFERENCES user_account_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_useraccount_lifecycle_useraccount_id (user_account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipment_request_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  shipment_request_id INT NOT NULL COMMENT 'FK to shipment_request_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous lifecycle status',
  new_status INT NOT NULL COMMENT 'New lifecycle status',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'When the change occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  CONSTRAINT fk_shipmentrequest_lifecycle_shipmentrequest FOREIGN KEY (shipment_request_id) REFERENCES shipment_request_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_shipmentrequest_lifecycle_shipmentrequest_id (shipment_request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE scheduled_report_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  scheduled_report_id INT NOT NULL COMMENT 'FK to scheduled_report_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous lifecycle status',
  new_status INT NOT NULL COMMENT 'New lifecycle status',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'When the change occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  CONSTRAINT fk_schedreport_lifecycle_schedreport FOREIGN KEY (scheduled_report_id) REFERENCES scheduled_report_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_schedreport_lifecycle_schedreport_id (scheduled_report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE report_request_life_cycle_all (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'System surrogate key',
  status INT NOT NULL DEFAULT 1 COMMENT '1=active, 2=inactive, 3=deleted',
  created_on DATETIME NOT NULL COMMENT 'Record creation timestamp',
  modified_on DATETIME NOT NULL COMMENT 'Last modification timestamp',
  report_request_id INT NOT NULL COMMENT 'FK to report_request_header_all.id',
  previous_status INT NOT NULL COMMENT 'Previous lifecycle status',
  new_status INT NOT NULL COMMENT 'New lifecycle status',
  reason VARCHAR(500) NULL COMMENT 'Reason for status change',
  changed_by INT NOT NULL COMMENT 'User who performed the change',
  changed_on DATETIME NOT NULL COMMENT 'When the change occurred',
  trigger_event VARCHAR(100) NOT NULL COMMENT 'What triggered this transition',
  remarks TEXT NULL COMMENT 'Additional remarks',
  CONSTRAINT fk_reportrequest_lifecycle_reportrequest FOREIGN KEY (report_request_id) REFERENCES report_request_header_all(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_reportrequest_lifecycle_reportrequest_id (report_request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
-- ============================================================
-- End of schema
-- ============================================================
