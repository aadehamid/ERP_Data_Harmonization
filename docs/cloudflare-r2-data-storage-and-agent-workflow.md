# Cloudflare R2 Data Storage and Agent Workflow
## LSC Enterprise Data Harmonization Benchmark

**Repository:** `aadehamid/ERP_Data_Harmonization`  
**Fictitious enterprise:** Lagos Specialty Chemicals (LSC)  
**Document status:** Draft for implementation  
**Version:** 0.1.0  
**Date:** 2026-09-20  
**Related documents:**

- `README.md`
- `docs/synthetic-data-generation-strategy.md`
- `docs/data-acquisition-and-synthetic-generation-strategy.md`

---

## 1. Purpose

This document defines how the LSC Enterprise Data Harmonization project uses **Cloudflare R2** as the durable store for synthetic datasets, public-source inputs, ERP-lab extracts, processed Parquet outputs, evaluation artifacts, and data-generation manifests.

The project must follow this storage rule:

```text
Cloudflare R2 = durable store for large, shared, and generated project data
Local disk     = temporary scratch space for download, processing, validation, and upload
GitHub         = code, documentation, semantic assets, schemas, mappings, tests, and small golden fixtures
```

R2 is the system of record for durable benchmark data. GitHub is **not** the warehouse. Large Parquet data, raw source archives, ERP database volumes, generated source extracts, and hidden evaluation truth must not be committed to the repository.

This workflow is based on the attached Cloudflare R2 agent guide. [file:115]

---

## 2. Scope

R2 stores durable data produced or used by the LSC benchmark:

- Raw public/open source data inputs, where the license and terms permit retention.
- Raw open-source ERP extracts generated locally from ERPNext, Apache OFBiz, or later Odoo Community.
- Canonical LSC enterprise truth datasets.
- ECC-style, S/4-style, and JDE-style synthetic source variants.
- Curated/conformed data products in Parquet.
- Reference-data extracts, taxonomy snapshots, and mapping-package exports when they are too large or generated for Git.
- Quality exceptions, reconciliation outputs, and performance results.
- Development versus hidden evaluation artifacts, with separate access controls and prefixes.
- Dataset manifests, checksums, release metadata, and small adjacent notes.

R2 does **not** replace GitHub for:

- Source code.
- Markdown documentation.
- Ontologies, taxonomies, SHACL shapes, schemas, mapping definitions, and tests.
- Small, intentionally versioned golden fixtures.
- Infrastructure templates such as Docker Compose, Makefiles, and CI configuration.

---

## 3. Core storage principles

### 3.1 One bucket per project

Use **one Cloudflare R2 bucket for this project only**. Do not use a bucket assigned to another LSC initiative, such as SCADA/OT harmonization, and do not store another project inside this benchmark bucket.

The project bucket name must be confirmed before the first write. A recommended name is:

```text
lsc-erp-data-harmonization
```

The actual bucket name is the only R2 connection/storage value that should vary by project. Do not create a second bucket for the same project unless explicitly requested.

### 3.2 Durable data belongs in R2

The durable-storage decision is straightforward:

| Asset | Primary location | Reason |
|---|---|---|
| Generator code, documentation, ontology, taxonomy, mappings, schemas, tests | GitHub | Small, version-controlled, code-reviewable assets |
| Small approved sample fixtures | GitHub | Useful for fast test execution and code review |
| Raw public data archives | R2 `raw/` | Potentially large, immutable input artifacts |
| Large generated Parquet datasets | R2 `cache/` | Durable, shareable, not suitable for Git history |
| ERPNext/OFBiz local database volumes | Local container volume; optional R2 export/backup | Live databases are not Git artifacts |
| ERP source extracts | R2 `raw/erp-labs/` | Immutable source snapshots for reproducibility |
| Canonical truth and conformed datasets | R2 `cache/` | Durable data-product storage |
| Hidden evaluation truth | R2 restricted prefix or separate controlled access policy | Must not leak into the development repository |
| Human-readable run notes/manifest summaries | R2 `notes/` and GitHub docs | Keep data-adjacent release notes durable and code-level docs versioned |

