# 📋 Database Schema Documentation

Complete schema documentation for Car3DB automotive database.

---

## 🗄️ Table Overview

Car3DB consists of 7 main tables with proper relationships:

```
makes → models → generations
              ↘ series → trims → specs
                              ↘ equipments
```

---

## 📊 Tables

### 1. `makes` - Automotive Manufacturers

Stores all automotive brand/manufacturer information.

```sql
CREATE TABLE makes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  country VARCHAR(100),
  founded_year INT,
  INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Records**: 403  
**Example**: Toyota, BMW, Mercedes-Benz, Ford, etc.

---

### 2. `models` - Vehicle Models

Contains all vehicle models for each manufacturer.

```sql
CREATE TABLE models (
  id INT PRIMARY KEY AUTO_INCREMENT,
  make_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  INDEX idx_make_id (make_id),
  INDEX idx_name (name),
  FOREIGN KEY (make_id) REFERENCES makes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Records**: 4,742  
**Example**: RAV4, 3 Series, C-Class, Mustang, etc.

---

### 3. `generations` - Model Generations

Stores generation information with year ranges.

```sql
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
```

**Records**: 10,223  
**Example**: RAV4 IV (2013-2018), F30 (2012-2019), etc.

---

### 4. `series` - Vehicle Series

Contains series/variant information.

```sql
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
```

**Records**: 15,546  
**Example**: RAV4 2.0 CVT, RAV4 2.5 AWD, etc.

---

### 5. `trims` - Trim Levels

Stores all trim level configurations.

```sql
CREATE TABLE trims (
  id INT PRIMARY KEY AUTO_INCREMENT,
  series_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  year INT,
  INDEX idx_series_id (series_id),
  INDEX idx_name (name),
  FOREIGN KEY (series_id) REFERENCES series(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Records**: 100,126+  
**Example**: Base, Limited, XLE, Sport, Premium, etc.

---

### 6. `specs` - Specifications (JSON)

Contains detailed specifications in JSON format.

```sql
CREATE TABLE specs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  trim_id INT NOT NULL UNIQUE,
  specs_json TEXT,
  specs_raw_json TEXT,
  INDEX idx_trim_id (trim_id),
  FOREIGN KEY (trim_id) REFERENCES trims(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Records**: 98,239+

**specs_json structure**:
```json
{
  "engine_type": "Gasoline",
  "engine_capacity_cm3": "1998 cm3",
  "engine_power_hp": "147 hp",
  "torque_nm": "199 N*m",
  "max_speed_kmh": "180 km/h",
  "acceleration_0_100_s": "10.2 s",
  "fuel_tank_l": "63 l",
  "city_consumption_l_100km": "10.3 l",
  "highway_consumption_l_100km": "6.6 l",
  "mixed_consumption_l_100km": "8 l"
  // ... and 50+ more fields
}
```

---

### 7. `equipments` - Equipment Details

Detailed equipment information with individual columns.

```sql
CREATE TABLE equipments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  trim_id INT NOT NULL UNIQUE,
  
  -- Body & Classification
  body_type VARCHAR(100),
  car_class VARCHAR(100),
  doors INT,
  seats VARCHAR(50),
  steering_wheel_position VARCHAR(50),
  country VARCHAR(100),
  
  -- Dimensions
  length_mm VARCHAR(50),
  width_mm VARCHAR(50),
  height_mm VARCHAR(50),
  wheelbase_mm VARCHAR(50),
  ground_clearance_mm VARCHAR(50),
  front_track_mm VARCHAR(50),
  rear_track_mm VARCHAR(50),
  wheel_size VARCHAR(100),
  turning_circle_m VARCHAR(50),
  
  -- Weight & Capacity
  curb_weight_kg VARCHAR(50),
  full_weight_kg VARCHAR(50),
  payload_kg VARCHAR(50),
  trunk_min_l VARCHAR(50),
  trunk_max_l VARCHAR(50),
  fuel_tank_l VARCHAR(50),
  
  -- Engine
  engine_type VARCHAR(100),
  engine_layout VARCHAR(100),
  engine_capacity_cm3 VARCHAR(50),
  engine_power_hp VARCHAR(50),
  max_power_rpm VARCHAR(50),
  boost_type VARCHAR(100),
  torque_nm VARCHAR(50),
  torque_rpm VARCHAR(50),
  cylinder_layout VARCHAR(50),
  cylinders VARCHAR(10),
  valves_per_cylinder VARCHAR(10),
  injection_type VARCHAR(100),
  compression_ratio VARCHAR(50),
  bore_mm VARCHAR(50),
  stroke_mm VARCHAR(50),
  engine_code VARCHAR(100),
  engine_model VARCHAR(100),
  timing VARCHAR(100),
  
  -- Performance
  max_speed_kmh VARCHAR(50),
  acceleration_0_100_s VARCHAR(50),
  
  -- Fuel
  fuel_octane VARCHAR(50),
  city_consumption_l_100km VARCHAR(50),
  highway_consumption_l_100km VARCHAR(50),
  mixed_consumption_l_100km VARCHAR(50),
  cruising_range_km VARCHAR(100),
  flow_calc_method VARCHAR(100),
  
  -- Transmission & Drivetrain
  gearbox_type VARCHAR(100),
  gears VARCHAR(10),
  drive_wheels VARCHAR(50),
  
  -- Suspension & Brakes
  front_suspension VARCHAR(100),
  rear_suspension VARCHAR(100),
  front_brakes VARCHAR(100),
  rear_brakes VARCHAR(100),
  
  INDEX idx_trim_id (trim_id),
  INDEX idx_body_type (body_type),
  INDEX idx_engine_type (engine_type),
  FOREIGN KEY (trim_id) REFERENCES trims(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Records**: 33,548+

---

## 🔗 Relationships

```
makes (1) ←→ (N) models
models (1) ←→ (N) generations
models (1) ←→ (N) series
generations (1) ←→ (N) series
series (1) ←→ (N) trims
trims (1) ←→ (1) specs
trims (1) ←→ (1) equipments
```

---

## 📊 Sample Queries

### Get all models for a manufacturer
```sql
SELECT m.name AS make, mo.name AS model
FROM makes m
JOIN models mo ON m.id = mo.make_id
WHERE m.name = 'Toyota'
ORDER BY mo.name;
```

### Get complete vehicle information
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  g.name AS generation,
  s.name AS series,
  t.name AS trim,
  e.engine_power_hp,
  e.max_speed_kmh,
  e.body_type
FROM makes ma
JOIN models mo ON ma.id = mo.make_id
JOIN generations g ON mo.id = g.model_id
JOIN series s ON g.id = s.generation_id
JOIN trims t ON s.id = t.series_id
JOIN equipments e ON t.id = e.trim_id
WHERE ma.name = 'Toyota' 
  AND mo.name = 'RAV4'
LIMIT 10;
```

### Search by specifications
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  t.name AS trim,
  e.engine_power_hp,
  e.acceleration_0_100_s
FROM equipments e
JOIN trims t ON e.trim_id = t.id
JOIN series s ON t.series_id = s.id
JOIN models mo ON s.model_id = mo.id
JOIN makes ma ON mo.make_id = ma.id
WHERE CAST(REPLACE(e.engine_power_hp, ' hp', '') AS UNSIGNED) > 300
  AND e.acceleration_0_100_s IS NOT NULL
ORDER BY CAST(REPLACE(e.engine_power_hp, ' hp', '') AS UNSIGNED) DESC
LIMIT 20;
```

### Get vehicles by year range
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  g.name AS generation,
  g.year_begin,
  g.year_end
FROM makes ma
JOIN models mo ON ma.id = mo.make_id
JOIN generations g ON mo.id = g.model_id
WHERE g.year_begin >= 1960 AND g.year_begin <= 1970
ORDER BY g.year_begin, ma.name;
```

---

## 📥 Download Full Database

**👉 [Get Complete Database with 262,827+ Records ($49)](https://car3db.gumroad.com/l/enwrs)**

---

© 2025 Car3DB

