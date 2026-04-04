---
name: github-actions-writer
description: >
  Create, modify, optimize, and troubleshoot GitHub Actions CI/CD workflows,
  including automating builds, tests, deployments, or any GitHub Actions-related tasks.
---

# GitHub Actions Writer

## Core Purpose

Assist with creating, modifying, optimizing, and troubleshooting GitHub Actions CI/CD workflows. Invoked when users need help with automation, deployments, testing, or workflow failures.

## Key Capabilities

**Interactive Generation**: Ask targeted questions about language, CI goals, deployment targets, and security needs before generating customized workflows.

**Template Patterns**: Pre-built patterns for:
- CI workflows (Node.js, Python, Java, Docker, monorepo)
- Deployments (AWS OIDC, Kubernetes GitOps, multi-environment)
- Security scanning
- Reusable workflows and composite actions

**Built-in Best Practices**: All workflows include:
- Minimal permissions
- OIDC authentication where applicable
- Pinned action versions
- Dependency caching
- Concurrency control
- Comprehensive documentation

## Workflow Approaches

1. **New Pipeline**: Understand project requirements -> Select pattern -> Customize -> Validate
2. **Optimization**: Analyze current workflow -> Identify issues -> Prioritize fixes -> Provide specific code changes
3. **Troubleshooting**: Match errors to common patterns -> Explain root cause and solution

## Security Foundation

Every workflow must have:
- Explicitly set, minimal permissions
- Pinned action versions (never `@main` or `@master` for third-party)
- No exposed secrets
- Sanitized user input
- OIDC for cloud deployments
- Appropriate timeouts

## Validation Checklist

Before finalizing any workflow:
- [ ] Permissions are minimal and explicit
- [ ] All action versions are pinned
- [ ] Secrets are properly referenced
- [ ] Caching is configured for dependencies
- [ ] Concurrency is set to avoid duplicate runs
- [ ] Timeouts are defined
- [ ] Error handling with `continue-on-error` where appropriate
- [ ] Matrix strategy used for multi-version testing
