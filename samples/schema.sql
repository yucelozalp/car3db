-- Car3DB Database Schema
-- Sample schema showing table structure
-- Full database available at: https://car3db.gumroad.com/l/enwrs

-- Manufacturers Table
CREATE TABLE makes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  country VARCHAR(100),
  founded_year INT,
  INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Models Table
CREATE TABLE models (
  id INT PRIMARY KEY AUTO_INCREMENT,
  make_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  INDEX idx_make_id (make_id),
  INDEX idx_name (name),
  FOREIGN KEY (make_id) REFERENCES makes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Generations Table
CREATE TABLE generations (
  id INT PRIMARY KEY AUTO_INCREMENT,
  model_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  year_begin INT,
  year_end INT,
  INDEX idx_model_id (model_id),
  INDEX idx_years (year_begin, year_end),
  FOREIGN KEY (model_id) REFERENCES models(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Series Table
CREATE TABLE series (
  id INT PRIMARY KEY AUTO_INCREMENT,
  model_id INT NOT NULL,
  generation_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  INDEX idx_model_id (model_id),
  INDEX idx_generation_id (generation_id),
  FOREIGN KEY (model_id) REFERENCES models(id),
  FOREIGN KEY (generation_id) REFERENCES generations(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Trims Table
CREATE TABLE trims (
  id INT PRIMARY KEY AUTO_INCREMENT,
  series_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  year INT,
  INDEX idx_series_id (series_id),
  INDEX idx_name (name),
  FOREIGN KEY (series_id) REFERENCES series(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Specifications Table (JSON format)
CREATE TABLE specs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  trim_id INT NOT NULL UNIQUE,
  specs_json TEXT,
  specs_raw_json TEXT,
  INDEX idx_trim_id (trim_id),
  FOREIGN KEY (trim_id) REFERENCES trims(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Equipment Table (Individual columns)
CREATE TABLE equipments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  trim_id INT NOT NULL UNIQUE,
  
  -- Body & Classification
  body_type VARCHAR(100),
  doors INT,
  seats VARCHAR(50),
  
  -- Dimensions (showing subset)
  length_mm VARCHAR(50),
  width_mm VARCHAR(50),
  height_mm VARCHAR(50),
  wheelbase_mm VARCHAR(50),
  
  -- Engine (showing subset)
  engine_type VARCHAR(100),
  engine_capacity_cm3 VARCHAR(50),
  engine_power_hp VARCHAR(50),
  torque_nm VARCHAR(50),
  
  -- Performance
  max_speed_kmh VARCHAR(50),
  acceleration_0_100_s VARCHAR(50),
  
  -- Fuel Economy
  city_consumption_l_100km VARCHAR(50),
  highway_consumption_l_100km VARCHAR(50),
  mixed_consumption_l_100km VARCHAR(50),
  
  -- ... and 40+ more specification fields
  
  INDEX idx_trim_id (trim_id),
  FOREIGN KEY (trim_id) REFERENCES trims(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sample Data (10 manufacturers)
INSERT INTO makes (id, name, country, founded_year) VALUES
(1, 'Toyota', 'Japan', 1937),
(2, 'BMW', 'Germany', 1916),
(3, 'Mercedes-Benz', 'Germany', 1926),
(4, 'Ford', 'USA', 1903),
(5, 'Volkswagen', 'Germany', 1937),
(6, 'Honda', 'Japan', 1948),
(7, 'Nissan', 'Japan', 1933),
(8, 'Audi', 'Germany', 1909),
(9, 'Chevrolet', 'USA', 1911),
(10, 'Hyundai', 'South Korea', 1967);

-- Full database with 262,827+ records available at:
-- https://car3db.gumroad.com/l/enwrs

