-- Car3DB v2 — sample schema
-- Data date: 2026-11-01
-- Full database: https://car3db.gumroad.com/l/enwrs
--
-- This file is the exact DDL used by the release dump. It is safe to run on an
-- empty database; insert order must follow the FK chain
--   makes -> models -> generations -> series -> trims -> specs / specification_values

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------- hierarchy

CREATE TABLE `makes` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type_id` int(11) NOT NULL DEFAULT 1,
  `date_create` int(11) DEFAULT NULL,
  `date_update` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_makes_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `models` (
  `id` bigint(20) NOT NULL,
  `make_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type_id` int(11) NOT NULL DEFAULT 1,
  `date_create` int(11) DEFAULT NULL,
  `date_update` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_models_make` (`make_id`),
  KEY `idx_models_name` (`name`),
  CONSTRAINT `fk_models_make` FOREIGN KEY (`make_id`) REFERENCES `makes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `generations` (
  `id` bigint(20) NOT NULL,
  `model_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `year_begin` int(11) DEFAULT NULL,
  `year_end` int(11) DEFAULT NULL,
  `type_id` int(11) NOT NULL DEFAULT 1,
  `date_create` int(11) DEFAULT NULL,
  `date_update` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_generations_model` (`model_id`),
  KEY `idx_generations_years` (`year_begin`,`year_end`),
  CONSTRAINT `fk_generations_model` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `series` (
  `id` bigint(20) NOT NULL,
  `model_id` bigint(20) DEFAULT NULL,
  `generation_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `type_id` int(11) NOT NULL DEFAULT 1,
  `date_create` int(11) DEFAULT NULL,
  `date_update` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_series_model` (`model_id`),
  KEY `idx_series_generation` (`generation_id`),
  CONSTRAINT `fk_series_model` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_series_generation` FOREIGN KEY (`generation_id`) REFERENCES `generations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `trims` (
  `id` bigint(20) NOT NULL,
  `series_id` bigint(20) NOT NULL,
  `model_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `start_production_year` int(11) DEFAULT NULL,
  `end_production_year` int(11) DEFAULT NULL,
  `type_id` int(11) NOT NULL DEFAULT 1,
  `specs_status` varchar(16) NOT NULL DEFAULT 'none',
  `date_create` int(11) DEFAULT NULL,
  `date_update` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_trims_series` (`series_id`),
  KEY `idx_trims_name` (`name`),
  CONSTRAINT `fk_trims_series` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------- specification (v2)

CREATE TABLE `specifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  `api_id` bigint(20) DEFAULT NULL,
  `spec_key` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_specifications_name` (`name`),
  KEY `idx_specifications_group` (`group_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `specification_values` (
  `trim_id` bigint(20) NOT NULL,
  `specification_id` bigint(20) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `unit` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`trim_id`,`specification_id`),
  KEY `idx_specvalues_spec` (`specification_id`),
  CONSTRAINT `fk_specvalues_trim` FOREIGN KEY (`trim_id`) REFERENCES `trims` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_specvalues_spec` FOREIGN KEY (`specification_id`) REFERENCES `specifications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------- v1 compatible JSON blob

