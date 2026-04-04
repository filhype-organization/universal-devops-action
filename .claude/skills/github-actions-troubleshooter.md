---
name: github-actions-troubleshooter
description: >
  Diagnose and fix GitHub Actions workflow failures, CI/CD pipeline issues,
  YAML syntax errors, and workflow configuration problems.
---

# GitHub Actions Troubleshooter

Diagnoses and fixes GitHub Actions workflow failures and configuration issues.

## Instructions

When activated, follow this systematic troubleshooting approach:

### 1. Identify the Failure

**Get workflow status:**
```bash
gh run list --limit 5                    # Recent runs
gh run view <run-id>                     # Specific run details
gh run view <run-id> --log-failed        # Failed job logs only
```

**Analyze the failure:**
- Parse error messages from logs
- Identify which job/step failed
- Note the exit code and error type
- Check if it's intermittent or consistent

### 2. Common Failure Categories

#### YAML Syntax Errors
- Invalid indentation (must use spaces, not tabs)
- Missing required fields (`name`, `on`, `jobs`)
- Invalid step format
- Quote escaping issues

**Fix approach:**
- Read the workflow file
- Validate YAML structure
- Check GitHub Actions syntax documentation
- Fix syntax issues

#### Dependency/Setup Issues
- Node/Python/etc version mismatches
- Missing dependencies in package.json/requirements.txt
- Cache invalidation needed
- Setup action version incompatibility

**Fix approach:**
```yaml
# Pin versions explicitly
- uses: actions/setup-node@v4
  with:
    node-version: '22'
    cache: 'npm'
```

#### Test/Build Failures
- Tests failing in CI but passing locally
- Environment variable differences
- File path issues (case sensitivity on Linux)
- Missing environment secrets

**Fix approach:**
- Compare local vs CI environment
- Check for hardcoded paths
- Verify secrets are configured
- Add debugging output

#### Permission Errors
- `GITHUB_TOKEN` insufficient permissions
- File permission issues
- Branch protection violations

**Fix approach:**
```yaml
permissions:
  contents: write
  pull-requests: write
  checks: read
```

#### Timeout/Performance Issues
- Jobs exceeding 6-hour limit
- Slow dependency installation
- Missing caching
- Inefficient matrix strategies

**Fix approach:**
- Add caching for dependencies
- Parallelize independent jobs
- Optimize test suites
- Use workflow artifacts efficiently

### 3. Diagnostic Workflow

1. Read the workflow file
2. Get recent run logs with `gh run view --log-failed`
3. Identify root cause by parsing error messages, checking known patterns, reviewing recent changes
4. Apply fix, test locally if possible, monitor next run

### 4. Common Fixes

#### Missing Environment Variables
```yaml
env:
  NODE_ENV: production
  API_URL: ${{ secrets.API_URL }}
```

#### Caching Dependencies
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '22'
    cache: 'npm'

# Or manual cache
- uses: actions/cache@v4
  with:
    path: ~/.cache
    key: ${{ runner.os }}-cache-${{ hashFiles('**/package-lock.json') }}
```

#### Matrix Strategy for Multiple Versions
```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
    os: [ubuntu-latest, windows-latest]
```

### 5. Prevention & Best Practices

- Pin action versions (`actions/checkout@v4` not `@main`)
- Use caching for dependencies
- Set explicit timeouts
- Add descriptive step names
- Use `if: failure()` for debugging steps
- Minimize `GITHUB_TOKEN` permissions
- Don't log secrets
- Review third-party actions before use

## Tools to Use

- **Read**: View workflow YAML files
- **Edit**: Fix workflow configuration
- **Bash(gh)**: Get run logs, workflow status
- **Bash(git)**: Check recent changes, blame
- **Grep**: Search for patterns in logs/workflows
