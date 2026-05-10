# GCP Data Engineer

## Enforcing Code Quality

<!-- TOC -->

- [GCP Data Engineer](#gcp-data-engineer)
  - [Enforcing Code Quality](#enforcing-code-quality)
  - [YAML Linting](#yaml-linting)
  - [Pylint for python linting](#pylint-for-python-linting)
  - [Ruff for python linting and quick fixing](#ruff-for-python-linting-and-quick-fixing)
    - [Pylint vs. Ruff: Side-by-Side Comparison](#pylint-vs-ruff-side-by-side-comparison)
      - [1. Performance and Speed](#1-performance-and-speed)
      - [2. Consolidation](#2-consolidation)
      - [3. Deep Analysis](#3-deep-analysis)
  - [Markdown Linting](#markdown-linting)
  - [SQL Linting](#sql-linting)
  - [pre-commit hooks](#pre-commit-hooks)

<!-- /TOC -->

## YAML Linting

- YAML linting with [custom configuration](https://yamllint.readthedocs.io/en/stable/configuration.html) for `.yamllint`

```bash
# check which files will be linted by default
yamllint --list-files .

# lint a specific file
yamllint my_file.yml

# OR
yamllint .
```

## [Pylint for python linting](https://pylint.readthedocs.io/en/latest/)

```bash
# lint a specific file
pylint my_file.py

# lint all Python files in the current directory
pylint .

# lint with a custom configuration file
pylint --rcfile=.pylintrc my_file.py
```

## [Ruff for python linting and quick fixing](https://docs.astral.sh/ruff/)

```bash
# lint all Python files in the current directory
ruff check .

# let the linter fix your code
ruff check --fix .

# apply formatting rules to all Python files in the current directory
ruff format .
```

### Pylint vs. Ruff: Side-by-Side Comparison

This document provides a detailed comparison between Pylint and Ruff to help you decide which tool (or combination) fits your workflow.

| Feature               | Ruff                              | Pylint                        |
|:----------------------|:----------------------------------|:------------------------------|
| Language              | Rust (Compiled)                   | Python (Interpreted)          |
| Performance           | Extremely Fast (ms)               | Slow (Seconds/Minutes)        |
| Primary Use Case      | All-in-one linter & formatter     | Deep semantic analysis        |
| Rule Implementation   | Re-implements Flake8, isort, etc. | Original custom rules         |
| Formatting            | Built-in (Black-compatible)       | None (linting only)           |
| Import Sorting        | Built-in (isort-compatible)       | None (linting only)           |
| Auto-fix Capabilities | Extensive (one-click fixes)       | Very limited                  |
| Type Inference        | Basic                             | Advanced                      |
| Configuration         | pyproject.toml (primary)          | .pylintrc or pyproject.toml   |
| Core Philosophy       | Speed and consolidation           | Depth and logical correctness |

---

#### 1. Performance and Speed

> Ruff is written in Rust, which allows it to process files nearly instantaneously. On massive codebases, Ruff can be 100x faster than Pylint. Pylint's slowness comes from its deep traversal of the Python Abstract Syntax Tree (AST) and its interpreted nature.

#### 2. Consolidation

> Ruff is designed to replace over 30 different Python tools (Flake8, isort, Black, pydocstyle, etc.). Pylint focuses strictly on linting and does not attempt to format code or sort imports.

#### 3. Deep Analysis

> Pylint is still superior for catching 'code smells' that require understanding the relationship between different modules or classes. It can detect issues like 'method hidden by instance attribute' or 'too many arguments' more reliably than Ruff's static pattern matching.

## Markdown Linting

- markdownlint rules have been defined in `.markdownlint.yaml` and are enforced via `pymarkdownlint` pre-commit hooks

## SQL Linting

To see if your SQL is compliant to the defined `bigquery` standard, you can run the following commands

```bash
# lint a specific file
sqlfluff lint path/to/file.sql

# lint a file directory
sqlfluff lint directory/of/sql/files

# let the linter fix your code
sqlfluff fix folder/file.sql
```

## [pre-commit hooks](https://github.com/pre-commit/pre-commit-hooks)

Pre-commit have been set up in this repo to check and fix for:

- missing lines at the end
- trailing whitespaces
- violations of sql standards
- errors in yaml syntax

Hence, when working with the repo, make sure you've got the pre-commit installed so that they run upon your every commit

```bash
# install the githook scripts
pre-commit install

# run against all existing files
pre-commit run --all-files
```
