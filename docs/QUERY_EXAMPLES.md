# 🔍 Query Examples

Common SQL query examples for Car3DB database.

---

## Basic Queries

### Get all manufacturers
```sql
SELECT * FROM makes ORDER BY name;
```

### Get models for a specific manufacturer
```sql
SELECT mo.* 
FROM models mo
JOIN makes ma ON mo.make_id = ma.id
WHERE ma.name = 'Toyota'
ORDER BY mo.name;
```

### Count models per manufacturer
```sql
SELECT ma.name, COUNT(mo.id) as model_count
FROM makes ma
LEFT JOIN models mo ON ma.id = mo.make_id
GROUP BY ma.id, ma.name
ORDER BY model_count DESC
LIMIT 10;
```

---

## Advanced Queries

### Get complete vehicle hierarchy
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  g.name AS generation,
  s.name AS series,
  t.name AS trim,
  t.year
FROM makes ma
JOIN models mo ON ma.id = mo.make_id
JOIN generations g ON mo.id = g.model_id
JOIN series s ON g.id = s.generation_id
JOIN trims t ON s.id = t.series_id
WHERE ma.name = 'BMW' AND mo.name = '3 Series'
ORDER BY t.year DESC
LIMIT 20;
```

### Search by engine power
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  t.name AS trim,
  e.engine_power_hp,
  e.max_speed_kmh,
  e.acceleration_0_100_s
FROM equipments e
JOIN trims t ON e.trim_id = t.id
JOIN series s ON t.series_id = s.id
JOIN models mo ON s.model_id = mo.id
JOIN makes ma ON mo.make_id = ma.id
WHERE CAST(REPLACE(e.engine_power_hp, ' hp', '') AS UNSIGNED) >= 500
  AND e.acceleration_0_100_s IS NOT NULL
ORDER BY CAST(REPLACE(e.engine_power_hp, ' hp', '') AS UNSIGNED) DESC
LIMIT 50;
```

### Find vehicles by fuel economy
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  t.name AS trim,
  e.mixed_consumption_l_100km,
  e.engine_type
FROM equipments e
JOIN trims t ON e.trim_id = t.id
JOIN series s ON t.series_id = s.id
JOIN models mo ON s.model_id = mo.id
JOIN makes ma ON mo.make_id = ma.id
WHERE e.mixed_consumption_l_100km IS NOT NULL
  AND CAST(REPLACE(REPLACE(e.mixed_consumption_l_100km, ' l', ''), '/100km', '') AS DECIMAL(5,2)) < 5.0
ORDER BY CAST(REPLACE(REPLACE(e.mixed_consumption_l_100km, ' l', ''), '/100km', '') AS DECIMAL(5,2)) ASC
LIMIT 30;
```

---

## Vintage & Classic Cars

### Get all vehicles from a specific decade
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
WHERE g.year_begin BETWEEN 1960 AND 1969
ORDER BY g.year_begin, ma.name;
```

### Find classic muscle cars (1960s-1970s)
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  t.year,
  e.engine_power_hp,
  e.engine_capacity_cm3
FROM equipments e
JOIN trims t ON e.trim_id = t.id
JOIN series s ON t.series_id = s.id
JOIN models mo ON s.model_id = mo.id
JOIN makes ma ON mo.make_id = ma.id
WHERE t.year BETWEEN 1960 AND 1979
  AND CAST(REPLACE(e.engine_capacity_cm3, ' cm3', '') AS UNSIGNED) >= 5000
ORDER BY t.year, CAST(REPLACE(e.engine_power_hp, ' hp', '') AS UNSIGNED) DESC;
```

---

## Body Type Queries

### Count vehicles by body type
```sql
SELECT 
  e.body_type,
  COUNT(*) as count
FROM equipments e
WHERE e.body_type IS NOT NULL
GROUP BY e.body_type
ORDER BY count DESC;
```

### Find all SUVs
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  t.name AS trim,
  t.year,
  e.length_mm,
  e.seats
FROM equipments e
JOIN trims t ON e.trim_id = t.id
JOIN series s ON t.series_id = s.id
JOIN models mo ON s.model_id = mo.id
JOIN makes ma ON mo.make_id = ma.id
WHERE e.body_type LIKE '%SUV%' OR e.body_type LIKE '%Crossover%'
ORDER BY t.year DESC
LIMIT 50;
```

---

## Drivetrain Queries

### Find all AWD vehicles
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  t.name AS trim,
  e.drive_wheels,
  e.engine_power_hp
FROM equipments e
JOIN trims t ON e.trim_id = t.id
JOIN series s ON t.series_id = s.id
JOIN models mo ON s.model_id = mo.id
JOIN makes ma ON mo.make_id = ma.id
WHERE e.drive_wheels LIKE '%AWD%' OR e.drive_wheels LIKE '%4WD%'
ORDER BY ma.name, mo.name;
```

---

## Statistics Queries

### Average specifications by manufacturer
```sql
SELECT 
  ma.name AS make,
  COUNT(DISTINCT mo.id) as total_models,
  AVG(CAST(REPLACE(e.engine_power_hp, ' hp', '') AS UNSIGNED)) as avg_power_hp,
  AVG(CAST(REPLACE(REPLACE(e.mixed_consumption_l_100km, ' l', ''), '/100km', '') AS DECIMAL(5,2))) as avg_fuel_consumption
FROM makes ma
JOIN models mo ON ma.id = mo.make_id
JOIN series s ON mo.id = s.model_id
JOIN trims t ON s.id = t.series_id
JOIN equipments e ON t.id = e.trim_id
WHERE e.engine_power_hp IS NOT NULL
GROUP BY ma.id, ma.name
HAVING COUNT(DISTINCT mo.id) >= 5
ORDER BY avg_power_hp DESC
LIMIT 20;
```

---

## Full-Text Search (if enabled)

### Search across all text fields
```sql
SELECT 
  ma.name AS make,
  mo.name AS model,
  t.name AS trim
FROM makes ma
JOIN models mo ON ma.id = mo.make_id
JOIN series s ON mo.id = s.model_id
JOIN trims t ON s.id = t.series_id
WHERE mo.name LIKE '%Sport%'
   OR t.name LIKE '%Sport%'
ORDER BY ma.name, mo.name;
```

---

## 💡 Tips

- Always use proper JOINs to maintain referential integrity
- Add appropriate indexes for better performance
- Use LIMIT when testing queries
- Consider adding WHERE clauses to filter NULL values
- Use CAST or REPLACE functions to handle string-formatted numbers

---

## 🛒 Get Full Database

These queries work with the complete database.

**👉 [Purchase Full Database ($49)](https://car3db.gumroad.com/l/enwrs)**

---

© 2025 Car3DB

