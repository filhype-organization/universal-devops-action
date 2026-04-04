---
name: cicd-pipeline-setup
description: >
  Design and implement CI/CD pipelines with GitHub Actions, GitLab CI, Jenkins,
  or CircleCI. Use for automated testing, building, and deployment workflows.
---

# CI/CD Pipeline Setup

## Overview

Build automated continuous integration and deployment pipelines that test code, build artifacts, run security checks, and deploy to multiple environments with minimal manual intervention.

## When to Use

- Automated code testing and quality checks
- Containerized application builds
- Multi-environment deployments
- Release management and versioning
- Automated security scanning
- Performance testing integration
- Artifact management and registry

## Quick Start

```yaml
# .github/workflows/deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [20.x, 22.x]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Best Practices

### DO

- Fail fast with early validation
- Run tests in parallel when possible
- Use caching for dependencies
- Implement proper secret management
- Gate production deployments with approval
- Monitor and alert on pipeline failures
- Use consistent environment configuration
- Implement infrastructure as code

### DON'T

- Store credentials in pipeline configuration
- Deploy without automated tests
- Skip security scanning
- Allow long-running pipelines without timeouts
- Mix staging and production pipelines
- Ignore test failures
- Deploy directly to main branch without checks
- Skip health checks after deployment
