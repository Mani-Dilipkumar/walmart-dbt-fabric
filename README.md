# walmart-dbt-fabric

dbt transformations that build a **silver layer** for a Walmart-style retail warehouse on
**Microsoft Fabric**, reading raw bronze tables from a Fabric lakehouse and producing cleaned,
conformed tables plus wide one-big-table (OBT) models for reporting.

## Architecture

Bronze (source) → staging views → typed silver tables → OBT marts, following the medallion pattern.

| Layer | Path | Materialization | Purpose |
|---|---|---|---|
| Sources | `models/sources.yml` | — | Bronze tables in the `Postgres_LH` lakehouse (`dbo` schema) |
| Staging | `models/staging/` | view | Thin pass-through over bronze, no business logic |
| Ephemeral | `models/ephemeral/` | ephemeral | Reusable CTEs, compiled inline rather than persisted |
| Silver (typed) | `models/silver_t/` | table → `silver` | Cast, cleaned, deduplicated entity tables |
| Silver (OBT) | `models/silver_b/` | table → `silver` | Denormalized wide tables joining the entities |

Entities modelled: customers, employees, orders, order_items, products, stores.

`macros/customschema.sql` overrides dbt's default `generate_schema_name` so a model's
`+schema` config is used verbatim instead of being prefixed with the target schema.

## Stack

- dbt-core >= 1.11.12 with the `dbt-fabric` adapter
- Microsoft Fabric Warehouse, authenticated with an Azure AD **service principal**
- ODBC Driver 18 for SQL Server (must be installed on the machine)
- Python >= 3.13, dependencies managed with [uv](https://docs.astral.sh/uv/)

## Setup

Install the ODBC driver and [uv](https://docs.astral.sh/uv/getting-started/installation/) first, then:

```bash
git clone https://github.com/<your-username>/walmart-dbt-fabric.git
cd walmart-dbt-fabric
uv sync
```

Create your credentials from the templates:

```bash
cp .env.example .env                    # fill in the service principal values
cp profiles.example.yml profiles.yml    # set your own server and database
```

`.env` needs your Azure service principal:

```
AZURE_TENANT_ID=...
AZURE_CLIENT_ID=...
AZURE_CLIENT_SECRET=...
```

`.env`, `profiles.yml`, and `.vscode/` are gitignored. The client secret is only ever read
through `env_var()` in `profiles.yml` — never hardcode it.

## Running

`main.py` loads `.env` into the environment and forwards its arguments to dbt, so credentials
are picked up without exporting them by hand:

```bash
uv run python main.py debug     # verify the Fabric connection
uv run python main.py run       # build all models
uv run python main.py test      # run tests
uv run python main.py build     # run + test together
```

Plain `dbt` also works if the variables are already in your shell:

```bash
uv run dbt run --select silver_t
```

## Layout

```
.
├── models/
│   ├── sources.yml         # bronze source definitions
│   ├── staging/            # views over bronze
│   ├── ephemeral/          # inline CTE models
│   ├── silver_t/           # typed entity tables
│   └── silver_b/           # OBT / denormalized marts
├── macros/customschema.sql # generate_schema_name override
├── seeds/  tests/  snapshots/  analyses/
├── dbt_project.yml
├── profiles.example.yml
├── .env.example
├── main.py                 # .env-aware dbt wrapper
└── DBT_COMPREHENSIVE_GUIDE.md
```

`DBT_COMPREHENSIVE_GUIDE.md` is a long-form walkthrough of every config in this project,
written as a learning reference.