CREATE TABLE `specs` (
  `trim_id` bigint(20) NOT NULL,
  `specs_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
      CHECK (json_valid(`specs_json`)),
  `specs_raw_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
      CHECK (json_valid(`specs_raw_json`)),
  `specs_grouped_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
      CHECK (json_valid(`specs_grouped_json`)),
  `key_specs_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
      CHECK (json_valid(`key_specs_json`)),
  PRIMARY KEY (`trim_id`),
  CONSTRAINT `fk_specs_trim` FOREIGN KEY (`trim_id`) REFERENCES `trims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------------- equipment

CREATE TABLE `equipments` (
  `id` bigint(20) NOT NULL,
  `trim_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_equipments_trim` (`trim_id`),
  CONSTRAINT `fk_equipment_trim` FOREIGN KEY (`trim_id`) REFERENCES `trims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `option_values` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `equipment_id` bigint(20) NOT NULL,
  `name` varchar(512) NOT NULL,
  `value` varchar(1024) DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_option_values_equipment` (`equipment_id`),
  CONSTRAINT `fk_option_values_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------------ sample

-- The reference trim used throughout the docs (Volkswagen Golf VII Alltrack).
INSERT INTO `makes` (`id`, `name`, `type_id`) VALUES (184, 'Volkswagen', 1);

INSERT INTO `models` (`id`, `make_id`, `name`, `type_id`) VALUES (1908, 184, 'Golf', 1);

INSERT INTO `generations` (`id`, `model_id`, `name`, `year_begin`, `year_end`, `type_id`)
VALUES (2160, 1908, '7 generation [2012 - 2017]', 2012, 2017, 1);

INSERT INTO `series` (`id`, `model_id`, `generation_id`, `name`, `type_id`)
VALUES (51487, 1908, 2160, 'Alltrack wagon 5-doors', 1);

INSERT INTO `trims` (`id`, `series_id`, `model_id`, `name`, `type_id`, `specs_status`)
VALUES (220224, 51487, 1908, '2.0 TDI DSG 4MOTION (184 hp)', 1, 'full');

INSERT INTO `specifications` (`id`, `name`, `group_name`, `spec_key`) VALUES
(1, 'Body type', 'Bodywork', 'body_type'),
(2, 'Length', 'Bodywork', 'length_mm'),
(3, 'Engine power', 'Engine', 'engine_power_hp'),
(4, 'Maximum torque', 'Engine', 'torque_nm'),
(5, 'Gearbox type', 'Gearbox and handling', 'gearbox_type'),
(6, 'Drive wheels', 'Gearbox and handling', 'drive_wheels'),
(7, 'Max speed', 'Operating characteristics', 'max_speed_kmh'),
(8, 'Acceleration (0-100 km/h)', 'Operating characteristics', 'acceleration_0_100_s'),
(9, 'Fuel', 'Operating characteristics', 'fuel'),
(10, 'Curb weight', 'Weight and capacity', 'curb_weight_kg');

INSERT INTO `specification_values` (`trim_id`, `specification_id`, `value`, `unit`) VALUES
(220224, 1, 'Wagon', NULL),
(220224, 2, '4578', 'mm'),
(220224, 3, '184', 'hp'),
(220224, 4, '380', 'N*m'),
(220224, 5, 'robot', NULL),
(220224, 6, 'All wheel drive (AWD)', NULL),
(220224, 7, '219', 'km/h'),
(220224, 8, '7.8', 's'),
(220224, 9, 'diesel', NULL),
(220224, 10, '1584', 'kg');

INSERT INTO `specs` (`trim_id`, `specs_json`, `specs_raw_json`, `specs_grouped_json`, `key_specs_json`) VALUES
(220224,
 '{"body_type":"Wagon","length_mm":"4578 mm","engine_power_hp":"184 hp","torque_nm":"380 N*m","gearbox_type":"robot","drive_wheels":"All wheel drive (AWD)","max_speed_kmh":"219 km/h","acceleration_0_100_s":"7.8 s","fuel":"diesel","curb_weight_kg":"1584 kg"}',
 '{"Body type":"Wagon","Length":"4578 mm","Engine power":"184 hp","Maximum torque":"380 N*m","Gearbox type":"robot","Drive wheels":"All wheel drive (AWD)","Max speed":"219 km/h","Acceleration (0-100 km/h)":"7.8 s","Fuel":"diesel","Curb weight":"1584 kg"}',
 '[{"name":"Bodywork","items":[{"name":"Body type","value":"Wagon","unit":null,"text":"Wagon"},{"name":"Length","value":"4578","unit":"mm","text":"4578 mm"}]},{"name":"Engine","items":[{"name":"Engine power","value":"184","unit":"hp","text":"184 hp"},{"name":"Maximum torque","value":"380","unit":"N*m","text":"380 N*m"}]}]',
 '{"engineVolume":1968,"power":184,"transmission":"robot","transmissionGears":6,"drive":"All wheel drive (AWD)","bodyType":"Wagon","seats":5,"acceleration":7.8,"fuelConsumptionMixed":5,"maxSpeed":219}');

-- The complete dump has 403 makes, 4,742 models, 10,223 generations,
-- 15,546 series, 98,239 trims and 4,256,122 specification values.
-- https://car3db.gumroad.com/l/enwrs