### 3.3 Local disk is scratch only

A generation or harmonization job should:

1. Download or stream only the required R2 objects.
2. Process data locally in a temporary work area.
3. Validate contracts, quality rules, mappings, reconciliation, and manifests.
4. Upload durable outputs to the same project R2 bucket.
5. Remove local downloads and intermediates when the job completes.

Do not depend on a laptop, a one-time notebook session, or chat attachment storage as the durable location for generated benchmark data.

### 3.4 Never place credentials in code or chat

R2 Access Key ID and Secret Access Key must be obtained from a secret manager, connector secret, CI secret store, or local environment secret file that is excluded from Git.

Never:

- Paste access keys or secret keys into chat, Markdown files, notebooks, source code, commits, logs, or issues.
- Commit `.env` files containing credentials.
- Print environment variables or boto3 client configuration containing secrets.
- Store credentials inside R2 objects.

---

## 4. R2 connection standard

Use the following fixed Cloudflare R2 connection settings for this project.

| Field | Value |
|---|---|
| Account ID | `011701390f6fee966f04b48182e37f9e` |
| Endpoint | `https://011701390f6fee966f04b48182e37f9e.r2.cloudflarestorage.com` |
| Region | `auto` |
| Signature version | `s3v4` |
| Client library | `boto3` using the S3 API |
| Access Key ID | Obtain from R2 API-token secret storage; never write in repo/chat |
| Secret Access Key | Obtain from R2 API-token secret storage; never write in repo/chat |

Do not change the Account ID, endpoint, region, signature version, or default client library per task. The project-specific values are the bucket name and the object prefix.

### 4.1 Python connection example

```python
import os
import boto3
from botocore.config import Config

ACCOUNT_ID = "011701390f6fee966f04b48182e37f9e"
BUCKET = os.environ["LSC_ERP_R2_BUCKET"]
ACCESS_KEY_ID = os.environ["R2_ACCESS_KEY_ID"]
SECRET_ACCESS_KEY = os.environ["R2_SECRET_ACCESS_KEY"]

client = boto3.client(
    "s3",
    endpoint_url=f"https://{ACCOUNT_ID}.r2.cloudflarestorage.com",
    aws_access_key_id=ACCESS_KEY_ID,
    aws_secret_access_key=SECRET_ACCESS_KEY,
    region_name="auto",
    config=Config(signature_version="s3v4"),
)
```

Use a project-local `.env.example` only for variable names, never values:

```bash
LSC_ERP_R2_BUCKET=lsc-erp-data-harmonization
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
```

Add `.env` and `.env.*` to `.gitignore` while allowing `.env.example` to be committed.

### 4.2 Connectivity check

Before writing data, verify the expected bucket and prefix with a read-only listing where possible:

```python
response = client.list_objects_v2(Bucket=BUCKET, Prefix="notes/")
for obj in response.get("Contents", []):
    print(obj["Key"], obj["Size"])
```

If a write probe is necessary, write only a tiny object under `_probe/` or `notes/`, verify it, and remove it. Never point a connectivity test at live `raw/` or `cache/` prefixes.

---

## 5. Bucket layout

The benchmark uses a stable prefix tree inside the project bucket.

