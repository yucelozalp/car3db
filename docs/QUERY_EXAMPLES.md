# 🔍 Query Examples

SQL examples for Car3DB **v2** (data: 01 November 2026). Every v1 query still works — the v1 shapes
are preserved — and each section shows the shorter v2 equivalent where there is one.

---

## Basic queries

### All manufacturers

```sql
SELECT * FROM makes ORDER BY name;
```

### Models for a manufacturer

```sql
SELECT mo.*
FROM models mo
JOIN makes ma ON mo.make_id = ma.id
WHERE ma.name = 'Toyota'
ORDER BY mo.name;
```

### Models per manufacturer

```sql
SELECT ma.name, COUNT(mo.id) AS model_count
FROM makes ma
LEFT JOIN models mo ON ma.id = mo.make_id
GROUP BY ma.id, ma.name
ORDER BY model_count DESC
LIMIT 10;
```

---

## v2: reading specifications

### The reference trim, exactly as shown on the source site

```sql
SELECT sp.group_name, sp.name, v.value, v.unit
FROM specification_values v
JOIN specifications sp ON sp.id = v.specification_id
WHERE v.trim_id = 220224
ORDER BY sp.group_name, sp.name;
```

### Pivot a trim into a single wide row

```sql
SELECT
  MAX(CASE WHEN sp.name = 'Engine power'    THEN v.value END) AS power_hp,
  MAX(CASE WHEN sp.name = 'Maximum torque'  THEN v.value END) AS torque_nm,
  MAX(CASE WHEN sp.name = 'Capacity'        THEN v.value END) AS capacity_cm3,
  MAX(CASE WHEN sp.name = 'Body type'       THEN v.value END) AS body_type,
  MAX(CASE WHEN sp.name = 'Drive wheels'    THEN v.value END) AS drive,
  MAX(CASE WHEN sp.name = 'Emission standards' THEN v.value END) AS emission
FROM specification_values v
JOIN specifications sp ON sp.id = v.specification_id
WHERE v.trim_id = 220224;
```

### All values of one specification across a model

```sql
SELECT t.name AS trim, v.value, v.unit
FROM specification_values v
JOIN specifications sp ON sp.id = v.specification_id AND sp.name = 'Engine power'
JOIN trims t ON t.id = v.trim_id
JOIN series s ON s.id = t.series_id
JOIN models mo ON mo.id = t.model_id
WHERE mo.name = 'Golf'
ORDER BY CAST(v.value AS UNSIGNED) DESC;
```

---

## Advanced queries

### Complete vehicle hierarchy

```sql
SELECT ma.name AS make, mo.name AS model, g.name AS generation,
       s.name AS series, t.name AS trim,
       t.start_production_year, t.end_production_year
FROM makes ma
JOIN models mo      ON ma.id = mo.make_id
JOIN generations g  ON mo.id = g.model_id
JOIN series s       ON g.id  = s.generation_id
JOIN trims t        ON s.id  = t.series_id
WHERE ma.name = 'BMW' AND mo.name = '3 Series'
ORDER BY g.year_begin DESC, t.name
LIMIT 20;
```

### Search by engine power

```sql
SELECT ma.name AS make, mo.name AS model, t.name AS trim,
       v.value AS power_hp,
       acc.value AS accel_0_100
FROM specification_values v
JOIN specifications sp  ON sp.id = v.specification_id AND sp.name = 'Engine power'
JOIN trims t            ON t.id = v.trim_id
JOIN series s           ON s.id = t.series_id
JOIN models mo          ON mo.id = t.model_id
JOIN makes ma           ON ma.id = mo.make_id
LEFT JOIN specifications sp2 ON sp2.name = 'Acceleration (0-100 km/h)'
LEFT JOIN specification_values acc
       ON acc.trim_id = t.id AND acc.specification_id = sp2.id
WHERE CAST(v.value AS UNSIGNED) >= 500
ORDER BY CAST(v.value AS UNSIGNED) DESC
LIMIT 50;
```

### Fuel-efficient cars

