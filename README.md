# 🚗 Car3DB - Complete Automotive Database (1908-2025)

[![License: Commercial](https://img.shields.io/badge/License-Commercial-blue.svg)](https://car3db.gumroad.com/l/enwrs)
[![Database Records](https://img.shields.io/badge/Records-262K%2B-green.svg)](https://car3db.gumroad.com/l/enwrs)
[![Years Coverage](https://img.shields.io/badge/Years-1908--2025-orange.svg)](https://car3db.gumroad.com/l/enwrs)
[![Format](https://img.shields.io/badge/Format-MySQL%20%7C%20CSV-red.svg)](https://car3db.gumroad.com/l/enwrs)

> **The most comprehensive automotive database spanning 117 years of automotive history**

This repository contains **sample data** and documentation for Car3DB, a complete automotive database with 262,827+ verified records from 1908 to 2025.

---

## 📊 Database Overview

| Category | Count | Description |
|----------|-------|-------------|
| **Manufacturers** | 403 | All major automotive brands worldwide |
| **Models** | 4,742 | Complete model lineups |
| **Generations** | 10,223 | Model generations with year ranges |
| **Series** | 15,546 | Engine and trim variants |
| **Trim Levels** | 100,126+ | Detailed trim specifications |
| **Specifications** | 98,239+ | Complete technical data |
| **Equipment Sets** | 33,548+ | Detailed equipment lists |
| **Total Records** | 262,827+ | Comprehensive automotive data |

---

## 🎯 What's Included

### Complete Specifications
- ✅ **Engine Data**: Type, capacity, power, torque, cylinders, injection type
- ✅ **Performance**: 0-100 km/h, top speed, acceleration
- ✅ **Dimensions**: Length, width, height, wheelbase, ground clearance
- ✅ **Weight & Capacity**: Curb weight, payload, trunk capacity
- ✅ **Fuel Economy**: City, highway, mixed consumption, range
- ✅ **Drivetrain**: Transmission type, gears, drive wheels
- ✅ **Suspension**: Front and rear suspension types
- ✅ **Brakes**: Disc types, ABS information
- ✅ **Body**: Type, doors, seats, classification

### Multiple Formats
- 🗄️ **MySQL Database Dump** - Ready-to-import `.sql` file
- 📊 **CSV Files** - Individual CSV files for each table
- 🔧 **Normalized Schema** - Proper relationships and indexes

---

## 📁 Database Structure

```
car3db/
├── makes              (403 records)
│   ├── id
│   └── name
│
├── models             (4,742 records)
│   ├── id
│   ├── make_id       → makes.id
│   └── name
│
├── generations        (10,223 records)
│   ├── id
│   ├── model_id      → models.id
│   └── name
│
├── series             (15,546 records)
│   ├── id
│   ├── model_id      → models.id
│   ├── generation_id → generations.id
│   └── name
│
├── trims              (100,126+ records)
│   ├── id
│   ├── series_id     → series.id
│   └── name
│
├── specs              (98,239+ records)
│   ├── trim_id       → trims.id
│   ├── specs_json
│   └── specs_raw_json
│
└── equipments         (33,548+ records)
    ├── trim_id       → trims.id
    └── 60+ specification columns
```

---

## 🔍 Sample Data

This repository contains **sample data** to help you understand the database structure:

- [`/samples/makes.csv`](samples/makes.csv) - Sample manufacturers
- [`/samples/models.csv`](samples/models.csv) - Sample models
- [`/samples/specifications.json`](samples/specifications.json) - Sample spec data
- [`/samples/schema.sql`](samples/schema.sql) - Database schema

### Sample Record Example

```json
{
  "make": "Toyota",
  "model": "RAV4",
  "generation": "IV (2013-2018)",
  "series": "RAV4 2.0 CVT",
  "trim": "Base",
  "specifications": {
    "engine_type": "Gasoline",
    "engine_capacity": "1998 cm3",
    "engine_power": "147 hp",
    "max_torque": "199 N*m",
    "acceleration_0_100": "10.2 s",
    "max_speed": "180 km/h",
    "fuel_city": "10.3 l/100km",
    "fuel_highway": "6.6 l/100km",
    "fuel_mixed": "8 l/100km",
    "gearbox": "CVT",
    "drive_wheels": "FWD",
    "length": "4646 mm",
    "width": "1806 mm",
    "height": "1713 mm",
    "curb_weight": "1570 kg",
    "trunk_min": "441 l",
    "trunk_max": "1686 l"
  }
}
```

---

## 💼 Use Cases

### 🌐 Web Applications
- Car marketplaces and classified ads
- Vehicle comparison tools
- Automotive content portals
- Dealer inventory systems

### 📱 Mobile Apps
- Car finder and discovery apps
- Specification lookup tools
- Vintage car catalogs
- Automotive reference apps

### 🏢 Business Solutions
- Vehicle history services
- Insurance platforms
- Fleet management systems
- Automotive APIs

### 📊 Data Science & Research
- Market trend analysis
- Machine learning datasets
- Academic automotive research
- Historical data analysis

---

## 🚀 Getting Started

### Option 1: MySQL Import
```bash
# Import the full database
mysql -u username -p database_name < car3db_full.sql

# Query example
SELECT m.name as make, mo.name as model, t.name as trim
FROM makes m
JOIN models mo ON m.id = mo.make_id
JOIN trims t ON mo.id = t.model_id
WHERE m.name = 'Toyota';
```

### Option 2: CSV Import
```python
import pandas as pd

# Load data
makes = pd.read_csv('car3db_csv/makes.csv')
models = pd.read_csv('car3db_csv/models.csv')
specs = pd.read_csv('car3db_csv/specs.csv')

# Merge and analyze
df = makes.merge(models, left_on='id', right_on='make_id')
print(df.head())
```

### Option 3: REST API
```javascript
// Example API implementation
app.get('/api/makes', async (req, res) => {
  const makes = await db.query('SELECT * FROM makes ORDER BY name');
  res.json(makes);
});

app.get('/api/models/:makeId', async (req, res) => {
  const models = await db.query(
    'SELECT * FROM models WHERE make_id = ?', 
    [req.params.makeId]
  );
  res.json(models);
});
```

---

## 📊 Statistics & Coverage

### By Decade
- **1900s-1920s**: Early automotive era, rare classics
- **1930s-1950s**: Pre-war and post-war classics
- **1960s-1980s**: Muscle cars and vintage automobiles
- **1990s-2010s**: Modern classics and sports cars
- **2010s-2025**: Contemporary vehicles and electrics

### Geographic Coverage
- 🌍 **Global**: Manufacturers from all continents
- 🇺🇸 American brands (Ford, Chevrolet, Tesla, etc.)
- 🇩🇪 German brands (BMW, Mercedes-Benz, Volkswagen, etc.)
- 🇯🇵 Japanese brands (Toyota, Honda, Nissan, etc.)
- 🇮🇹 Italian brands (Ferrari, Lamborghini, Fiat, etc.)
- 🇬🇧 British brands (Jaguar, Land Rover, Aston Martin, etc.)
- 🇫🇷 French brands (Peugeot, Renault, Citroën, etc.)
- 🇰🇷 Korean brands (Hyundai, Kia, Genesis, etc.)

---

## ✨ Features

### ✓ Comprehensive Coverage
117 years of automotive history from 1908 to 2025

### ✓ Verified Data
All records are carefully curated and verified for accuracy

### ✓ Normalized Structure
Proper database design with foreign keys and indexes

### ✓ Multiple Formats
MySQL dump and CSV files for maximum compatibility

### ✓ Rich Specifications
60+ specification fields per vehicle

### ✓ Commercial License
Use in your commercial projects without restrictions

### ✓ Regular Updates
Database is maintained and updated regularly

### ✓ Easy Integration
Ready-to-use structure, import and start querying

---

## 📦 What You Get

When you purchase the full database:

- ✅ **Complete MySQL Dump** (~505 MB)
- ✅ **CSV Files** (All tables, UTF-8 encoded)
- ✅ **Database Schema** (SQL file with structure)
- ✅ **Documentation** (Import guides and examples)
- ✅ **Sample Queries** (Common use cases)
- ✅ **Commercial License** (Use in any project)
- ✅ **Instant Download** (No waiting, immediate access)

---

## 💰 Pricing

### Full Database Access: **$49** (One-time payment)

✅ No subscriptions, no recurring fees  
✅ Lifetime access to purchased version  
✅ Commercial use included  
✅ 262,827+ verified records  
✅ Both MySQL and CSV formats  

---

## 🛒 Purchase Full Database

**👉 [Get the Complete Database ($49)](https://car3db.gumroad.com/l/enwrs)**

*This repository only contains sample data. For the complete database with 262,827+ records, visit the link above.*

---

## 🔧 Technical Specifications

| Specification | Details |
|--------------|---------|
| **Database Size** | ~505 MB (MySQL), ~280 MB (CSV) |
| **Encoding** | UTF-8 (utf8mb4_general_ci) |
| **Database Engine** | InnoDB |
| **MySQL Version** | 5.7+ / MariaDB 10.2+ |
| **Total Tables** | 7 main tables + relations |
| **Total Records** | 262,827+ |
| **Fields per Vehicle** | 60+ specifications |

---

## 📖 Documentation

### Schema Documentation
See [`SCHEMA.md`](SCHEMA.md) for detailed table structures and relationships.

### Integration Guides
- [MySQL Import Guide](docs/MYSQL_IMPORT.md)
- [CSV Import Guide](docs/CSV_IMPORT.md)
- [API Implementation Examples](docs/API_EXAMPLES.md)
- [Query Examples](docs/QUERY_EXAMPLES.md)

### Use Case Examples
- [Building a Car Marketplace](docs/examples/marketplace.md)
- [Creating a Comparison Tool](docs/examples/comparison.md)
- [Building an API](docs/examples/api.md)

---

## ❓ FAQ

### Is this free?
This repository contains **sample data only**. The complete database with 262,827+ records is available for purchase at [$49](https://car3db.gumroad.com/l/enwrs).

### What's in the sample data?
Sample data includes a small subset of the full database to demonstrate structure and format.

### Can I use this commercially?
The full database includes a commercial license. Sample data is for evaluation only.

### What formats are available?
The full database includes both MySQL dump (.sql) and CSV files.

### Do you provide support?
Documentation and import guides are included. For additional support, contact after purchase.

### How do I get updates?
The full database purchase includes the current version. Future updates may be offered separately.

### What database systems are supported?
MySQL/MariaDB directly via SQL dump. CSV files can be imported into any database (PostgreSQL, SQLite, MongoDB, etc.).

---

## 🌟 Why Car3DB?

### Compared to Other Solutions

| Feature | Car3DB | API Services | Web Scraping |
|---------|--------|--------------|--------------|
| **One-time Cost** | ✅ $49 | ❌ $99/mo+ | ⚠️ Free but risky |
| **Offline Access** | ✅ Yes | ❌ No | ⚠️ Limited |
| **Commercial Use** | ✅ Yes | ⚠️ Limited | ❌ No |
| **Historic Data** | ✅ 1908-2025 | ⚠️ Limited | ❌ No |
| **Complete Specs** | ✅ 60+ fields | ⚠️ Basic only | ⚠️ Inconsistent |
| **Rate Limits** | ✅ None | ❌ Yes | ❌ Yes |
| **Data Quality** | ✅ Verified | ⚠️ Varies | ❌ Inconsistent |

---

## 🤝 Contributing

This repository is for documentation and samples only. The main database is a commercial product.

If you find errors in the sample data or documentation, please open an issue.

---

## 📄 License

**Sample data in this repository**: MIT License (for evaluation only)

**Full database**: Commercial License (included with purchase)

The full database can be used in commercial projects. You may not resell or redistribute the database as a standalone product.

See [LICENSE](LICENSE) for details.

---

## 🔗 Links

- 🛒 **[Purchase Full Database](https://car3db.gumroad.com/l/enwrs)** - $49 one-time payment
- 🌐 **[Official Website](https://car3db.gumroad.com)** - More information
- 📧 **[Contact](https://car3db.gumroad.com/l/enwrs)** - Questions? Get in touch

---

## 📊 Repository Stats

![GitHub stars](https://img.shields.io/github/stars/yourusername/car3db?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/car3db?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/yourusername/car3db?style=social)

---

## 🎯 Keywords

`automotive database` `car database` `vehicle database` `car specifications` `automobile data` `mysql car database` `csv car database` `vehicle specs` `car models` `automotive data` `car API` `vehicle API` `car data download` `automotive dataset` `car information` `vehicle information` `classic cars` `vintage cars` `car history` `automobile history`

---

**Car3DB** - The Complete Automotive Database  
*262,827+ Records • 403 Manufacturers • 100,126+ Trims • 1908-2025*

© 2025 Car3DB. All rights reserved.