```text
lsc-erp-data-harmonization/
├── raw/                           # Immutable source inputs and source snapshots
│   ├── public/                    # Public/open inputs, retained only under approved terms
│   │   ├── tpch/
│   │   ├── tpcc/
│   │   └── reference-data/
│   ├── erp-labs/                  # Extracts from locally operated open-source ERP systems
│   │   ├── erpnext_lab01/
│   │   ├── ofbiz_lab01/
│   │   └── odoo_lab01/
│   └── manifests/                 # Input/source manifests and checksums
│
├── cache/                         # Durable generated/processed analytical datasets
│   ├── canonical/                 # LSC canonical enterprise truth
│   │   └── release=<release>/
│   ├── variants/                  # ERP-inspired source variants
│   │   ├── profile=ecc_style_us01/
│   │   ├── profile=s4_style_global01/
│   │   └── profile=jde_style_us01/
│   ├── conformed/                 # Harmonized/mastered data products
│   │   ├── product/
│   │   ├── party/
│   │   ├── organization/
│   │   ├── sales/
│   │   ├── procurement/
│   │   ├── inventory/
│   │   └── finance/
│   ├── reference/                 # Generated reference-data/controlled-vocabulary exports
│   ├── quality/                   # Quality findings, reject/quarantine extracts, profiling outputs
│   ├── reconciliation/            # Reconciliation output and control totals
│   ├── performance/               # Generation and transformation benchmark reports
│   └── manifests/                 # Generated-data manifests and checksums
│
├── exports/                       # Curated deliverables for other tools/environments
│   ├── erp-imports/               # ERPNext/OFBiz/Odoo import packages
│   ├── analytics/                 # Curated extracts intended for BI/semantic consumers
│   ├── graph/                     # RDF/CSV graph import exports when needed
│   └── releases/                  # Packaged approved benchmark releases
│
├── evaluation/                    # Evaluation artifacts; apply strict access controls
│   ├── development/               # Shareable mapping/matching evaluation assets
│   ├── validation/                # Controlled validation datasets
│   └── hidden/                    # Held-out truth; never commit or expose to model tuning
│
├── notes/                         # Small, human-readable data-adjacent notes and release summaries
│   ├── source-notes/
│   ├── run-notes/
│   └── release-notes/
│
└── _probe/                        # Tiny disposable connectivity probes only
```

### 5.1 Prefix responsibilities

| Prefix | Purpose | Write policy |
|---|---|---|
| `raw/` | Original inputs and immutable ERP source snapshots | Append new versioned objects; do not overwrite silently |
| `cache/` | Canonical, variant, conformed, quality, reconciliation, and performance outputs | Write only via versioned generation/transformation runs |
| `exports/` | Deliberately consumable outputs for other tools | Write after validation and release checks |
| `evaluation/development/` | Non-sensitive development labels and benchmark assets | Versioned write allowed |
| `evaluation/hidden/` | Held-out test truth and scoring inputs | Restricted write/read; never use for model tuning |
| `notes/` | Small human-readable run/release notes | Versioned write allowed |
| `_probe/` | Connectivity probes | Disposable only; clean up after use |

---

## 6. Object naming and versioning

### 6.1 Required dimensions in object keys

Where applicable, include the following in key paths or object metadata:

- Dataset/domain name.
- Release or run ID.
- Scenario name.
- Source profile/system instance.
- Region/country and legal entity if a partition is scoped that way.
- Schema version.
- Generation seed.
- Date/time or effective period for time-partitioned data.

### 6.2 Recommended examples

```text
raw/public/tpch/sf=1/source_version=2026-09-20/lineitem.parquet
raw/erp-labs/erpnext_lab01/extract_date=2026-09-20/sales_invoice.parquet

cache/canonical/release=0.1.0/domain=enterprise_material/data.parquet
cache/canonical/release=0.1.0/domain=sales_order_line/data.parquet

cache/variants/profile=ecc_style_us01/release=0.1.0/entity=material/data.parquet
cache/variants/profile=s4_style_global01/release=0.1.0/entity=business_partner/data.parquet
cache/variants/profile=jde_style_us01/release=0.1.0/entity=item_master/data.parquet

cache/conformed/release=0.1.0/domain=product/data.parquet
cache/conformed/release=0.1.0/domain=party/data.parquet
cache/conformed/release=0.1.0/domain=inventory/data.parquet

cache/quality/release=0.1.0/rule_set=quality-v1/findings.parquet
cache/reconciliation/release=0.1.0/control_totals.json
cache/manifests/release=0.1.0/benchmark-manifest.json

exports/releases/lsc-harmonization-benchmark-0.1.0.zip
notes/release-notes/release=0.1.0.md
```

### 6.3 Immutability rule

Do not silently overwrite a successful released dataset. Use a new `release=<version>` or `run_id=<identifier>` prefix.

If a dataset must be regenerated because of a defect:

