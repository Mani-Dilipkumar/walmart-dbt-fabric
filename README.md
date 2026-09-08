# walmart-dbt-fabric

dbt transformations that build a **silver layer** for a Walmart-style retail warehouse on
**Microsoft Fabric**, reading raw bronze tables from a Fabric lakehouse and producing cleaned,
conformed tables plus wide one-big-table (OBT) models for reporting.

## About this repository — read this first

**This is a guided project, not original work.** I built it by following
, and the modelling approach, the entity
choices and the medallion structure come from that material rather than from me. I am keeping
it public because it is the project where I learned dbt properly, and because I would rather a
reviewer know exactly what they are looking at than guess.

What I did do myself, on top of the guide:

- [e.g. re-pointed the project at my own Fabric workspace and got service-principal auth working]
- [e.g. wrote `main.py` so dbt picks up `.env` without exporting variables by hand]
- [e.g. wrote `DBT_COMPREHENSIVE_GUIDE.md` — a walkthrough of every config in the project]
- [e.g. added tests / changed materializations / debugged the ODBC setup]

> Replace the bracketed lines above with what is actually true. Anything you cannot honestly
> claim, delete — a short accurate list beats a long padded one.

For work that is mine end to end, see **[Shelf Life](LINK)** — an excess and obsolete
inventory pipeline on synthetic ERP data, with a measured baseline and a published site.

## What this pipeline is for

A retail warehouse lands raw operational tables in a bronze lakehouse: orders, order items,
customers, employees, products, stores. Those tables are untyped, duplicated and awkward to
query, so every analyst re-writes the same joins and casts, and two people asking the same
question get two different numbers.

The silver layer fixes that by making one governed version of each entity, and then a small
number of wide reporting tables built from those entities. Reporting reads the wide tables and
nobody re-derives business logic in a BI tool.

| | Before | After |
| --- | --- | --- |
| Where logic lives | In each report | In version-controlled dbt models |
| Types and dedup | Ad hoc, per query | Once, in `silver_t/` |
| Reporting joins | Rebuilt every time | Pre-joined in `silver_b/` |

## Architecture

Bronze (source) → staging views → typed silver tables → OBT marts, following the medallion pattern.

| Layer | Path | Materialization | Purpose |
| --- | --- | --- | --- |
| Sources | `models/sources.yml` | — | Bronze tables in the `Postgres_LH` lakehouse (`dbo` schema) |
| Staging | `models/staging/` | view | Thin pass-through over bronze, no business logic |
| Ephemeral | `models/ephemeral/` | ephemeral | Reusable CTEs, compiled inline rather than persisted |
| Silver (typed) | `models/silver_t/` | table → `silver` | Cast, cleaned, deduplicated entity tables |
| Silver (OBT) | `models/silver_b/` | table → `silver` | Denormalized wide tables joining the entities |

Entities modelled: customers, employees, orders, order_items, products, stores.

`macros/customschema.sql` overrides dbt's default `generate_schema_name` so a model's `+schema`
config is used verbatim instead of being prefixed with the target schema.

## Stack

- dbt-core >= 1.11.12 with the `dbt-fabric` adapter
- Microsoft Fabric Warehouse, authenticated with an Azure AD **service principal**
- ODBC Driver 18 for SQL Server (must be installed on the machine)
- Python >= 3.13, dependencies managed with [uv](https://docs.astral.sh/uv/)

## Setup

Install the ODBC driver and [uv](https://docs.astral.sh/uv/getting-started/installation/) first, then:

```
git clone https://github.com/Mani-Dilipkumar/walmart-dbt-fabric.git
cd walmart-dbt-fabric
uv sync
```

Create your credentials from the templates:

```
cp .env.example .env                    # fill in the service principal values
cp profiles.example.yml profiles.yml    # set your own server and database
```

`.env` needs your Azure service principal:

```
AZURE_TENANT_ID=...
AZURE_CLIENT_ID=...
AZURE_CLIENT_SECRET=...
```

`.env`, `profiles.yml` and `.vscode/` are gitignored. The client secret is only ever read
through `env_var()` in `profiles.yml` — never hardcode it.

## Running

`main.py` loads `.env` into the environment and forwards its arguments to dbt, so credentials
are picked up without exporting them by hand:

```
uv run python main.py debug     # verify the Fabric connection
uv run python main.py run       # build all models
uv run python main.py test      # run tests
uv run python main.py build     # run + test together
```

Plain `dbt` also works if the variables are already in your shell:

```
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

## Known gaps

Being explicit, since this is a learning repo and I would rather name these than have a
reviewer find them:

- **No CI.** Nothing verifies the project builds outside my machine. This is the next thing
  I am fixing.
- **Requires a live Fabric warehouse**, so nobody can clone and run it without their own
  Azure tenant.
- **Test coverage is [N] tests** across the schema YAMLs — thinner than I would ship at work.
- The transformations follow the source material's modelling decisions; I have not
  independently justified every entity boundary.