```sql
SELECT ma.name AS make, mo.name AS model, t.name AS trim,
       v.value AS mixed_l_100km, fuel.value AS fuel_type
FROM specification_values v
JOIN specifications sp ON sp.id = v.specification_id
     AND sp.name = 'Mixed driving fuel consumption per 100 km'
JOIN trims t   ON t.id = v.trim_id
JOIN models mo ON mo.id = t.model_id
JOIN makes ma  ON ma.id = mo.make_id
LEFT JOIN specifications spf ON spf.name = 'Fuel'
LEFT JOIN specification_values fuel
       ON fuel.trim_id = t.id AND fuel.specification_id = spf.id
WHERE CAST(REPLACE(v.value, ',', '.') AS DECIMAL(6,2)) < 5.0
ORDER BY CAST(REPLACE(v.value, ',', '.') AS DECIMAL(6,2))
LIMIT 30;
```

> v1 required `REPLACE(REPLACE(value,' l',''),'/100km','')`; v2 stores `5.7` and `l` separately.

### Electric vehicles by range

```sql
SELECT ma.name AS make, mo.name AS model, t.name AS trim,
       v.value AS range_km, batt.value AS battery_kwh
FROM specification_values v
JOIN specifications sp ON sp.id = v.specification_id AND sp.name = 'Electric power reserve'
JOIN trims t   ON t.id = v.trim_id
JOIN models mo ON mo.id = t.model_id
JOIN makes ma  ON ma.id = mo.make_id
LEFT JOIN specifications spb ON spb.name = 'Battery capacity'
LEFT JOIN specification_values batt
       ON batt.trim_id = t.id AND batt.specification_id = spb.id
ORDER BY CAST(v.value AS UNSIGNED) DESC
LIMIT 30;
```

---

## Vintage & classic cars

### Vehicles from a decade

```sql
SELECT ma.name AS make, mo.name AS model,
       g.name AS generation, g.year_begin, g.year_end
FROM makes ma
JOIN models mo     ON ma.id = mo.make_id
JOIN generations g ON mo.id = g.model_id
WHERE g.year_begin BETWEEN 1960 AND 1969
ORDER BY g.year_begin, ma.name;
```

### Classic muscle cars

```sql
SELECT ma.name AS make, mo.name AS model, t.name AS trim,
       g.year_begin, cap.value AS capacity_cm3, pw.value AS power_hp
FROM trims t
JOIN series s           ON s.id = t.series_id
JOIN models mo          ON mo.id = t.model_id
JOIN makes ma           ON ma.id = mo.make_id
JOIN generations g      ON g.id = s.generation_id
JOIN specifications spc ON spc.name = 'Capacity'
JOIN specification_values cap ON cap.trim_id = t.id AND cap.specification_id = spc.id
JOIN specifications spp ON spp.name = 'Engine power'
JOIN specification_values pw  ON pw.trim_id = t.id AND pw.specification_id = spp.id
WHERE g.year_begin BETWEEN 1960 AND 1979
  AND CAST(cap.value AS UNSIGNED) >= 5000
ORDER BY g.year_begin, CAST(pw.value AS UNSIGNED) DESC;
```

---

## Body type queries

### Count by body type

```sql
SELECT v.value AS body_type, COUNT(*) AS count
FROM specification_values v
JOIN specifications sp ON sp.id = v.specification_id AND sp.name = 'Body type'
GROUP BY v.value
ORDER BY count DESC;
```

### All SUVs and crossovers

```sql
SELECT ma.name AS make, mo.name AS model, t.name AS trim,
       g.year_begin, length.value AS length_mm, seats.value AS seats
FROM specification_values body
JOIN specifications spb ON spb.id = body.specification_id AND spb.name = 'Body type'
JOIN trims t   ON t.id = body.trim_id
JOIN series s  ON s.id = t.series_id
JOIN models mo ON mo.id = t.model_id
JOIN makes ma  ON ma.id = mo.make_id
JOIN generations g ON g.id = s.generation_id
LEFT JOIN specifications spl ON spl.name = 'Length'
LEFT JOIN specification_values length
       ON length.trim_id = t.id AND length.specification_id = spl.id
LEFT JOIN specifications sps ON sps.name = 'Number of seater'
LEFT JOIN specification_values seats
       ON seats.trim_id = t.id AND seats.specification_id = sps.id
WHERE body.value IN ('SUV', 'Crossover', 'SUV 5-doors')
ORDER BY g.year_begin DESC
LIMIT 50;
```