1. Create a new run/release prefix.
2. Record the reason, changed generator version, scenario change, and migration implications in `notes/`.
3. Update the repository manifest/reference to the approved release.
4. Keep the prior release for reproducibility unless storage-retention policy requires deletion.

---

## 7. Data lifecycle workflow

### 7.1 Standard workflow

```text
1. Confirm the LSC ERP Harmonization bucket and target prefix.
2. Load R2 secrets from an approved secret store or local protected environment.
3. List/read only the required objects from R2.
4. Download or stream inputs to local scratch storage.
5. Generate, transform, profile, map, validate, and reconcile locally or in approved compute.
6. Write outputs to a new versioned R2 prefix.
7. Write manifest, checksums, run notes, and quality/reconciliation evidence.
8. Validate uploaded objects using size, checksum, schema, and row-count checks.
9. Clean local scratch files and intermediates.
```

### 7.2 Raw input handling

Raw data must be immutable after acquisition or extraction.

- Retain original public files/archives where license permits.
- Retain raw ERP extracts before transformations.
- Do not apply cleansing, renaming, or normalization inside `raw/`.
- Create a source manifest with source, date, license, checksum, extraction method, schema, row counts, and permitted use.
- Use `cache/` for all transformed/normalized forms.

### 7.3 Canonical and variant generation

For every generation run:

1. Retrieve the relevant scenario configuration and reference inputs from GitHub/R2.
2. Generate canonical LSC truth data from declared seed and scenario version.
3. Validate business constraints and baseline reconciliation.
4. Generate ECC-style, S/4-style, JDE-style, and open-source-ERP import/extract artifacts.
5. Inject the selected controlled defect profile.
6. Write canonical and variant data to release-specific `cache/` prefixes.
7. Write a manifest and test report.

### 7.4 Conformed data publication

Before publishing to `cache/conformed/` or `exports/`:

- Mapping version and source-profile version must be recorded.
- Data contract and SHACL/semantic validation must pass, where implemented.
- Record, quantity, and amount reconciliation must be within defined tolerance.
- Quality exceptions must be written to `cache/quality/` with actionable metadata.
- Lineage identifiers must link the conformed output to source objects, mappings, crosswalks, and transformation run.

### 7.5 Local cleanup

After successful validation and upload:

- Delete downloaded raw files, generated intermediate files, temporary database exports, and unneeded Parquet fragments from local scratch.
- Retain local data only if it is explicitly part of a controlled local ERP lab volume or an approved developer cache.
- Do not delete raw R2 objects merely because local processing completed.

---

## 8. Manifests, lineage, and integrity controls

### 8.1 Required manifest fields

Every dataset release should include a machine-readable manifest.

```json
{
  "benchmark": "lsc-enterprise-data-harmonization",
  "release": "0.2.0",
  "run_id": "lsc-gen-20260920-001",
  "generated_at": "2026-09-20T00:00:00Z",
  "synthetic": true,
  "scenario": {
    "name": "lsc-specialty-chemicals-v1",
    "version": "1.0.0",
    "seed": 20260920,
    "scale_profile": "pilot"
  },
  "generator": {
    "repository": "aadehamid/ERP_Data_Harmonization",
    "git_commit": "<commit-sha>",
    "generator_version": "0.2.0"
  },
  "r2": {
    "bucket": "lsc-erp-data-harmonization",
    "canonical_prefix": "cache/canonical/release=0.2.0/",
    "variant_prefixes": [
      "cache/variants/profile=ecc_style_us01/release=0.2.0/",
      "cache/variants/profile=s4_style_global01/release=0.2.0/",
      "cache/variants/profile=jde_style_us01/release=0.2.0/"
    ]
  },
  "artifacts": [
    {
      "key": "cache/canonical/release=0.2.0/domain=enterprise_material/data.parquet",
      "classification": "synthetic",
      "schema_version": "1.0.0",
      "row_count": 1000,
      "sha256": "<hash>"
    }
  ],
  "validation": {
    "data_contract_status": "passed",
    "reconciliation_status": "passed",
    "quality_rule_set": "quality-v1"
  },
  "restrictions": [
    "No real personal data",
    "No production ERP extracts",
    "No chemical-safety, tax, accounting, or regulatory advice",
    "ERP-inspired profiles are not vendor database replicas"
  ]
}
```

