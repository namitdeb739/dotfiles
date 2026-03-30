---
name: ML/Data Science Standards
description: Reproducibility, experiment tracking, data handling, notebook best practices
applyTo: '**/*.ipynb,**/notebooks/**,**/ml/**,**/models/**'
---

# ML & Data Science Conventions

## Reproducibility
- Set random seeds explicitly (numpy, torch, random, tensorflow)
- Pin dependency versions in requirements.txt or pyproject.toml
- Log all hyperparameters, data versions, and model configurations
- Use deterministic operations where possible; document non-deterministic steps

## Data Handling
- Never modify raw data — write transformations to a separate processed directory
- Split data before any preprocessing that uses statistics (mean, std) to prevent leakage
- Validate data schema at pipeline boundaries (input loading, output saving)
- Document data assumptions: expected ranges, distributions, missing value handling

## Experiment Tracking
- Log metrics, parameters, and artifacts using a tracking tool (MLflow, W&B, etc.)
- Use descriptive experiment names and tags
- Save model checkpoints with metadata (epoch, metrics, config)

## Notebooks
- Keep notebooks focused: one analysis or experiment per notebook
- Clear all outputs before committing to version control
- Extract reusable logic into .py modules — notebooks are for exploration and presentation
- Use markdown cells to explain the reasoning, not just the code
- Number notebooks for sequential workflows (01_data_prep, 02_training, etc.)

## Model Code
- Separate data loading, model definition, training loop, and evaluation
- Use configuration files or dataclasses for hyperparameters, not hardcoded values
- Include inference/prediction utilities alongside training code
- Document model input/output shapes and data types
