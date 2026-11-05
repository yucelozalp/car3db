# 📋 Database Schema — Car3DB v2

Schema documentation for the **v2** Car3DB release (data dated **01 November 2026**).

> Looking for v1? The v1 layout is a strict subset of this one — `specs.specs_json` and
> `specs.specs_raw_json` are unchanged, so v1 integrations keep working.

---

## 🗄️ Table Overview

Car3DB v2 consists of 10 tables:

```
makes ──→ models ──→ generations ──→ series ──→ trims
                                       │           │
                                       │           ├──→ specs                 (v1 JSON, 1:1)
                                       │           ├──→ specification_values ──→ specifications  (v2 EAV)
                                       │           └──→ equipments ──→ option_values
                                       └───────────→ models (FK)
```

| Table | Rows (Nov 2026) | Purpose |
|---|---:|---|
| `makes` | 403 | Manufacturers |
| `models` | 4,742 | Model lineups |
| `generations` | 10,223 | Generations with production years |
| `series` | 15,546 | Body/engine families |
| `trims` | 98,239 | Trim levels |
| `specs` | 98,239 | v1-compatible JSON blobs |
| `specifications` | 82 | Catalogue of spec fields |
| `specification_values` | 4,256,122 | EAV values |
| `equipments` | 33,548 | Equipment packages |
| `option_values` | 0 | Options inside a package |

---

## 📊 Tables

### 1. `makes` — Manufacturers

```sql
CREATE TABLE `makes` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type_id` int(11) NOT NULL DEFAULT 1,
  `date_create` int(11) DEFAULT NULL,
  `date_update` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_makes_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Example**: `(184, 'Volkswagen', 1, 1234567890, 1234567890)`

---

### 2. `models` — Vehicle Models