### 8.2 Checksums

Record SHA-256 checksums for every release artifact. The manifest itself should also be checksummed and retained in both R2 and, where small enough, GitHub.

### 8.3 Source-to-conformed lineage

Each conformed record or data partition must be traceable through:

```text
Conformed LSC record or data product
  -> canonical LSC entity/event
  -> transformation run
  -> source semantic adapter
  -> source record and source object key
  -> source system/profile and regional context
  -> mapping rule and mapping version
  -> taxonomy/crosswalk version where used
  -> generator scenario, seed, and release manifest
```

Use stable IDs in Parquet columns and retain full lineage relationships in generated provenance exports or a knowledge graph as the implementation matures.

---

## 9. Development, evaluation, and access separation

### 9.1 Development artifacts

`evaluation/development/` can contain:

- Public/shareable source profiles.
- Small sample datasets.
- Glossary, ontology, taxonomy, and mapping examples.
- Training/validation field mapping examples.
- Non-sensitive entity-match examples.
- Quality rule definitions and controlled defect examples.

### 9.2 Hidden evaluation truth

`evaluation/hidden/` contains information that must not be exposed to model training, prompt tuning, or open development workflows:

- Held-out canonical IDs.
- Held-out mapping truth.
- Entity-match gold clusters.
- Expected transformations.
- Defect labels.
- Reconciliation control totals.
- Comparability truth labels.

This prefix requires stricter read/write access than development artifacts. The project should eventually use separate R2 tokens or scoped permissions if multiple contributors/agents access the bucket.

### 9.3 Public-release policy

Before publishing a benchmark release outside the project:

1. Confirm the source/license register permits redistribution.
2. Remove all hidden truth and non-public artifacts.
3. Verify no secrets, internal metadata, real data, or confidential mappings are present.
4. Publish only approved small fixtures in GitHub; distribute larger approved data through R2 or a release-specific delivery mechanism.
5. Include license, attribution, manifest, synthetic-data disclaimer, and reproducibility instructions.

---

## 10. R2 workflow examples

### 10.1 Download a canonical dataset for local validation

```python
from pathlib import Path

local_path = Path("/tmp/lsc-canonical-material.parquet")
client.download_file(
    BUCKET,
    "cache/canonical/release=0.2.0/domain=enterprise_material/data.parquet",
    str(local_path),
)

# Validate/process locally here.
# Delete the file after successful completion.
local_path.unlink(missing_ok=True)
```

### 10.2 Upload a generated source variant

```python
from pathlib import Path

local_path = Path("/tmp/jde_style_us01_item_master.parquet")
key = (
    "cache/variants/profile=jde_style_us01/"
    "release=0.2.0/entity=item_master/data.parquet"
)

client.upload_file(str(local_path), BUCKET, key)
```

### 10.3 Upload manifest and release note

```python
client.upload_file(
    "/tmp/benchmark-manifest.json",
    BUCKET,
    "cache/manifests/release=0.2.0/benchmark-manifest.json",
)

client.upload_file(
    "/tmp/release-0.2.0.md",
    BUCKET,
    "notes/release-notes/release=0.2.0.md",
)
```

### 10.4 Avoid bulk download

Do not download every object under `raw/` or `cache/` by default. List the relevant prefix and retrieve only the required partitions.

```python
response = client.list_objects_v2(
    Bucket=BUCKET,
    Prefix="cache/conformed/release=0.2.0/domain=inventory/",
)

for obj in response.get("Contents", []):
    print(obj["Key"], obj["Size"])
```

---

## 11. Integration with repository workflows

### 11.1 GitHub responsibilities

GitHub should contain:

- Generator code that reads/writes R2 using environment variables and `boto3`.
- Scenario YAML, profile YAML, data contracts, mapping specs, ontology, taxonomy, SHACL, and tests.
- `.env.example` with variable names only.
- Small sample fixtures and golden test cases.
- R2 key conventions, manifests, and reproducibility documentation.

