# Raw API responses (reference)

These files are the unmodified responses from the car2db widget API for the
reference vehicle used throughout the docs:

> **Volkswagen Golf VII (2012–2017) · Alltrack wagon 5-doors · 2.0 TDI DSG 4MOTION (184 hp)**
> typeId `1` · makeId `184` · modelId `1908` · generationId `2160` · seriesId `51487` · trimId `220224`

| File | Endpoint |
|---|---|
| `get-makes.json` | `/car2db-api/get-makes/?typeId=1&itemsPerPage=2000` |
| `get-models.json` | `/car2db-api/get-models/?typeId=1&makeId=184&itemsPerPage=100` |
| `get-generation.json` | `/car2db-api/get-generations/?typeId=1&modelId=1908` |
| `get-series.json` | `/car2db-api/get-series/?typeId=1&generationId=2160` |
| `get-trims.json` | `/car2db-api/get-trims/?typeId=1&seriesId=51487` |
| `get-trims-full.json` | `/car2db-api/get-trim-full/?trimId=220224` |
| `get-equiments.json` | `/car2db-api/get-equipments/?typeId=1&trimId=220224` (empty for this trim) |

`get-trims-full.json` is the file that `samples/specifications.json` and the
`specification_values` example rows are derived from, so you can trace every value
back to its source.

> The API requires a widget token (`GET /car2db-api/token/`) and answers `403
> Invalid selection` for ids that were not reached by walking down from the type.
> See the scraper project for the full client implementation.