```sql
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Example**: `(1908, 184, 'Golf', 1, ...)`

---

### 3. `generations` — Model Generations

```sql
CREATE TABLE `generations` (
  `id` bigint(20) NOT NULL,
  `model_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `year_begin` int(11) DEFAULT NULL,   -- v2: extracted from the name
  `year_end` int(11) DEFAULT NULL,     -- v2
  `type_id` int(11) NOT NULL DEFAULT 1,
  `date_create` int(11) DEFAULT NULL,
  `date_update` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_generations_model` (`model_id`),
  KEY `idx_generations_years` (`year_begin`,`year_end`),
  CONSTRAINT `fk_generations_model` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Example**: `(2160, 1908, '7 generation', 2012, 2017, 1, ...)`

> v1 only had the years inside `name` (`"7 generation [2012 - 2017]"`). v2 keeps that name and
> also stores the years as integers.

---

### 4. `series` — Vehicle Series

```sql
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
  FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`generation_id`) REFERENCES `generations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Example**: `(51487, 1908, 2160, 'Alltrack wagon 5-doors', 1, ...)`

---

### 5. `trims` — Trim Levels

```sql
CREATE TABLE `trims` (
  `id` bigint(20) NOT NULL,
  `series_id` bigint(20) NOT NULL,
  `model_id` bigint(20) DEFAULT NULL,          -- v2: denormalised for fast joins
  `name` varchar(255) NOT NULL,
  `start_production_year` int(11) DEFAULT NULL, -- v2
  `end_production_year` int(11) DEFAULT NULL,   -- v2
  `type_id` int(11) NOT NULL DEFAULT 1,
  `specs_status` varchar(16) NOT NULL DEFAULT 'none', -- v2: full|list|none|error
  `date_create` int(11) DEFAULT NULL,
  `date_update` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_trims_series` (`series_id`),
  KEY `idx_trims_name` (`name`),
  CONSTRAINT `fk_trims_series` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Example**: `(220224, 51487, 1908, '2.0 TDI DSG 4MOTION (184 hp)', 2013, NULL, 1, 'full', ...)`

`specs_status` tells you whether the specification tables are populated for that trim — useful when
a partial crawl was interrupted.

---

### 6. `specifications` — Specification Catalogue (v2)

One row per distinct field car2db exposes. 82 rows today; new fields appear here automatically.

```sql
CREATE TABLE `specifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,     -- car2db label, e.g. "Engine power"
  `group_name` varchar(255) DEFAULT NULL,
  `api_id` bigint(20) DEFAULT NULL, -- car2db's own specification id
  `spec_key` varchar(128) DEFAULT NULL, -- stable snake_case alias, e.g. engine_power_hp
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_specifications_name` (`name`),
  KEY `idx_specifications_group` (`group_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Groups** (identical to car2db's own catalogue): `Bodywork` (28), `Engine` (23), `Electric` (11),
`Operating characteristics` (11), `Suspension and brakes` (4), `Gearbox and handling` (3), `Safety` (2).

> Grouping follows the source, not intuition: `Curb weight`/`Payload` live under `Bodywork` and
> `Fuel tank capacity` under `Operating characteristics`, exactly as car2db lists them.

---

### 7. `specification_values` — Spec Values (v2)

The EAV table: one row per trim × field. Value and unit are separate, so numeric comparison works
without string surgery.

```sql
CREATE TABLE `specification_values` (
  `trim_id` bigint(20) NOT NULL,
  `specification_id` bigint(20) NOT NULL,
  `value` varchar(255) DEFAULT NULL,   -- "184", "4578", "from 3 500 to 4 000"
  `unit` varchar(32) DEFAULT NULL,     -- "hp", "mm", "RPM", NULL
  PRIMARY KEY (`trim_id`,`specification_id`),
  KEY `idx_specvalues_spec` (`specification_id`),
  FOREIGN KEY (`trim_id`) REFERENCES `trims` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`specification_id`) REFERENCES `specifications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Example rows for trim 220224**:

| specification_id | name | value | unit |
|---|---|---|---|
| … | Body type | Wagon | NULL |
| … | Length | 4578 | mm |
| … | Engine power | 184 | hp |
| … | Max power at RPM | from 3 500 to 4 000 | RPM |

> A handful of values are inherently textual (`"from 960 to 1 200"`); those keep their phrasing in
> `value` and are marked with a unit so the reader knows what the numbers refer to.

---

### 8. `specs` — v1-Compatible JSON

Kept byte-for-byte compatible with v1 for consumers that already parse it.

```sql
CREATE TABLE `specs` (
  `trim_id` bigint(20) NOT NULL,
  `specs_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin
      DEFAULT NULL CHECK (json_valid(`specs_json`)),
  `specs_raw_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin
      DEFAULT NULL CHECK (json_valid(`specs_raw_json`)),
  `specs_grouped_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  -- v2
      DEFAULT NULL CHECK (json_valid(`specs_grouped_json`)),
  `key_specs_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin      -- v2
      DEFAULT NULL CHECK (json_valid(`key_specs_json`)),
  PRIMARY KEY (`trim_id`),
  CONSTRAINT `fk_specs_trim` FOREIGN KEY (`trim_id`) REFERENCES `trims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

| Column | Content |
|---|---|
| `specs_json` | v1 shape: 54 snake_case keys, `"value unit"` strings |
| `specs_raw_json` | car2db labels → `"value unit"` |
| `specs_grouped_json` | **v2**: `[{name, items:[{name,value,unit,text}]}]` — all 82 fields |
| `key_specs_json` | **v2**: headline specs (`engineVolume`, `power`, `transmission`, `drive`, …) |

`specs_json` example:

```json
{
  "body_type": "Wagon",
  "seats": "5",
  "length_mm": "4578 mm",
  "engine_capacity_cm3": "1968 cm3",
  "engine_power_hp": "184 hp",
  "torque_nm": "380 N*m",
  "max_speed_kmh": "219 km/h",
  "acceleration_0_100_s": "7.8 s",
  "fuel": "diesel"
  // … 54 keys in total, unchanged from v1
}
```

---

### 9. `equipments` — Equipment Packages

```sql
CREATE TABLE `equipments` (
  `id` bigint(20) NOT NULL,
  `trim_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_equipments_trim` (`trim_id`),
  CONSTRAINT `fk_equipment_trim` FOREIGN KEY (`trim_id`) REFERENCES `trims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

> In v1 `equipments` was overloaded: it held 60 specification columns. Those columns are now
> `specification_values`; this table holds only equipment package names, as its name suggests.

---

### 10. `option_values` — Options inside a package

```sql
CREATE TABLE `option_values` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `equipment_id` bigint(20) NOT NULL,
  `name` varchar(512) NOT NULL,
  `value` varchar(1024) DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_option_values_equipment` (`equipment_id`),
  CONSTRAINT `fk_option_values_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

Empty in the Nov 2026 snapshot (the source returns no option list for these trims); the table is
populated automatically when the source provides them.

---

## 🔗 Relationships

```
makes (1) ←→ (N) models
models (1) ←→ (N) generations
models (1) ←→ (N) series
generations (1) ←→ (N) series
series (1) ←→ (N) trims
trims (1) ←→ (1) specs
trims (1) ←→ (N) specification_values → specifications
trims (1) ←→ (N) equipments → (N) option_values
```

---

## 📊 Sample Queries

### Everything about one trim (the format used on the source site)

```sql
SELECT sp.group_name AS `group`, sp.name, v.value, v.unit,
       CONCAT_WS(' ', v.value, v.unit) AS text
FROM specification_values v
JOIN specifications sp ON sp.id = v.specification_id
WHERE v.trim_id = 220224
ORDER BY sp.group_name, sp.name;
```

### Full vehicle identity

```sql
SELECT ma.name AS make, mo.name AS model,
       g.name AS generation, g.year_begin, g.year_end,
       s.name AS series, t.name AS trim,
       t.start_production_year, t.end_production_year
FROM trims t
JOIN series s      ON s.id = t.series_id
JOIN models mo     ON mo.id = t.model_id
JOIN makes ma      ON ma.id = mo.make_id
LEFT JOIN generations g ON g.id = s.generation_id
WHERE t.id = 220224;
```

### Rebuild a wide row for one trim

```sql
SELECT
  MAX(CASE WHEN sp.name = 'Engine power' THEN v.value END)  AS power_hp,
  MAX(CASE WHEN sp.name = 'Capacity'     THEN v.value END)  AS capacity_cm3,
  MAX(CASE WHEN sp.name = 'Body type'    THEN v.value END)  AS body_type,
  MAX(CASE WHEN sp.name = 'Fuel'         THEN v.value END)  AS fuel
FROM specification_values v
JOIN specifications sp ON sp.id = v.specification_id
WHERE v.trim_id = 220224;
```

### Search by numeric specification

```sql
SELECT ma.name AS make, mo.name AS model, t.name AS trim, v.value AS hp
FROM specification_values v
JOIN specifications sp ON sp.id = v.specification_id AND sp.name = 'Engine power'
JOIN trims t  ON t.id = v.trim_id
JOIN models mo ON mo.id = t.model_id
JOIN makes ma  ON ma.id = mo.make_id
WHERE CAST(v.value AS UNSIGNED) >= 400
ORDER BY CAST(v.value AS UNSIGNED) DESC
LIMIT 50;
```

### Coverage per specification

```sql
SELECT sp.group_name, sp.name, COUNT(v.trim_id) AS trims
FROM specifications sp
LEFT JOIN specification_values v ON v.specification_id = sp.id
GROUP BY sp.id, sp.group_name, sp.name
ORDER BY trims DESC;
```

---

## 📥 Download Full Database

**👉 [Get Complete Database with 4.5M+ rows ($49)](https://car3db.gumroad.com/l/enwrs)**

---

© 2026 Car3DB