### 11.2 R2 responsibilities

R2 should contain:

- Large source inputs and generated Parquet data.
- Release-specific canonical and source-variant datasets.
- Conformed data products.
- Quality, reconciliation, and performance outputs.
- ERP import/export packages when too large for Git.
- Hidden truth and restricted evaluation assets.

### 11.3 CI/CD and agents

When a CI pipeline or agent needs R2 access:

- Inject `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, and `LSC_ERP_R2_BUCKET` via secure repository/environment secrets.
- Use least-privilege R2 tokens if available.
- Do not echo secrets in logs.
- Use read-only credentials for validation-only jobs when possible.
- Use a dedicated write-capable token only for release/generation jobs.
- Make writes release-scoped and append-only by default.

---

## 12. Retention and cleanup

### 12.1 Retain

Retain the following for each approved benchmark release:

- Raw source/seed manifest and approved input versions.
- Canonical truth release.
- Source-variant release.
- Mapping/taxonomy/schema versions referenced by the release.
- Quality and reconciliation results.
- Release manifest and checksums.
- Release notes.

### 12.2 Remove or expire

Consider lifecycle/retention rules for:

- Superseded exploratory local extracts.
- Failed or incomplete temporary generation outputs.
- `_probe/` connectivity objects.
- Obsolete scratch exports.
- Unused large performance runs once results have been documented and retention policy permits deletion.

Do not remove an artifact required to reproduce a published/reviewed benchmark release unless it has been archived under an approved retention approach.

---

## 13. Security and operating rules

### Always do

- Confirm the correct project bucket before reading or writing.
- Use `boto3` with the fixed R2 endpoint and secret-managed credentials.
- Pull only required data into local scratch.
- Write durable outputs back to the project bucket.
- Use release/version prefixes and manifests.
- Validate checksums, schemas, row counts, and reconciliation after upload.
- Clean local scratch after completion.
- Keep GitHub limited to code, docs, semantic assets, mappings, tests, and small fixtures.

### Never do

- Do not put two projects in one bucket.
- Do not write LSC ERP Harmonization data into another LSC project bucket.
- Do not use the AWS CLI as the default project path; use `boto3`.
- Do not store durable generated datasets only on a laptop, in a notebook runtime, or in chat.
- Do not commit large generated data or ERP database volumes to GitHub.
- Do not paste R2 credentials into chat, documents, source code, or logs.
- Do not overwrite released data silently.
- Do not run write probes against live `raw/` or `cache/` prefixes.
- Do not expose hidden evaluation truth to mapping-model training or prompt tuning.

---

## 14. Immediate implementation checklist

- [ ] Confirm the dedicated R2 bucket name for this project.
- [ ] Create the bucket if it does not exist, following the one-bucket-per-project rule.
- [ ] Create the stable prefix tree: `raw/`, `cache/`, `exports/`, `evaluation/`, `notes/`, and `_probe/`.
- [ ] Add `boto3` and `botocore` to project dependencies.
- [ ] Add `.env.example` with `LSC_ERP_R2_BUCKET`, `R2_ACCESS_KEY_ID`, and `R2_SECRET_ACCESS_KEY` variable names only.
- [ ] Update `.gitignore` to exclude `.env`, generated Parquet, local databases, ERP volumes, and hidden truth.
- [ ] Implement `scripts/r2_client.py` or equivalent shared client factory using the fixed connection standard.
- [ ] Implement manifest creation and checksum validation.
- [ ] Upload a small pilot canonical dataset and corresponding manifest to a versioned `cache/canonical/` prefix.
- [ ] Verify source-to-conformed lineage includes R2 object keys and release identifiers.
- [ ] Establish restricted handling for `evaluation/hidden/` before AI/ML benchmark work begins.

---

## 15. Source guide

This document is derived from the attached **Cloudflare R2 — generic agent guide**, which establishes the durable-storage model, fixed connection parameters, one-bucket-per-project rule, `boto3` client requirement, local-scratch workflow, and credential-handling rules. [file:115]
