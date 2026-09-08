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

