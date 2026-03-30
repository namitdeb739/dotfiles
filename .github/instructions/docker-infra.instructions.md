---
name: Docker & Infrastructure Standards
description: Container best practices, IaC conventions for Dockerfiles, compose, Terraform
applyTo: '**/Dockerfile,**/Dockerfile.*,**/docker-compose*,**/*.tf,**/k8s/**'
---

# Docker & Infrastructure Conventions

## Dockerfiles
- Use specific base image tags, never `latest` (e.g., `python:3.12-slim`, not `python:latest`)
- Order layers from least to most frequently changed for cache efficiency
- Combine RUN commands with `&&` to minimize layers
- Use multi-stage builds to keep final images small
- Copy dependency files (requirements.txt, package.json) before source code
- Run as non-root user in production images
- Use .dockerignore to exclude build artifacts, .git, node_modules, __pycache__

## Docker Compose
- Pin service image versions
- Use named volumes for persistent data, bind mounts only for development
- Define healthchecks for services that accept connections
- Use environment variable files (.env) for configuration, not hardcoded values
- Define explicit networks for service isolation

## Terraform / IaC
- Use variables for anything that might change between environments
- Use meaningful resource names that include the purpose and environment
- Lock provider versions in required_providers
- Use modules for reusable infrastructure patterns
- Store state remotely with locking (S3+DynamoDB, GCS, etc.)
- Tag all resources with environment, team, and purpose

## General
- Never commit secrets or credentials in infrastructure files
- Use parameterized configurations over environment-specific copies
- Document non-obvious infrastructure decisions in comments or companion docs
