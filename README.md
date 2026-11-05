# 🚗 Car3DB — Complete Automotive Database (1908–2026)

[![License: Commercial](https://img.shields.io/badge/License-Commercial-blue.svg)](https://car3db.gumroad.com/l/enwrs)
[![Database Records](https://img.shields.io/badge/Records-4.5M%2B-green.svg)](https://car3db.gumroad.com/l/enwrs)
[![Years Coverage](https://img.shields.io/badge/Years-1908--2026-orange.svg)](https://car3db.gumroad.com/l/enwrs)
[![Format](https://img.shields.io/badge/Format-MySQL%20%7C%20CSV-red.svg)](https://car3db.gumroad.com/l/enwrs)
[![Version](https://img.shields.io/badge/Schema-v2-purple.svg)](SCHEMA.md)

> **The most comprehensive automotive database — 118 years of automotive history, refreshed to November 2026.**

This repository contains **sample data** and documentation for Car3DB. The current release is **v2**,
generated from car2db.com on **01 November 2026** (previous release: 01 October 2025).

---

## 🆕 What changed in v2

| | v1 (Oct 2025) | v2 (Nov 2026) |
|---|---|---|
| **Data date** | 01 Oct 2025 | **01 Nov 2026** |
| **Specification storage** | 54 fixed columns in `specs.specs_json` | **EAV: `specifications` + `specification_values`** |
| **Specification fields** | 54 (fixed, new fields silently dropped) | **82 and open-ended** — every field car2db exposes, including EV battery/charging, CO₂, safety ratings, trailer load |
| **Spec values** | 98,239 rows | **4,256,122 rows** |
| **Units** | glued into the value (`"4578 mm"`) | **split into `value` + `unit`** (numeric queries need no string surgery) |
| **Spec groups** | none | `Bodywork`, `Engine`, `Gearbox and handling`, `Operating characteristics`, `Suspension and brakes`, `Electric`, `Safety` |
| **Generation years** | only inside the name | **`year_begin` / `year_end` columns** |
| **Trim production years** | not stored | `start_production_year` / `end_production_year` |
| **Empty `equipments` table** | 60 columns, mostly NULL | equipment + option values are separate tables |

The v1 `specs` table is still exported, so existing integrations keep working — see
[Migrating from v1](#-migrating-from-v1).

---

## 📊 Database Overview

| Category | Count | Description |
|----------|-------|-------------|
| **Manufacturers** | 403 | All major automotive brands worldwide |
| **Models** | 4,742 | Complete model lineups |
| **Generations** | 10,223 | Model generations with `year_begin` / `year_end` |
| **Series** | 15,546 | Body/engine family variants |
| **Trim Levels** | 98,239 | 97,876 with full specifications, 363 empty upstream |
| **Specifications (catalogue)** | 82 | Distinct specification fields |
| **Specification values** | 4,256,122 | One row per trim × field |
| **Equipment sets** | 33,548 | Named equipment packages |
| **Total rows** | **4,517,144+** | Across all tables |

---

## 🎯 What's Included

### Complete Specifications
- ✅ **Engine**: type, placement, capacity, power (hp *and* kW), torque + RPM band, injection, cylinder layout/count, valves, bore/stroke, compression ratio, boost type, intercooler, engine code
- ✅ **Performance**: 0–100 km/h, top speed, power-to-weight inputs
- ✅ **Dimensions**: length, width, height, wheelbase, both tracks, ground clearance, wheel size, PCD
- ✅ **Weight & capacity**: curb weight, gross weight, payload, trailer load, trunk min/max, cargo volume
- ✅ **Fuel economy**: city / highway / mixed per 100 km, consumption, cruising range, CO₂, emission standard
- ✅ **Drivetrain**: gearbox type, gear count, drive wheels, turning circle
- ✅ **Chassis**: front/rear suspension, front/rear brakes, disc sizes
- ✅ **Electric & hybrid**: battery type/capacity (gross *and* usable), electric range, connector type, charging times, max charging power, charge cycles
- ✅ **Body**: body type, doors, seats, class, country, steering-wheel position

### Multiple Formats
- 🗄️ **MySQL Database Dump** — ready-to-import `.sql` (utf8mb4, InnoDB, FK constraints)
- 📊 **CSV Files** — one file per table
- 🔧 **Normalised Schema** — 10 tables with indexes and foreign keys

---

## 📁 Database Structure

```
car3db/
├── makes                  (403)
│   ├── id, name, type_id, date_create, date_update
│   └──← models
│
├── models                 (4,742)
│   ├── id, make_id, name, type_id
│   └──← generations, series
│
├── generations            (10,223)
│   ├── id, model_id, name, year_begin, year_end
│   └──← series
│
├── series                 (15,546)
│   ├── id, model_id, generation_id, name
│   └──← trims
│
├── trims                  (98,239)
│   ├── id, series_id, model_id, name
│   ├── start_production_year, end_production_year
│   ├── specs_status          'full' | 'list' | 'none' | 'error'
│   ├──← specs                 (v1-compatible JSON blobs)
│   ├──← specification_values  (v2 EAV)
│   └──← equipments → option_values
│
├── specifications         (82)                 ← v2
│   └── id, name, group_name, api_id, spec_key
│
├── specification_values   (4,256,122)          ← v2
│   ├── trim_id  → trims.id
│   ├── specification_id → specifications.id
│   └── value, unit
│
├── specs                  (98,239)             ← v1 compatible
│   ├── trim_id
│   ├── specs_json         (54 snake_case keys)
│   ├── specs_raw_json     (car2db labels)
│   ├── specs_grouped_json (category → items)   ← v2
│   └── key_specs_json     (headline specs)     ← v2
│
├── equipments             (33,548)
│   └── id, trim_id, name
│
└── option_values          (0 in this snapshot)
    └── id, equipment_id, name, value, group_name
```

---

## 🔍 Reading a trim

v2 keeps every field, so the same vehicle reads the same way the source site displays it:

```sql
SELECT s.group_name, s.name, v.value, v.unit
FROM specification_values v
JOIN specifications s ON s.id = v.specification_id
WHERE v.trim_id = 220224
ORDER BY s.group_name, s.name;
```

```
Bodywork            | Body type            | Wagon              | NULL
Bodywork            | Length               | 4578               | mm
Engine              | Engine type          | Diesel             | NULL
Engine              | Capacity             | 1968               | cm3
Engine              | Engine power         | 184                | hp
Operating char.     | Acceleration (0-100) | 7.8                | s
...
```

Full example: [`samples/specifications.json`](samples/specifications.json).

### Numeric queries are now trivial

```sql
-- Every 300+ hp wagon from 2015 onwards, no string parsing
SELECT ma.name AS make, mo.name AS model, t.name AS trim,
       power.value AS hp, body.value AS body_type
FROM trims t
JOIN series s        ON s.id = t.series_id
JOIN models mo       ON mo.id = t.model_id
JOIN makes ma        ON ma.id = mo.make_id
JOIN generations g   ON g.id = s.generation_id
JOIN specifications sp_power ON sp_power.name = 'Engine power'
JOIN specification_values power ON power.trim_id = t.id AND power.specification_id = sp_power.id
JOIN specifications sp_body ON sp_body.name = 'Body type'
JOIN specification_values body ON body.trim_id = t.id AND body.specification_id = sp_body.id
WHERE CAST(power.value AS UNSIGNED) >= 300
  AND body.value = 'Wagon'
  AND g.year_begin >= 2015
ORDER BY CAST(power.value AS UNSIGNED) DESC;
```

---

## 🔄 Migrating from v1

v1 consumers keep working: `specs.specs_json` and `specs.specs_raw_json` are still populated with
the same 54 keys and the same `"value unit"` strings.

What changed:

| v1 | v2 |
|---|---|
| `specs.specs_json` | still present, **plus** `specs_grouped_json` (all 82 fields, grouped) |
| `equipments` (60 spec columns) | now a real equipment table + `option_values`; the spec data lives in `specification_values` |
| `generations.name = "7 generation [2012 - 2017]"` | same name, **plus** `year_begin = 2012`, `year_end = 2017` |
| `trims.name` | same, **plus** production years and `specs_status` |

---

## 🚀 Getting Started

### Option 1: MySQL / MariaDB import

```bash
mysql -u username -p -e "CREATE DATABASE car3db CHARACTER SET utf8mb4"
mysql -u username -p car3db < car3db_v2.sql
```

The dump disables foreign-key checks while loading and re-enables them afterwards, so a plain
`mysql < file.sql` is enough.

### Option 2: CSV

```python
import pandas as pd

makes  = pd.read_csv('car3db_csv/makes.csv')
models = pd.read_csv('car3db_csv/models.csv')
values = pd.read_csv('car3db_csv/specification_values.csv')
specs  = pd.read_csv('car3db_csv/specifications.csv')

# One row per trim × field, then pivot to a wide frame
wide = (values.merge(specs, left_on='specification_id', right_on='id')
              .pivot_table(index='trim_id', columns='name', values='value', aggfunc='first'))
```

### Option 3: REST API

```javascript
app.get('/api/trims/:id', async (req, res) => {
  const [values] = await db.query(`
    SELECT s.group_name AS \`group\`, s.name, v.value, v.unit
    FROM specification_values v
    JOIN specifications s ON s.id = v.specification_id
    WHERE v.trim_id = ?`, [req.params.id]);
  res.json(values);
});
```

---

## 📊 Statistics & Coverage

### By Decade
- **1900s–1920s**: Early automotive era, rare classics
- **1930s–1950s**: Pre-war and post-war classics
- **1960s–1980s**: Muscle cars and vintage automobiles
- **1990s–2010s**: Modern classics and sports cars
- **2010s–2026**: Contemporary vehicles, hybrids and EVs

880 generations end in 2025 or later, including model years through 2027.

363 trims carry no specification data upstream (every field is NULL at the source); they are kept so
the hierarchy stays complete and are marked `specs_status = 'empty'`.

### Geographic Coverage
- 🌍 **Global**: manufacturers from every continent
- 🇺🇸 American, 🇩🇪 German, 🇯🇵 Japanese, 🇮🇹 Italian, 🇬🇧 British, 🇫🇷 French, 🇰🇷 Korean brands and more

---

## ✨ Features

### ✓ Comprehensive Coverage
118 years of automotive history, refreshed to November 2026

### ✓ Nothing Silently Dropped
The v2 EAV layout stores every field the source exposes — adding a field never requires a schema change

### ✓ Typed Values
Numeric values and units are separate columns, so `AVG()`, `>=`, and indexing work as expected

### ✓ Normalised Structure
10 tables, foreign keys, and indexes on every join path

### ✓ Multiple Formats
MySQL dump, per-table CSV, and a nested JSON hierarchy

### ✓ Commercial License
Use in commercial projects without restrictions

---

## 📦 What You Get

- ✅ Complete MySQL dump (utf8mb4)
- ✅ CSV files (all tables)
- ✅ Schema documentation ([`SCHEMA.md`](SCHEMA.md))
- ✅ Query examples ([`docs/QUERY_EXAMPLES.md`](docs/QUERY_EXAMPLES.md))
- ✅ Sample data (`samples/`)
- ✅ Commercial license

---

## 💰 Pricing

### Full Database Access: **$49** (one-time payment)

✅ No subscriptions, no recurring fees
✅ Lifetime access to the purchased version
✅ Commercial use included
✅ 4.5M+ verified rows

---

## 🛒 Purchase Full Database

**👉 [Get the Complete Database ($49)](https://car3db.gumroad.com/l/enwrs)**

*This repository only contains sample data.*

---

## 🔧 Technical Specifications

| Specification | Details |
|---|---|
| **Database Size** | ~700 MB (MySQL dump), ~720 MB (CSV) |
| **Encoding** | UTF-8 (`utf8mb4_general_ci`) |
| **Storage Engine** | InnoDB |
| **MySQL Version** | 5.7+ / MariaDB 10.2+ (JSON columns optional) |
| **Total Tables** | 10 |
| **Total Rows** | 4,517,144+ |
| **Spec fields** | 82 (open-ended) |
| **Schema version** | v2 |

---

## 📖 Documentation

### Schema Documentation
See [`SCHEMA.md`](SCHEMA.md) for every table, column, and relationship.

### Query Examples
See [`docs/QUERY_EXAMPLES.md`](docs/QUERY_EXAMPLES.md) — v1 queries plus v2 EAV equivalents.

---

## ❓ FAQ

### Is this free?
This repository contains **sample data only**. The complete database is available for purchase at [$49](https://car3db.gumroad.com/l/enwrs).

### What's the difference between `specs` and `specification_values`?
`specs` is the v1-compatible JSON blob (54 fixed keys). `specification_values` is the v2 EAV table with
all 82 fields, typed values and units. Both are kept so old and new consumers can coexist.

### Can I use this commercially?
The full database includes a commercial license. Sample data is for evaluation only.

### What database systems are supported?
MySQL/MariaDB directly via the SQL dump. CSV files import into PostgreSQL, SQLite, BigQuery, etc.

### How do I get updates?
The purchase includes the current (v2, Nov 2026) release. Future releases are offered separately.

---

## 📄 License

**Sample data in this repository**: MIT License (evaluation only)

**Full database**: Commercial License (included with purchase). The full database may be used in
commercial projects; it may not be resold or redistributed as a standalone product.

See [LICENSE](LICENSE) for details.

---

## 🔗 Links

- 🛒 **[Purchase Full Database](https://car3db.gumroad.com/l/enwrs)**
- 🌐 **[Official Website](https://car3db.gumroad.com)**

---

**Car3DB v2** — The Complete Automotive Database
*4,517,144+ rows · 403 manufacturers · 98,239 trims · 82 spec fields · 1908–2026*

© 2026 Car3DB. All rights reserved.
