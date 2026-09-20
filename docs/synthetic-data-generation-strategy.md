# Synthetic Data Generation Strategy
## LSC Enterprise Data Harmonization Benchmark

**Repository:** `aadehamid/ERP_Data_Harmonization`  
**Fictitious enterprise:** Lagos Specialty Chemicals (LSC)  
**Document status:** Draft for implementation  
**Version:** 0.2.0  
**Date:** 2026-09-20  
**Related artifacts:** Enterprise Data Harmonization Project Charter; Data Acquisition and Synthetic Data Generation Strategy  

---

## 1. Purpose

This document defines how the project will generate a **synthetic-but-realistic multi-ERP dataset** for demonstrating enterprise data harmonization for **Lagos Specialty Chemicals (LSC)**.

LSC is a fictional multinational specialty-chemicals manufacturer and distributor used solely as the benchmark business context. It is not a representation of a real company, customer, supplier, operating site, tax position, production process, or ERP implementation.

The benchmark will demonstrate data harmonization across:

- SAP ECC-style source representations.
- SAP S/4HANA-style source representations.
- JD Edwards EnterpriseOne (JDE)-style source representations.
- Regional and organizational variants within those representations.
- One or more actual, fully free/open-source ERP applications operated in a lab environment.

The benchmark is intended to support the difficult parts of data harmonization—not merely file-format conversion:

- Master-data identity and cross-reference management.
- Product/material/item, customer/supplier/Business Partner, organization, and location harmonization.
- Specialty-chemical product, packaging, unit-of-measure, batch/lot, and controlled classification context.
- Regional, legal-entity, fiscal-calendar, currency, unit-of-measure, tax-context, and local-code variation.
- Business dictionary, taxonomy, ontology, and source-to-canonical mapping design.
- Deterministic transformation and reference-data crosswalk execution.
- Entity resolution and survivorship decisions.
- Data-quality detection, exception handling, reconciliation, provenance, and lineage.
- Traditional machine learning and LLM-assisted mapping discovery, ranking, explanation, and stewardship workflows.

The dataset must be reproducible, legally usable, explicitly synthetic where applicable, and designed with **known ground truth**. Known truth lets the project measure mapping accuracy, match accuracy, transformation correctness, reconciliation, and AI/ML quality instead of relying on visual demonstrations alone.

---

## 2. Repository context

At the time of this document, the repository contains a minimal root structure: `.gitignore` and `README.md`. This is an advantage: the project can establish a clean, intentional structure before data, generated artifacts, tools, and documentation are added. [github_mcp_direct:1][github_mcp_direct:2]

This strategy is intended to be stored at:

```text
docs/synthetic-data-generation-strategy.md
```

The repository should retain source code, scenario configurations, semantic assets, schemas, mappings, test definitions, and small sample data. Large generated datasets, local ERP databases, credentials, confidential inputs, and hidden evaluation truth should not be committed to Git.

---

## 3. Strategic approach

### 3.1 The core design

The benchmark is generated from a **canonical enterprise truth layer**. This is the most important architectural decision.

```text
Public/open data seeds + fictional LSC reference data
        +
Open-source ERP-generated records
        |
        v
LSC canonical enterprise truth
  - Stable LSC enterprise identities
  - Business entities, events, relationships, constraints
  - Regional, fiscal, currency, UoM, packaging, and policy context
  - Ground-truth mapping, matching, quality, and reconciliation labels
        |
        +------------------------+------------------------+
        |                        |                        |
        v                        v                        v
ECC-style regional sources   S/4-style regional sources  JDE-style regional sources
        |                        |                        |
        +------------------------+------------------------+
                                 |
                                 v
                Source semantic adapters and harmonization engine
                                 |
                                 v
          Conformed/mastered data products, lineage, and evaluation results
```

Do **not** generate ECC-style, S/4-style, and JDE-style datasets independently. Independent generation makes it impossible to know whether product, party, supplier, organization, order, and event relationships are truly the same across source systems. It also prevents objective scoring of entity-resolution and mapping logic.

### 3.2 Initial objective: semantic correctness, not volume

The initial project goal is **not billions of rows**. The first deliverable should prove:

- Shared business concepts and canonical grain.
- Source-system and regional context.
- Master and reference-data harmonization.
- Mapping and crosswalk governance.
- Entity-resolution evidence.
- Data-quality controls and exception workflows.
- End-to-end source-to-conformed lineage.
- Record, quantity, and value reconciliation.
- Evaluation of deterministic rules, ML, and LLM-assisted mapping proposals.

Increase volume only after these capabilities work at manageable scale.

### 3.3 Initial pilot scale

Use a small-to-medium dataset that can be inspected and iterated quickly.

| Domain | Initial target | Purpose |
|---|---:|---|
| LSC enterprise products/materials | 500–2,000 | Product taxonomy, grades, packaging, alternate IDs, substitutes, UoM, lifecycle, and source-specific classifications |
| LSC enterprise parties | 1,000–5,000 | Customer/supplier roles, hierarchy, sites, duplicates, and entity resolution |
| Organizations and locations | 25–100 | Legal entities, plants, warehouses, sales organizations, and JDE branch/plants |
| Product/source identifiers | 2,000–10,000 | Material/item/SKU/customer-part cross-references |
| Sales-order lines | 10,000–100,000 | Order, fulfillment, delivery, cancellation, invoice, pricing, and status semantics |
| Purchase-order/receipt lines | 5,000–50,000 | Supplier/material relationships, procurement, receipt, lead-time, and quality scenarios |
| Inventory movements/snapshots | 25,000–250,000 | Batch/lot-aware inventory, stock status, facility/location context, UoM conversion, and reconciliation |
| Financial postings | 25,000–250,000 | Currency, fiscal period, chart-of-account, reporting-account, cost, revenue, and reconciliation scenarios |
| Controlled mapping/quality exceptions | 100–500 | Stewardship workflows, rules/ML/LLM evaluation, exception management, and auditability |

Start even smaller if needed: for example, 100 materials, 100 parties, 10 locations, and 1,000 order lines. The minimum requirement is that the data supports the **full lifecycle** from source data through source adapter, mapping, conformance, lineage, reconciliation, and evaluation.

---

## 4. Scope and non-goals

### 4.1 In scope

