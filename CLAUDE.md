# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A reusable GitHub Actions workflow (`workflow_call`) that provides a complete CI/CD pipeline. Consumer repos reference it as:
```yaml
uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v1
```

There is no application code, build system, or test suite in this repo. All code is GitHub Actions YAML (composite actions + one reusable workflow).

## Validation

There is no local build/test/lint command. To validate changes:
- **YAML syntax**: use `actionlint` if installed (`actionlint .github/workflows/github-actions.yml`)
- **Manual testing**: push to a branch and trigger the workflow from a consumer repo pointing at the branch ref
- **Review workflow runs**: check GitHub Actions logs on consumer repos

## Architecture

### Entry Point
`.github/workflows/github-actions.yml` - the single reusable workflow. All jobs are defined here. It dispatches to composite actions.

### Composite Actions (`.github/actions/`)
Each action is self-contained with its own `action.yml`:

| Action | Path | Purpose |
|--------|------|---------|
| get-context | `get-context/` | Detects project type (Java/Angular/MkDocs/Timoni) and framework (Spring/Quarkus) by checking for `pom.xml`, `build.gradle`, `angular.json`, `mkdocs.yml`, `timoni.cue` |
| java-test | `test/java-test/` | Runs `mvn test` or `./gradlew test` |
| angular-test | `test/angular-test/` | Runs `npm test` with CI-patched Karma config (ChromeHeadless, singleRun) |
| java-build | `build/java-build/` | Maven/Gradle build, supports legacy and Quarkus native compilation, Docker push |
| angular-build | `build/angular-build/` | `npm run build`, optional Docker push |
| timoni-build | `build/timoni-build/` | Installs Timoni CLI (via `stefanprodan/timoni/actions/setup`), pushes module as OCI artifact to Docker Hub |
| mkdocs-build | `mkdocs-build/` | Builds and deploys MkDocs to GitHub Pages |
| lint | `lint/` | MegaLinter (code quality) + SQLFluff (SQL linting) |
| trivy | `security/trivy/` | Vulnerability scanning with SARIF upload |
| trufflehog | `security/trufflehog/` | Secret detection |
| renovate | `analysis/renovate/` | Creates Renovate config files for dependency management |

### Job Dependency Graph
```
get-context
  ├── test (Java) ──────────┐
  ├── test-node (Angular) ──┤
  ├── timoni-build          │
  ├── mkdocs-build          │
  └── analysis              │
                            ├── java-build ────┐
                            ├── angular-build ──┤
                            │                   ├── create-manifest
                            │                   │       │
                            │                   ├───────┤
                            └───────────────────┤       │
                                                ├── lint (non-blocking)
                                                └── security (non-blocking)
```

### Multi-Arch Build Pattern
Build jobs use a matrix strategy over `build_platforms` (e.g., `["amd64", "arm64"]`). Each platform pushes `image:version-platform`. A separate `create-manifest` job then combines them into a multi-arch manifest `image:version`.

### Configuration Files (`conf/`)
- `.trivy.yaml` - Trivy scanner configuration (severities, skip patterns)
- `.mega-linter.yml` - empty (MegaLinter is configured inline in the lint action)
- `debug-manifests.sh` / `test-multi-arch.sh` - helper scripts for debugging multi-arch Docker manifests

## Key Patterns When Editing

- All composite actions use `shell: bash` and `runs.using: composite`
- Version tagging logic (tag > git tag > commit SHA, with `-snapshot` suffix for non-main branches) is duplicated in `java-build`, `angular-build`, `timoni-build`, and the `create-manifest` step in the main workflow. Git tags with or without `v` prefix are both supported (`${GITHUB_REF#refs/tags/}` then `${VERSION#v}`)
- Timoni requires valid semver — non-semver versions (SHA, SHA-snapshot) are prefixed with `0.0.0-` in `timoni-build`
- The `if: always()` pattern is used on lint/security jobs so they run regardless of build outcome
- `continue-on-error: true` makes lint non-blocking
- `provenance: false` is required on `docker/build-push-action` to get single-platform images (not manifest lists)
- The get-context action writes to `$GITHUB_OUTPUT` using both individual keys and a JSON `outputs` key