---

## Drivetrain queries

### All-wheel-drive vehicles

```sql
SELECT ma.name AS make, mo.name AS model, t.name AS trim,
       drive.value AS drive_wheels, power.value AS power_hp
FROM specification_values drive
JOIN specifications spd ON spd.id = drive.specification_id AND spd.name = 'Drive wheels'
JOIN trims t   ON t.id = drive.trim_id
JOIN models mo ON mo.id = t.model_id
JOIN makes ma  ON ma.id = mo.make_id
LEFT JOIN specifications spp ON spp.name = 'Engine power'
LEFT JOIN specification_values power
       ON power.trim_id = t.id AND power.specification_id = spp.id
WHERE drive.value LIKE '%AWD%'
   OR drive.value LIKE '%4WD%'
   OR drive.value = 'All wheel drive (AWD)'
ORDER BY ma.name, mo.name;
```

---

## Statistics

### Average power per manufacturer

```sql
SELECT ma.name AS make,
       COUNT(DISTINCT mo.id) AS total_models,
       AVG(CAST(power.value AS DECIMAL(10,2))) AS avg_power_hp
FROM makes ma
JOIN models mo ON mo.id = ma.id
JOIN trims t   ON t.model_id = mo.id
JOIN specifications spp ON spp.name = 'Engine power'
JOIN specification_values power
     ON power.trim_id = t.id AND power.specification_id = spp.id
WHERE power.value REGEXP '^[0-9]+$'
GROUP BY ma.id, ma.name
HAVING COUNT(DISTINCT mo.id) >= 5
ORDER BY avg_power_hp DESC
LIMIT 20;
```

### Which specifications are populated most often

```sql
SELECT sp.group_name, sp.name, COUNT(v.trim_id) AS trims,
       ROUND(100 * COUNT(v.trim_id) / (SELECT COUNT(*) FROM trims), 1) AS coverage_pct
FROM specifications sp
LEFT JOIN specification_values v ON v.specification_id = sp.id
GROUP BY sp.id, sp.group_name, sp.name
ORDER BY trims DESC;
```

### Trims still missing specifications

```sql
SELECT t.id, t.name, s.name AS series, mo.name AS model, ma.name AS make
FROM trims t
JOIN series s  ON s.id = t.series_id
JOIN models mo ON mo.id = t.model_id
JOIN makes ma  ON ma.id = mo.make_id
WHERE t.specs_status <> 'full'
ORDER BY ma.name, mo.name
LIMIT 100;
```

---

## v1 compatibility

Every v1 query still runs against `specs.specs_json`, for example:

```sql
SELECT t.id, t.name, e.value AS power
FROM trims t
JOIN specification_values e ON e.trim_id = t.id
JOIN specifications sp      ON sp.id = e.specification_id AND sp.name = 'Engine power'
WHERE CAST(e.value AS UNSIGNED) >= 300;
```

or, unchanged from v1:

```sql
SELECT t.id, t.name,
       JSON_UNQUOTE(JSON_EXTRACT(s.specs_json, '$.engine_power_hp')) AS power
FROM trims t
JOIN specs s ON s.trim_id = t.id
WHERE CAST(REPLACE(JSON_UNQUOTE(JSON_EXTRACT(s.specs_json, '$.engine_power_hp')), ' hp', '') AS UNSIGNED) >= 300;
```

---

## 💡 Tips

- v2 stores `value` and `unit` separately — compare numerically without `REPLACE()` chains.
- Not every value is numeric: ranges keep their phrasing (`"from 3 500 to 4 000"`). Filter with
  `value REGEXP '^[0-9]+$'` before casting.
- `trims.model_id` is denormalised, so model joins do not need `series`.
- `trims.specs_status` shows whether specs exist for a trim — filter on it for partial crawls.
- Index hints: `specification_values` is keyed on (`trim_id`, `specification_id`); filter by
  `specification_id` first when scanning a whole field.

---

## 🛒 Full Database

**👉 [Purchase Full Database ($49)](https://car3db.gumroad.com/l/enwrs)**

---

© 2026 Car3DB