- Synthetic LSC canonical enterprise data.
- Synthetic ECC-style, S/4-style, and JDE-style source extracts.
- Regional and implementation-specific variation.
- Data produced by locally operated open-source ERP systems.
- Public/open benchmark seeds, subject to license and terms review.
- Product, party, supplier, organization, location, commercial, procurement, inventory, finance, and later operations/reliability domains.
- Specialty-chemical master-data patterns: product family, grade, formulation/specification, packaging, batch/lot, shelf-life where appropriate, and controlled handling classifications.
- Semantic assets: glossary, ontology, SKOS taxonomies, data contracts, source profiles, mappings, crosswalks, SHACL shapes, provenance.
- Ground truth for source-to-canonical mapping, taxonomy crosswalks, entity matching, data quality, reconciliation, and comparability.

### 4.2 Out of scope

- Exporting, reproducing, or redistributing real production ECC, S/4HANA, or JDE data.
- Claiming that generated ERP-style datasets are vendor-generated source extracts.
- Reproducing proprietary SAP or Oracle data schemas in full.
- Production chemical-safety, regulatory, transport, tax, environmental, or legal-compliance logic.
- Real customer, employee, supplier, pricing, bank, tax-registration, contract, formulation, plant, operational, or system-access data.
- Fully autonomous publication of mappings or transformation rules by ML or LLM systems.
- Billion-row generation during the initial semantic and architecture phase.

---

## 5. Data acquisition hierarchy

Use the least sensitive data source that supports the requirement.

```text
1. Public/open benchmark data and open reference data
2. Locally generated records from open-source ERP systems
3. Synthetic data generated from canonical LSC enterprise truth
4. Approved, anonymized, or aggregated internal data
5. Controlled internal extracts in an authorized environment only
```

### 5.1 Public/open sources

| Source | Use in this project | Link |
|---|---|---|
| TPC-H | Seed customer, supplier, part, order, line-item, and geographic relationships; optional transaction-scale testing | [TPC-H](https://www.tpc.org/tpch/) |
| DuckDB TPC-H extension | Generate local TPC-H data for a seed dataset or later scale testing | [DuckDB TPC-H extension](https://duckdb.org/docs/lts/core_extensions/tpch.html) |
| `tpchgen-rs` | Optional streaming/parallel generator for future high-volume use | [tpchgen-rs](https://github.com/datafusion-contrib/tpcgen-rs) |
| TPC-C | Optional seed for customer/order/stock/payment/delivery event sequences | [TPC-C](https://www.tpc.org/tpcc/) |
| SAP Data Hub DINE archive | Optional synthetic SAP-oriented customer/product/sales seed; review license/terms before reuse | [SAP Data Hub DINE](https://github.com/SAP-archive/datahub-dine) |
| SAP BTP Data-to-Value workshop | Optional SAP-oriented scenario and ingestion/modeling reference; review license/terms | [SAP BTP Data-to-Value workshop](https://github.com/SAP-samples/btp-data-to-value-workshop) |
| Open reference data | Countries, currencies, units, languages, geographic/market lists where reuse is permitted | Record source and license for each list |

TPC-H is useful for connected commercial and supply-chain relationships, but it is not an ERP or specialty-chemicals dataset. It must be enriched with LSC material/product hierarchy, packaging, specification, organization, inventory, finance, tax/localization, source-system semantics, regional policies, classifications, and quality defects.

### 5.2 Open-source ERP systems

Use actual open-source ERP records to introduce real application behavior and source-data diversity.

| System | License | Best role | Link |
|---|---|---|---|
| **ERPNext** | GPL-3.0 | Primary operational ERP: parties, products, sales, purchase, inventory, manufacturing, assets, and finance | [ERPNext](https://github.com/frappe/erpnext) |
| **Apache OFBiz** | Apache-2.0 | Primary fixture/configuration ERP: controlled seed/demo/ext data, party/order/product/accounting/manufacturing scenarios | [Apache OFBiz](https://github.com/apache/ofbiz-framework) |
| **Odoo Community** | Core repository LGPLv3; verify modules | Supplemental source: partner/product/sales/purchase/inventory/manufacturing variation | [Odoo](https://github.com/odoo/odoo) |
| **iDempiere** | GPL-2.0-or-later | Optional later enterprise-style ERP/CRM/SCM diversity | [iDempiere](https://github.com/idempiere/idempiere) |
| **Dolibarr** | GPL-3.0-or-later | Optional lightweight ERP/CRM third source | [Dolibarr](https://github.com/Dolibarr/dolibarr) |

**Recommended starting stack:** ERPNext + Apache OFBiz + DuckDB/TPC-H. Add Odoo Community only after the first end-to-end slice works.

### 5.3 License and provenance rules

For every acquired source, record:

- Source URL, publisher, release/commit, and acquisition date.
- License/terms, attribution requirements, derivative restrictions, and redistribution rights.
- Checksum and retained copy/version where permitted.
- Intended use in this project.
- Data classification and privacy assessment.

A public GitHub repository is not automatically permission to redistribute all embedded data. Verify its license and the terms for any specific dataset or sample material.

---

## 6. LSC canonical enterprise truth model

### 6.1 Purpose

The LSC canonical truth model provides stable enterprise IDs and expected relationships before source-system-specific representation is introduced. It is the ground truth for:

- Source-to-canonical attribute mappings.
- Cross-system entity identity.
- Taxonomy and reference-data mappings.
- Transformation logic.
- Quality defect labels.
- Reconciliation totals.
- Comparability classifications.

### 6.2 Core domains

| Domain | Representative canonical entities |
|---|---|
| Party | `EnterpriseParty`, `Organization`, `Person`, `PartyRole`, `CustomerAccount`, `SupplierAccount`, `PartySite` |
| Product/material | `EnterpriseProduct`, `Material`, `ProductIdentifier`, `ProductClassification`, `ProductSpecification`, `PackagingSpecification`, `SubstituteProduct`, `UnitConversion` |
| Organization | `LegalEntity`, `BusinessUnit`, `SalesOrganization`, `PurchasingOrganization`, `ManufacturingSite`, `Facility`, `Warehouse`, `StorageLocation`, `BranchPlant` |
| Commercial | `Quote`, `QuoteLine`, `SalesOrder`, `SalesOrderLine`, `Delivery`, `Invoice`, `PricingCondition`, `CustomerCommitment` |
| Procurement | `PurchaseOrder`, `PurchaseOrderLine`, `SupplierSite`, `Receipt`, `SupplierMaterialRelationship`, `SourcingRule` |
| Inventory | `InventoryPosition`, `InventoryMovement`, `InventoryStatus`, `BatchLot`, `Allocation`, `AvailableToPromise`, `SupplyConstraint` |
| Finance | `ChartOfAccount`, `ReportingAccount`, `JournalEntry`, `JournalEntryLine`, `CostCenter`, `ProfitCenter`, `CurrencyRate`, `FiscalPeriod` |
| Operations | `Asset`, `WorkOrder`, `OperationalIncident`, `FailureMode`, `MaintenanceActivity`, `ProductionOrder`, `ProductionEvent`, `QualityEvent` |
| Reference | `Country`, `Region`, `Language`, `Currency`, `UnitOfMeasure`, `PackagingType`, `TaxJurisdiction`, `TaxType`, `DocumentStatus`, `ReasonCode` |
| Governance | `SourceSystem`, `SourceInstance`, `SourceRecord`, `MappingRule`, `Crosswalk`, `MatchDecision`, `TransformationRun`, `QualityFinding` |

### 6.3 Stable identifiers

The canonical layer must contain stable, non-source-specific LSC identifiers.

```text
LSC enterprise material: LSC-MAT-00018421
LSC enterprise party: LSC-PARTY-00008421
LSC supplier-material relationship: LSC-SUPMAT-00001281
LSC legal entity: LSC-LE-NA-001
LSC manufacturing site: LSC-SITE-US-HOU-001
LSC sales order: LSC-SO-0000054312
LSC sales-order line: LSC-SOL-0000054312-000010
```

Source-system identifiers are generated as alternate identifiers, not as replacements for LSC enterprise identity.

```text
LSC canonical material: LSC-MAT-00018421

ECC-style material identifier: 000000000004893210
S/4-style product/material identifier: 4893210
JDE-style short item: 837218
JDE-style second item: 412898
ERPNext item code: LSC-BRG-79A
OFBiz product ID: LSC_BRG_79A
Customer material identifier: BRG-79A
```

---

## 7. ERP-style source profiles

### 7.1 Important disclaimer

The following profiles are **synthetic, ERP-inspired source representations**. They model useful semantic differences for LSC data-harmonization testing. They are not copies of vendor schemas and must not be described as real SAP ECC, S/4HANA, or JDE exports.

### 7.2 Initial profiles

| Profile | Key semantic pattern | Regional/local context |
|---|---|---|
| `ecc_style_us01` | Separate customer, supplier/vendor, material, company-code, sales-area, plant/storage perspectives; zero-padded identifiers | LSC United States; USD; English; state/jurisdiction and sales-tax context |
| `s4_style_global01` | Business Partner-centered party identity with customer/supplier roles, sites, and role-specific extensions | LSC global/shared-service master; multi-company roles; group currency |
| `jde_style_us01` | Address Book-centered party identity; customer/supplier relationships; item and branch/plant context; UDC/category-code classification | LSC United States; USD; branch/plant, local status codes, local classifications |
| `erpnext_lab01` | Actual ERPNext business records created through normal application workflow | Fictitious LSC multi-company/warehouse/manufacturing scenario |
| `ofbiz_lab01` | Actual OFBiz records from controlled custom fixtures | Fictitious LSC organizations, materials, parties, orders, inventory, accounting |

### 7.3 Later profiles

| Profile | Purpose |
|---|---|
| `ecc_style_de01` | LSC EUR, VAT concept, German/English descriptions, distinct company-code and material-classification variation |
| `s4_style_latam01` | LSC role model with Spanish/Portuguese labels, local currency, enriched synthetic tax/document context |
| `jde_style_ca01` | LSC CAD, English/French labels, GST/HST-like synthetic context, independent UDC/category-code lists |
| `odoo_lab01` | Actual Odoo Community source data for supplemental model diversity |

---

## 8. Regional, structural, and semantic variation

The benchmark must deliberately generate variation at three distinct levels.

### 8.1 Structural variation

- Different source tables/files and header/line decomposition.
- Different field names, data types, lengths, padding, and identifier formats.
- Different source keys and foreign-key conventions.
- Different grains: order header, schedule line, delivery line, invoice line, inventory snapshot, inventory movement, batch/lot record.
- Different organization/location structures.

### 8.2 Semantic variation

- Customer/vendor records versus Business Partner and role relationships.
- Material/product/item interpretation and alternate-material relationships.
- Product family, grade, application, packaging, and controlled classification semantics.
- Order promise, shipment, delivery, cancellation, backorder, quality hold, release, and invoice status semantics.
- Local classification schemes, material types, item categories, UDCs, category codes, account groups, and reason codes.
- Revenue, cost, inventory status, available-to-promise, batch availability, and fiscal-period policy differences.
- Unit conversion, packaging conversion, currency conversion, and time interpretation.

### 8.3 Data-quality variation

- Duplicate party/material/site records.
- Similar but non-identical legal names.
- Missing or invalid units, packaging conversion factors, dates, country codes, statuses, or classifications.
- Formatting differences such as zero padding, casing, punctuation, abbreviations, and mixed date formats.
- Orphaned records, late-arriving events, historical renames, replaced materials, reused local codes, and changed hierarchies.
- Undocumented local fields and ambiguous code values.

### 8.4 Variation catalogue

| Category | Example | Harmonization capability |
|---|---|---|
| Identifier | `000000000004893210`, `4893210`, `837218`, `LSC-BRG-79A` | Cross-reference and alternate-ID resolution |
| Party model | Customer/vendor vs Business Partner roles vs Address Book | Role ontology and party identity |
| Product/material | Material, product, item, SKU, customer material, substitute | Material identity and taxonomy mapping |
| Organization | Company code/plant/sales org vs branch/plant/business unit | Hierarchy and regional context |
| Units/packaging | KG, LB, L, GAL, DR, IBC, EA, PAL; valid/invalid conversion | UoM and packaging normalization |
| Currency/time | USD/EUR/CAD, fiscal/calendar, timezone | Financial and temporal harmonization |
| Reference code | Material type, UDC, category code, status, tax code, quality code | SKOS crosswalk and semantic mapping |
| Process state | Backordered, allocated, quality-held, released, shipped, delivered, blocked, returned | Event/process normalization |
| Finance | Local segments, reporting-account mapping, cost basis | Finance data harmonization |
| History | Product replacement, renamed party, hierarchy change | Effective dating and provenance |

---

## 9. Scenario design

### 9.1 Initial business scenario

LSC is a fictitious specialty-chemicals manufacturer and distributor. It procures feedstocks and packaging materials, manufactures or blends specialty products, stores inventory at plants and warehouses, and sells products to industrial customers through multiple legal entities and regions.

```text
Fictitious enterprise: Lagos Specialty Chemicals (LSC)

Initial regions:
  - United States
  - Germany/EMEA or Canada

Business model:
  - Procures raw materials, intermediates, packaging, and indirect materials from suppliers.
  - Manufactures, blends, packages, and distributes specialty chemical products.
  - Maintains inventory at manufacturing sites, warehouses, and JDE-style branch plants.
  - Sells packaged products and selected specialty materials to industrial customers.
  - Supports customer-specific material identifiers, contractual pricing, and alternate/substitute materials.
  - Operates multiple legal entities, plants, warehouses, sales organizations, and purchasing organizations.
  - Creates sales, purchase, inventory, delivery, invoice, quality, batch/lot, and journal events.
```

The scenario uses synthetic, non-regulatory classifications. It is not a real chemical-safety, transport, quality, product-stewardship, or compliance model.

### 9.2 Initial process scope

```text
Supplier and material setup
        |
        v
Purchase order -> Receipt -> Quality status -> Inventory movement
        |
        v
Blend/manufacture/package scenario where enabled
        |
        v
Sales quote -> Sales order -> Allocation/backorder -> Delivery -> Invoice
        |
        v
Financial postings and reporting classification
```

### 9.3 Later scenarios

After the initial scope is stable, add:

- Asset maintenance and spare-parts consumption.
- Equipment incident/failure and downtime events.
- Quality holds, returns, claims, and customer-service cases.
- Production orders, recipes/BOM-like relationships, material consumption, yield, and scrap.
- Supplier disruption, logistics delay, inventory rebalancing, and substitution scenarios.
- Cross-domain KPI/measure use cases.

---

## 10. Synthetic generator architecture

```text
Layer 0: Seeds and reference inputs
  - TPC-H/TPC-C subsets where licensed and appropriate
  - Open-source ERP fixture/transaction extracts
  - Fictional LSC names, products, locations, and narratives
  - Controlled reference-data lists

Layer 1: Canonical LSC truth generator
  - LSC enterprise IDs and relationships
  - Master data, transactions, policies, and event chronology
  - Ground-truth mappings and reconciliation totals

Layer 2: Scenario generator
  - Regions, legal entities, currencies, calendars, UoM, packaging, tax context
  - Material/customer/supplier hierarchy and distribution rules
  - Demand, supply, order, inventory, production, and finance event patterns

Layer 3: Source profile generators
  - ECC-style, S/4-style, JDE-style, ERPNext, OFBiz, Odoo profiles
  - Identifier, schema, code, status, grain, and context transformations

Layer 4: Defect and drift injector
  - Missingness, duplication, ambiguity, stale codes, invalid values, late arrivals

Layer 5: Packaging and truth separation
  - Development data, mappings, glossary, ontology, taxonomies
  - Controlled hidden truth for test/evaluation
  - Manifest, hashes, provenance, licenses, and test evidence
```

### 10.1 Recommended implementation stack

| Capability | Recommended tools/pattern |
|---|---|
| Generation/transformation | Python + SQL; DuckDB and/or Polars; DBT if adopted later |
| Local storage | Parquet + DuckDB; PostgreSQL for ERP lab/application databases |
| Synthetic values | `Faker` plus custom fictional providers and curated LSC vocabularies |
| Data contracts | Pydantic/JSON Schema; SQL constraints; DBT/Great Expectations/Soda tests as appropriate |
| Semantic artifacts | RDF/Turtle, SKOS, SHACL, PROV-O-aligned metadata |
| Mapping registry | Versioned YAML/JSON and optional RDF mapping assertions |
| Entity resolution | Deterministic matching rules, scored candidates, steward decisions, gold truth |
| Packaging | Parquet for data; JSON/YAML manifests; Markdown docs; Turtle semantic assets |
| Reproducibility | Python CLI, Makefile/Taskfile, Docker Compose, Git tags, fixed seeds |

### 10.2 Deterministic run configuration

```bash
python -m generators.run \
  --scenario scenarios/lsc-specialty-chemicals-v1.yaml \
  --scale pilot \
  --seed 20260920 \
  --profiles ecc_style_us01,s4_style_global01,jde_style_us01 \
  --release 0.2.0
```

The same scenario, seed, generator version, and profile versions must reproduce the same business identities, relationships, source records, mappings, and expected reconciliation results.

---

## 11. Synthetic data rules

### 11.1 Do not use real sensitive data

Generated data must not include real customer, employee, supplier, bank, tax, contract, formula, manufacturing, quality, production, facility, system, or credential data.

Use:

- Fictional organization and material names.
- Generated, non-real identifiers.
- Synthetic contact/address patterns.
- Synthetic prices, costs, exchange rates, tax context, quality states, and operational narratives.
- Clearly documented non-production policies.

### 11.2 Business consistency rules

The clean canonical dataset must obey business rules. Examples:

- An order line belongs to an order and references a valid customer, material, and fulfillment location.
- A delivery does not predate its order.
- An invoice links to a delivery/order or explicit exception scenario.
- Inventory movements preserve stock balance unless a defined adjustment applies.
- A purchase order references a valid supplier-material relationship unless generated as a controlled exception.
- A material/UoM/packaging conversion is valid inside a defined unit family.
- A party may hold both customer and supplier roles.
- A material can hold multiple source-specific identifiers and customer-specific identifiers.
- Batch/lot relationships are retained where enabled in the scenario.
- Financial postings balance under the selected synthetic accounting policy.
- Tax context is effective dated and regionally consistent according to benchmark policy.

### 11.3 Chemical, safety, and tax caution

Chemical classifications, handling indicators, product specifications, transport references, quality states, and tax values in this benchmark are synthetic semantic examples. They are not safety data sheets, regulatory classifications, transport classifications, product specifications, compliance instructions, tax advice, or production-ready rules.

---

## 12. Data quality and defect injection

A realistic harmonization benchmark must include controlled imperfections. Defects must be labeled in hidden truth so quality controls and AI tools can be evaluated.

| Defect class | Examples | Expected handling |
|---|---|---|
| Completeness | Missing UoM, packaging conversion, customer hierarchy, batch attribute, commitment date | Flag and route to remediation; do not infer without evidence |
| Validity | Invalid currency/unit/status/country, impossible event dates | Reject/quarantine or correct only through approved rule |
| Consistency | Different material lifecycle/classification across sources | Surface conflict; apply survivorship/policy transparently |
| Uniqueness | Duplicate party/material/site/batch record | Entity-resolution or source-quality workflow |
| Conformity | Case, padding, punctuation, date/number format differences | Normalize while retaining source value and rule trace |
| Referential integrity | Orphan order line, missing material/supplier/batch relation | Flag, reject, repair under contract, or generate as known exception |
| Timeliness | Late-arriving delivery, stale price, future-dated quality event | Retain event/extract time and apply late-arrival policy |
| Historical drift | Reused code, renamed material, changed hierarchy | Effective-dated mapping and historical lineage |
| Semantic ambiguity | Local category code or custom field with sparse description | Candidate proposal, evidence retrieval, steward approval |
| Reconciliation anomaly | Intentional total mismatch | Identify, classify, and expose reconciliation exception |

### 12.1 Severity tiers

| Tier | Purpose | Example |
|---|---|---|
| 0 | Clean control | Fully valid data used for baseline pipeline tests |
| 1 | Benign normalization | Case, padding, punctuation, locale date |
| 2 | Contextual mapping | Local classification, packaging/UoM conversion, status translation |
| 3 | Entity ambiguity | Similar legal names, sites, alternate material identifiers |
| 4 | Material issue | Invalid UoM, missing legal entity, conflicting tax/quality context |
| 5 | Controlled adversarial | Misleading label, unseen source field, contradictory evidence |

---

## 13. Mapping, ontology, and taxonomy assets

### 13.1 Business dictionary

The LSC business dictionary defines terms, owners, examples, exclusions, policy, and links to source/canonical representations. At minimum, create definitions for:

- Product, material, item, SKU, grade, package, batch/lot, substitute material.
- Party, organization, customer, supplier, Business Partner, customer site, supplier site.
- Legal entity, company code, business unit, manufacturing site, plant, warehouse, branch/plant.
- Sales order, order line, delivery, invoice, purchase order, receipt.
- Inventory position, inventory movement, quality status, available inventory, allocation.
- Revenue, cost, currency amount, unit of measure, packaging unit, fiscal period.
- Source system, source instance, source record, mapping, crosswalk, match decision, transformation run.

### 13.2 Ontology

Use a lightweight enterprise ontology for durable concepts and relationships. Do not model every source column or code as an ontology class.

Representative concepts:

```text
Party, Organization, BusinessPartner, CustomerRole, SupplierRole
Product, Material, Item, ProductIdentifier, ProductSpecification
PackagingSpecification, BatchLot, UnitOfMeasure
LegalEntity, ManufacturingSite, Facility, Warehouse, BranchPlant
SalesOrder, SalesOrderLine, PurchaseOrder, Delivery, Invoice
InventoryPosition, InventoryMovement, QualityEvent, JournalEntry
SourceSystem, SourceInstance, SourceRecord, CanonicalRecord
MappingRule, Crosswalk, MatchDecision, TransformationActivity
DataQualityAssessment, ReconciliationResult, ComparabilityAssessment
```

### 13.3 Taxonomies and SKOS crosswalks

Use SKOS concept schemes for code lists and classifications that evolve or vary by source/region.

Examples:

- LSC enterprise material/product hierarchy.
- Material family, product grade, application, package, and lifecycle classification.
- ECC-style material types and groups.
- S/4-style Business Partner groupings and role types.
- JDE-style UDCs and category codes.
- Customer/supplier classifications.
- Organization/market/channel classifications.
- Reporting-account and financial-statement taxonomy.
- Status, reason, quality, incident, and failure classifications.
- Tax, currency, UoM, country, language, payment term, and incoterm schemes.

Use mapping relations honestly:

- `exactMatch` — equivalent under approved policy.
- `closeMatch` — similar but not fully interchangeable.
- `broadMatch` / `narrowMatch` — source and target differ in granularity.
- `transform` — requires conditional logic, calculation, split/merge, or lookup.
- `noMatch` / `unknown` — do not force an unsupported mapping.

---

## 14. Mapping specification

Every source-to-canonical mapping must be context-aware and versioned.

```yaml
mapping_id: MAP-JDE-US01-ITEM-CATEGORY07-001
status: approved
mapping_version: 1.0.0

authority:
  business_owner: LSC Global Product Data Owner
  data_steward: LSC JDE North America Product Steward
  approved_date: 2026-09-20

source:
  system: JDE_STYLE
  source_instance: jde_style_us01
  table: item_master
  field: category_code_07
  label: Category Code 07
  source_scheme: lsc-jde-us01-category-code-07
  country: US
  legal_entity: LSC-LE-US-001
  branch_plant_scope: [LSC-BP100, LSC-BP110]

target:
  canonical_entity: EnterpriseProduct
  canonical_attribute: productClassification
  target_scheme: lsc-enterprise-product-taxonomy-v1

mapping_relation: closeMatch
transformation:
  type: reference_crosswalk
  crosswalk_id: XWALK-LSC-JDE-US01-CC07-PRODUCT-V1

validity:
  effective_from: 2025-01-01
  effective_to: null

quality_controls:
  reject_unmapped: true
  allowed_source_values: [ADD, COAT, SURF, PACK]

lineage:
  retain_source_value: true
  retain_mapping_id: true
  retain_mapping_version: true
```

The matching key for mapping resolution should include, where relevant:

\[
(\text{system},\ \text{source instance},\ \text{source object},\ \text{field/code scheme},\ \text{country},\ \text{legal entity},\ \text{organization},\ \text{effective date},\ \text{mapping version})
\]

---

## 15. Entity-resolution ground truth

Entity resolution is central to the benchmark. The data should include deterministic matches, probable matches, non-matches, and intentionally ambiguous cases.

### 15.1 Match evidence

Use evidence such as:

- Approved source cross-reference.
- Synthetic external identifier.
- Normalized legal name.
- Address/site relationship.
- Contact domain or controlled contact identifier.
- Material manufacturer number or customer material number.
- UoM/specification/product hierarchy.
- Organization and effective-date context.

### 15.2 Match decision model

```text
MatchDecision
  - source_record_id
  - canonical_entity_id
  - match_method: deterministic | probabilistic | steward_approved
  - confidence_score
  - evidence_attributes
  - status: accepted | rejected | pending | superseded
  - reviewer
  - decision_timestamp
  - effective_from / effective_to
```

### 15.3 Evaluation metrics

- Pairwise precision, recall, and F1.
- False merge rate.
- False split rate.
- Manual-review rate.
- Accuracy by source pair, region, entity type, and ambiguity tier.

False merges should be treated as particularly serious because incorrectly merging two distinct LSC customers, suppliers, or materials can distort financial and operational analysis.

---

## 16. Rules, ML, and LLM strategy

### 16.1 Deterministic execution is authoritative

Certified outputs must be generated by approved and tested deterministic rules.

```text
Source profile and source records
        |
        v
Approved mappings, crosswalks, and transformation rules
        |
        v
Conformed records and data products
        |
        v
Quality checks, reconciliation, lineage, comparability
```

### 16.2 Traditional ML use cases

Use ML for candidate ranking and scoring, not unapproved transformation execution.

- Field/attribute mapping ranking using names, labels, descriptions, data type, profiles, sample values, relationship context, and semantic constraints.
- Entity-resolution scoring for parties, materials, suppliers, sites, and locations.
- Code crosswalk candidate ranking.
- Data-quality anomaly and drift detection.

### 16.3 LLM use cases

Use retrieval-augmented LLMs as a semantic-mapping copilot.

Appropriate inputs:

- Source system/instance and regional context.
- Table/file and field names, labels, data types, profiles, and permitted sample values.
- Relevant source documentation and configuration glossary.
- Candidate canonical concepts and taxonomy values.
- Related approved mappings and business definitions.

Required structured output:

```json
{
  "candidate_target_concept": "lsc:ProductClassification",
  "mapping_relation": "closeMatch",
  "confidence": 0.78,
  "evidence_ids": ["DOC-123", "MAP-456"],
  "rationale": "Short evidence-grounded explanation",
  "ambiguities": ["Source code-list version is unknown"],
  "proposed_transformation": "Lookup using XWALK-LSC-JDE-US01-CC07-PRODUCT-V1"
}
```

### 16.4 Approval gates

An AI proposal cannot become an approved mapping unless:

- The target concept exists in the approved semantic model.
- The relationship type is permitted.
- Data types and source/target profiles are compatible.
- Required context is present.
- Evidence is retrievable and valid.
- SHACL/data-contract/quality rules pass.
- Required business and steward approvals are recorded.
- Transformation and reconciliation tests pass.

Do not apply LLMs to every transaction row. Use LLMs for metadata, documentation, profiles, distinct code values, candidate mappings, anomalies, samples, and explanations. Use deterministic data-engineering tools to execute approved transformations at scale.

---

## 17. Development and evaluation split

### 17.1 Development package

The development package may contain:

- Raw synthetic ERP-style source files.
- Source semantic profiles and data profiles.
- LSC business glossary, ontology, and taxonomies.
- Partial approved mappings and crosswalks.
- Training/validation entity-match examples.
- Sample quality rules and known issue patterns.

### 17.2 Controlled hidden truth

Keep the following outside any public repository or development environment used for benchmark tuning:

- Canonical truth IDs for held-out examples.
- Held-out source-to-canonical mappings.
- Held-out taxonomy alignments.
- Entity-match clusters/pairs.
- Expected transformations.
- Reconciliation totals.
- Defect labels and severity.
- Comparability classification truth.

### 17.3 Evaluation tasks

| Task | Input | Metrics |
|---|---|---|
| Field/schema mapping | Source metadata/profile to canonical attribute | Top-1 accuracy, Top-3 recall, precision/recall/F1, transformation correctness |
| Code/taxonomy mapping | Local code lists and descriptions to LSC taxonomy | Coverage, relation accuracy, unsupported mapping rate |
| Entity resolution | Candidate party/material/supplier/location records | Precision, recall, F1, false merge/split, review rate |
| Quality detection | Source data and profiles | Precision/recall by defect type and severity |
| Reconciliation | Raw/canonical/variant/conformed data | Count, quantity, amount, key, and status differences |
| Explanation quality | LLM/ML proposal plus evidence | Evidence-grounding, ambiguity detection, unsupported claim rate |
| Comparability | Source context and policies | Classification accuracy and policy compliance |

Split evaluation sets by entire semantic families, regional profiles, fields, code schemes, or mapping types—not random rows. A random split leaks near-identical patterns and overstates quality.

---

## 18. Source data format, lineage, and manifests

### 18.1 File formats

| Use | Recommended format |
|---|---|
| Main generated tabular data | Parquet |
| Small samples and human inspection | CSV |
| Scenario and mapping configuration | YAML or JSON |
| Semantic assets | Turtle (`.ttl`) |
| Data contracts | JSON Schema / YAML |
| Run manifests and checksums | JSON |
| Documentation | Markdown |

Use fixed decimal types for monetary measures in the canonical/conformed layers. Do not use floating point for currency amounts.

### 18.2 Required dataset manifest

```json
{
  "benchmark": "lsc-enterprise-data-harmonization",
  "release": "0.2.0",
  "generated_at": "2026-09-20T00:00:00Z",
  "synthetic": true,
  "generator": {
    "git_commit": "<commit>",
    "seed": 20260920,
    "scenario": "lsc-specialty-chemicals-v1",
    "scale_profile": "pilot"
  },
  "profiles": [
    "ecc_style_us01",
    "s4_style_global01",
    "jde_style_us01",
    "erpnext_lab01"
  ],
  "artifacts": [
    {
      "path": "variants/ecc_style_us01/customers.parquet",
      "classification": "synthetic",
      "schema_version": "1.0.0",
      "checksum": "sha256:<hash>"
    }
  ],
  "restrictions": [
    "No real personal data",
    "No production ERP extracts",
    "No chemical-safety, tax, accounting, or regulatory advice",
    "ERP-inspired profiles are not vendor database replicas"
  ]
}
```

### 18.3 Source-to-conformed lineage

Each derived record should support a lineage path:

```text
Conformed LSC record
  -> canonical LSC record
  -> source adapter
  -> source record
  -> source system and source instance
  -> mapping rule and mapping version
  -> crosswalk/taxonomy version where applicable
  -> transformation run and generator release
```

---

## 19. Recommended repository structure

```text
ERP_Data_Harmonization/
├── README.md
├── LICENSE
├── NOTICE
├── .gitignore
├── docs/
│   ├── synthetic-data-generation-strategy.md
│   ├── data-dictionary.md
│   ├── source-system-profiles.md
│   ├── regional-context-model.md
│   ├── mapping-governance.md
│   ├── evaluation-guide.md
│   ├── reproducibility-guide.md
│   └── architecture.md
├── licenses/
│   ├── third-party-notices.md
│   ├── source-register.csv
│   └── data-use-policy.md
├── scenarios/
│   ├── lsc-specialty-chemicals-v1.yaml
│   ├── profiles/
│   │   ├── ecc_style_us01.yaml
│   │   ├── s4_style_global01.yaml
│   │   ├── jde_style_us01.yaml
│   │   └── defect_profile_v1.yaml
│   └── reference-data/
├── generators/
│   ├── __init__.py
│   ├── run.py
│   ├── canonical.py
│   ├── variants/
│   │   ├── ecc_style.py
│   │   ├── s4_style.py
│   │   ├── jde_style.py
│   │   └── defects.py
│   ├── fixtures/
│   └── packaging/
├── schemas/
│   ├── canonical/
│   ├── source/
│   └── contracts/
├── ontology/
│   ├── enterprise-core.ttl
│   ├── master-data.ttl
│   ├── supply-chain.ttl
│   ├── finance.ttl
│   ├── provenance.ttl
│   └── shapes.ttl
├── taxonomies/
│   ├── lsc-enterprise-product.ttl
│   ├── source-code-schemes.ttl
│   ├── organization.ttl
│   ├── finance.ttl
│   └── tax.ttl
├── mappings/
│   ├── training/
│   ├── validation/
│   ├── regional-overrides/
│   └── mapping-registry.yaml
├── erp-labs/
│   ├── erpnext/
│   ├── ofbiz/
│   └── odoo/
├── sample-data/
│   ├── canonical/
│   ├── variants/
│   └── manifests/
├── tests/
│   ├── unit/
│   ├── data-contracts/
│   ├── quality/
│   ├── semantic/
│   ├── reconciliation/
│   └── reproducibility/
├── evaluation/
│   ├── mapping/
│   ├── entity-resolution/
│   ├── quality/
│   ├── reconciliation/
│   └── score.py
├── scripts/
│   ├── generate_pilot.sh
│   ├── validate_pilot.sh
│   └── export_erp_lab_data.sh
└── manifests/
    ├── benchmark-manifest.json
    └── checksums.sha256
```

### 19.1 What not to commit

Add appropriate `.gitignore` entries for:

```text
# Generated data and large artifacts
data/
output/
artifacts/
*.parquet
*.duckdb
*.db
*.sqlite
*.sqlite3

# Local ERP data and secrets
erp-labs/**/sites/
erp-labs/**/volumes/
erp-labs/**/.env
erp-labs/**/secrets/
.env
.env.*

# Hidden evaluation truth
truth-controlled/
evaluation/hidden/

# Python/build cache
__pycache__/
.pytest_cache/
.venv/
venv/
```

Commit only small, explicitly approved samples under `sample-data/`, never complete generated datasets unless the repository is deliberately designed and licensed as a data-release repository.

---

## 20. Implementation roadmap

### Phase 1 — Foundation and thin slice

**Goal:** Prove the complete lifecycle with small, inspectable LSC data.

1. Create the repository structure and add this document.
2. Define the fictional LSC scenario and canonical schemas.
3. Create initial LSC glossary, ontology module, material taxonomy, and mapping template.
4. Generate 100 materials, 100 parties, 10 locations, and 1,000 order lines.
5. Generate `ecc_style_us01`, `s4_style_global01`, and `jde_style_us01` extracts.
6. Implement basic source-to-canonical mappings and material/party cross-references.
7. Validate record/quantity/value reconciliation and lineage.
8. Add one controlled formatting defect and one controlled entity ambiguity.

**Exit criteria:** A sample LSC conformed record can be traced from enterprise entity/event through a mapping rule to its source profile and source record.

### Phase 2 — Pilot benchmark

**Goal:** Reach the initial target ranges and add realistic regional/master-data complexity.

1. Expand to 500–2,000 materials and 1,000–5,000 parties.
2. Add U.S. plus Germany/EMEA or Canada regional context.
3. Add material hierarchy, supplier/material relationship, customer hierarchy, UoM/packaging/currency/fiscal-time conversion, and controlled code mappings.
4. Add sales, purchase, inventory, delivery, invoice, quality, batch/lot, and journal events.
5. Deploy ERPNext and/or OFBiz; load fictional LSC data through versioned fixtures/imports.
6. Add source profiles and extraction snapshots for open-source ERP records.
7. Create development versus hidden evaluation split.
8. Add data quality, entity-resolution, and mapping evaluation harnesses.

**Exit criteria:** The LSC pilot supports a cross-system business question and provides source mapping, lineage, reconciliation, quality, and comparability evidence.

### Phase 3 — AI-assisted mapping and broader domains

**Goal:** Demonstrate governed ML/LLM-assisted semantic mapping.

1. Train/test a field-mapping candidate ranker.
2. Add entity-resolution scoring and review workflow.
3. Implement retrieval-augmented LLM mapping proposals with structured outputs and evidence checks.
4. Add held-out code schemes, fields, regional profiles, and mapping relationships.
5. Add finance/reporting-account and synthetic tax-context mappings.
6. Add Odoo Community or another source only if it provides distinct learning value.

**Exit criteria:** AI-assisted proposals are benchmarked against hidden truth and cannot bypass deterministic approval/execution controls.

### Phase 4 — Optional scale and operational extension

**Goal:** Add performance scale only when needed, then link operational/reliability data.

1. Increase to TPC-H SF 1–10, then SF 10–30 only for explicit integration/performance tests.
2. Write data as partitioned Parquet with manifests and reproducibility tests.
3. Scale to SF 100+ only for a stated engineering objective.
4. Add asset, work order, incident, maintenance, production, quality, and downtime domains.
5. Demonstrate how conformed LSC master/reference data connects financial, commercial, supply-chain, and operations questions.

**Exit criteria:** Performance results and resource requirements are measured, and semantic/correctness controls still pass at the selected scale.

---

## 21. Success criteria

The synthetic-data capability is successful when:

- Data is reproducible using a declared scenario, generator version, profile version, and seed.
- All portable data is synthetic, open, or approved for use with recorded provenance and license.
- The benchmark includes ECC-style, S/4-style, JDE-style, and at least one open-source ERP source profile.
- The dataset represents valid regional and organizational variation as well as controlled defects.
- Product/material, party, supplier, organization, location, UoM, packaging, currency, time, status, and reference-data crosswalks are represented.
- Source-to-canonical mappings are versioned, context-aware, and traceable.
- Entity matching has known truth and quality metrics.
- Data-quality defects have known truth and quality metrics.
- Record, quantity, and value reconciliation is validated through each stage.
- LLM/ML proposals are evidence-bound, evaluated, and subject to approval gates.
- The dataset supports reusable LSC data-harmonization demonstrations rather than a single dashboard or one-off transformation.

---

## 22. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Starting with too much volume | Start with semantic correctness and manageable pilot volumes; defer scale until needed |
| Synthetic data is too clean | Inject cataloged defects, drift, ambiguity, and regional variation |
| Synthetic data is incoherent | Generate from canonical truth with business constraints and reconciliation tests |
| Data resembles proprietary vendor extracts | Use abstract ERP-inspired profiles, clear disclaimer, and avoid reproducing proprietary schemas |
| Licensing ambiguity | Maintain a source register, terms review, attribution, and approved-source process |
| Real data leaks into benchmark | Use fictional generation, isolated environments, review gates, and `.gitignore` controls |
| LLM hallucination | Retrieval grounding, structured outputs, ontology/SHACL checks, stewardship, deterministic execution |
| Evaluation leakage | Keep held-out truth outside public/development repositories |
| Too many platforms too early | Begin with ERPNext + OFBiz + three ERP-inspired profiles; add Odoo/iDempiere later |
| Demo system security exposure | Keep ERP labs isolated; change defaults; do not expose demo systems publicly |
| Synthetic chemical context misunderstood as compliance guidance | Use clear non-production, non-regulatory, and non-safety disclaimer in all related artifacts |

---

## 23. Immediate next steps

1. Create `docs/`, `scenarios/`, `generators/`, `schemas/`, `ontology/`, `taxonomies/`, `mappings/`, `sample-data/`, `tests/`, and `evaluation/` directories.
2. Add this document as `docs/synthetic-data-generation-strategy.md`.
3. Update `.gitignore` for generated data, ERP volumes, secrets, and hidden truth.
4. Define `lsc-specialty-chemicals-v1.yaml` with two regions, three source profiles, and pilot-scale volumes.
5. Create initial canonical schemas for `EnterpriseMaterial`, `EnterpriseParty`, `LegalEntity`, `ManufacturingSite`, `SalesOrderLine`, `PurchaseOrderLine`, `InventoryMovement`, `BatchLot`, and `JournalEntryLine`.
6. Generate the thin slice: 100 materials, 100 parties, 10 locations, and 1,000 order lines.
7. Build three source-profile generators: ECC-style, S/4-style, and JDE-style.
8. Create one material-taxonomy crosswalk and one party-match ground-truth example.
9. Implement simple reconciliation tests and a source-to-canonical lineage manifest.
10. Only then expand data volume, add open-source ERP labs, and introduce ML/LLM-assisted mapping.

---

## Appendix A — Standards and reference links

### Data and ERP sources

- [TPC-H](https://www.tpc.org/tpch/)
- [TPC-H specification](https://www.tpc.org/tpc_documents_current_versions/pdf/tpc-h_v2.17.1.pdf)
- [TPC-C](https://www.tpc.org/tpcc/)
- [DuckDB TPC-H extension](https://duckdb.org/docs/lts/core_extensions/tpch.html)
- [tpchgen-rs](https://github.com/datafusion-contrib/tpcgen-rs)
- [ERPNext](https://github.com/frappe/erpnext)
- [Apache OFBiz](https://github.com/apache/ofbiz-framework)
- [Odoo Community](https://github.com/odoo/odoo)
- [iDempiere](https://github.com/idempiere/idempiere)
- [Dolibarr](https://github.com/Dolibarr/dolibarr)

### Semantic and evaluation standards

- [W3C SKOS Reference](https://www.w3.org/TR/skos-reference/)
- [W3C PROV-O](https://www.w3.org/TR/prov-o/)
- [W3C SHACL](https://www.w3.org/TR/shacl/)
- [Ontology Alignment Evaluation Initiative](https://oaei.ontologymatching.org/)
- [OAEI Crosswalks schema-matching track](https://oaei.ontologymatching.org/2022/metadata/index.html)
- [OAEI-LLM benchmark paper](https://arxiv.org/html/2409.14038v1)

---

## Appendix B — Minimal pilot manifest

```json
{
  "benchmark": "lsc-enterprise-data-harmonization",
  "release": "0.2.0",
  "generated_at": "2026-09-20T00:00:00Z",
  "synthetic": true,
  "generator": {
    "git_commit": "<commit>",
    "seed": 20260920,
    "scenario": "lsc-specialty-chemicals-v1",
    "scale_profile": "thin-slice"
  },
  "profiles": [
    "ecc_style_us01",
    "s4_style_global01",
    "jde_style_us01"
  ],
  "counts": {
    "lsc_enterprise_materials": 100,
    "lsc_enterprise_parties": 100,
    "organizations_locations": 10,
    "sales_order_lines": 1000
  },
  "restrictions": [
    "No real personal data",
    "No production ERP extracts",
    "No chemical-safety, tax, accounting, or regulatory advice",
    "ERP-inspired profiles are not vendor database replicas"
  ]
}
```

---

## Appendix C — Pilot acceptance checklist

- [ ] Source register and license/provenance metadata exist for each acquired input.
- [ ] LSC canonical truth has stable IDs, documented grain, and business constraints.
- [ ] Three ERP-inspired source profiles are generated from the same LSC canonical truth.
- [ ] At least two regional/localization contexts are represented or planned in a versioned profile.
- [ ] Material, party, organization, UoM, packaging, currency, time, and reference-data mappings exist.
- [ ] At least one material/taxonomy crosswalk and one party match decision are recorded.
- [ ] Source-to-canonical mappings are versioned and context-aware.
- [ ] Record, quantity, and value reconciliation passes for the clean scenario.
- [ ] At least one known quality defect and one known semantic ambiguity are included.
- [ ] A conformed record can be traced to source record, mapping rule, and generator run.
- [ ] No real personal, confidential, proprietary, chemical-safety, or production data is present.
- [ ] Hidden evaluation truth is separated from development assets.
- [ ] Volume remains small enough for business and steward review; scale-up is deferred until the pilot works.
