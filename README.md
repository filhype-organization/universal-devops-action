# Universal DevOps Action

<img src="asset/universal-github-action.png" alt="Universal GitHub Action" width="300" style="display: block; margin: auto;"/>

<p></p>
A reusable GitHub Actions workflow that provides a complete CI/CD pipeline with support for Java (Spring/Quarkus) and Angular projects. This workflow automatically detects your project type and executes the appropriate build, test, and quality check steps.
</p>

## Features

- 🔍 **Automatic project type detection**
  - Java (Maven/Gradle)
  - Angular
  - Framework detection (Spring Boot/Quarkus)
- 🏗️ **Build Support**
  - Java builds (legacy and native compilation for Quarkus)
  - Angular builds with production optimization
  - Multi-architecture support (x86/arm64)
  - Optional build disabling for specific project types
- 🐳 **Container Support**
  - Docker image building and pushing
  - Multi-arch container builds
  - Automatic container registry authentication
- 🧪 **Testing**
  - Java unit tests
  - Angular unit tests
  - Configurable test options
- 📊 **Quality Checks**
  - Code linting with MegaLinter (non-blocking)
  - SQL linting with SQLFluff
  - Security scanning with TruffleHog and Trivy
  - Vulnerability scanning with SARIF upload
- 🔒 **Security & Analysis**
  - Modular security actions (TruffleHog, Trivy)
  - Dependency management with Renovate
  - Secrets detection and vulnerability scanning
  - SARIF report upload to GitHub Security tab

## Usage

To use this workflow in your project, create a new workflow file (e.g., `.github/workflows/ci.yml`) with the following content:

```yaml
name: CI

on:
  push:
  pull_request:

jobs:
  build:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v1
    with:
      # Optional parameters - defaults shown
      java_version: '21'              # Java version
      node_version: '22'              # Node.js version      
      build_type: 'legacy'           # 'legacy' or 'native' (for Quarkus)
      build_platform: 'x86'          # 'x86' or 'arm64'
      container_build: false         # Enable container builds
      docker_image_name: 'org/repo'  # Required if container_build is true
      build_options: ''               # Additional build options
      test_options: ''                # Additional test options
      sql_lint_path: 'models'         # Path to SQL files
      sql_lint_config: '.sqlfluff'    # SQLFluff config file
      trufflehog_args: '--results=verified,unknown'  # TruffleHog options
      # Build control parameters
      enable_java_build: true         # Enable/disable Java builds
      enable_angular_build: true      # Enable/disable Angular builds
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}  # Optional
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}         # Optional
```

## Common Use Cases

### Standard CI/CD Pipeline
```yaml
jobs:
  build:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v1
    with:
      java_version: '21'
      container_build: true
      docker_image_name: 'myorg/myapp'
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
```

### Security and Quality Checks Only (No Builds)
```yaml
jobs:
  quality-checks:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v1
    with:
      enable_java_build: false
      enable_angular_build: false
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Angular Project with Custom Node Version
```yaml
jobs:
  build:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v1
    with:
      node_version: '20'
      enable_java_build: false  # Skip Java builds for Angular-only projects
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Workflow Details

### Project Detection

The workflow automatically detects your project type based on the presence of specific files:
- `pom.xml` → Java with Maven
- `build.gradle` or `build.gradle.kts` → Java with Gradle
- `angular.json` → Angular

For Java projects, it also detects the framework:
- Spring Boot: Checks for `org.springframework.boot` dependency
- Quarkus: Checks for `io.quarkus` dependency

### Jobs Description

1. **get-context**
   - Detects project type and framework
   - Sets up environment variables for subsequent jobs
   - Outputs individual flags for each detected technology

2. **lint** (Always runs, non-blocking)
   - Runs various code quality checks using MegaLinter
   - SQL linting if SQL files are present
   - Continues pipeline even if checks fail
   - Runs independently of build status

3. **security** (Always runs, non-blocking)
   - **TruffleHog**: Scans for secrets and sensitive information
   - **Trivy**: Vulnerability scanning with SARIF report upload
   - Runs independently of build status
   - SARIF reports uploaded to GitHub Security tab when possible

4. **java-build** (Conditional)
   - Runs if Java project is detected AND `enable_java_build` is true
   - Supports both legacy and native builds
   - Native builds only available for Quarkus projects
   - Optional container image building and pushing

5. **angular-build** (Conditional)
   - Runs if Angular project is detected AND `enable_angular_build` is true
   - Builds production-optimized assets
   - Optional container image building and pushing

6. **test** (Conditional)
   - Runs appropriate tests based on project type
   - Only runs if corresponding build job ran successfully
   - Configurable test options

### Security Actions (Modular)

The security workflow uses separate composite actions for better modularity:

- **TruffleHog Action** (`.github/actions/security/trufflehog/`)
  - Standalone secrets detection
  - Configurable scan parameters
  - GitHub integration for issue reporting

- **Trivy Action** (`.github/actions/security/trivy/`)
  - Vulnerability scanning for code and dependencies
  - SARIF report generation and upload
  - Fallback to artifacts if SARIF upload fails

- **Renovate Action** (`.github/actions/analysis/renovate/`)
  - Dependency management and updates
  - Automated pull request creation
  - Support for multiple package managers

## Requirements

### Repository Structure
- **Single Project Type**: Only one primary project type per repository is supported
  - Either a Java project (Spring Boot or Quarkus)
  - Or an Angular project
- **Mixed Projects**: While the workflow can detect multiple project types, build jobs are mutually exclusive
- **Monorepo Support**: Use build control parameters (`enable_java_build`, `enable_angular_build`) for selective builds

### GitHub Permissions
- **Repository access**: Read/write permissions for code scanning and SARIF uploads
- **Security tab access**: For vulnerability report uploads
- **Actions permissions**: To run workflows and upload artifacts

### Build Requirements

#### Java Projects
- **JDK**: Automatically installed (default: Java 21)
- **Build Tools**: Maven or Gradle (auto-detected)
- **Native Compilation**: Only available for Quarkus projects
- **Architectures**: x86 (amd64) and arm64 (aarch64) for native builds

#### Angular Projects
- **Node.js**: Automatically installed (default: Node 22)
- **Package Manager**: npm (automatically used)
- **Build Output**: Production-optimized builds

#### Container Builds
- **Docker**: Available on GitHub-hosted runners
- **Registry Authentication**: Optional (Docker Hub, GitHub Container Registry)
- **Multi-arch**: Supported for both Java and Angular projects

### Security Scanning
- **TruffleHog**: No additional setup required
- **Trivy**: Vulnerability database automatically updated
- **SARIF Upload**: Requires appropriate GitHub permissions

Note: All build tools and dependencies are automatically installed by the GitHub Actions runner. No local setup is required.

## Container Version Tagging

For container builds, the image version tag is determined in the following order of priority:
1. If `tag` input is provided, use it directly
2. If running on a Git tag (e.g., v1.2.3), use the tag version
3. Otherwise, use the short Git commit SHA

Additionally, if not building from the main branch and no custom tag is provided, "-snapshot" is appended to the version.

Examples:
- Custom tag input "1.0.0" → `image:1.0.0`
- Git tag "v1.2.3" → `image:1.2.3`
- Commit abc123f on main → `image:abc123f`
- Commit def456a on feature branch → `image:def456a-snapshot`

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| java_version | Java version | No | 21 |
| node_version | Node.js version | No | 22 |
| build_type | Build type for Java projects ('legacy' or 'native') | No | legacy |
| build_platform | Target platform for containers ('x86' or 'arm64') | No | x86 |
| container_build | Enable container builds | No | false |
| docker_image_name | Name of your Docker image | Conditional* | N/A |
| build_options | Additional build options | No | '' |
| test_options | Additional test options | No | '' |
| sql_lint_path | Path to SQL files for linting | No | models |
| sql_lint_config | SQLFluff config file path | No | .sqlfluff |
| trufflehog_args | TruffleHog scan arguments | No | --results=verified,unknown |
| tag | Override version tag for Docker images | No | N/A |
| **enable_java_build** | **Enable/disable Java build jobs** | **No** | **true** |
| **enable_angular_build** | **Enable/disable Angular build jobs** | **No** | **true** |

\* Required if container_build is true

**Note:** The `enable_java_build` and `enable_angular_build` parameters allow you to disable specific build jobs while still running lint and security checks. This is useful for:
- Security-only pipelines
- Quality checks without builds
- Selective builds in monorepo scenarios

## Secrets

| Name | Description | Required |
|------|-------------|----------|
| GH_TOKEN | GitHub token for authentication | Yes |
| DOCKER_USERNAME | Docker Hub username | No |
| DOCKER_TOKEN | Docker Hub token | No |

## Outputs and Behaviors

### Project Detection Outputs

The `get-context` job provides detailed information about the detected project:

| Output | Description | Example Values |
|--------|-------------|----------------|
| has_java | Java project detected | `true`, `false` |
| has_maven | Maven build system detected | `true`, `false` |
| has_gradle | Gradle build system detected | `true`, `false` |
| has_angular | Angular project detected | `true`, `false` |
| has_spring | Spring Boot framework detected | `true`, `false` |
| has_quarkus | Quarkus framework detected | `true`, `false` |

### Job Execution Logic

| Scenario | lint | security | java-build | angular-build | test |
|----------|------|----------|------------|---------------|------|
| Java project + `enable_java_build: true` | ✅ Always | ✅ Always | ✅ Runs | ❌ Skipped | ✅ If build succeeds |
| Java project + `enable_java_build: false` | ✅ Always | ✅ Always | ❌ Disabled | ❌ Skipped | ❌ Skipped |
| Angular project + `enable_angular_build: true` | ✅ Always | ✅ Always | ❌ Skipped | ✅ Runs | ✅ If build succeeds |
| Angular project + `enable_angular_build: false` | ✅ Always | ✅ Always | ❌ Skipped | ❌ Disabled | ❌ Skipped |
| No builds enabled | ✅ Always | ✅ Always | ❌ Disabled | ❌ Disabled | ❌ Skipped |

### Security Report Outputs

- **TruffleHog**: Secrets detection results are logged and can trigger GitHub issues
- **Trivy**: Vulnerability reports are uploaded as SARIF to GitHub Security tab
  - If SARIF upload fails (permissions), reports are saved as workflow artifacts
  - View results in GitHub Security → Code scanning alerts

## Advanced Configuration

### Custom Trivy Configuration

Create a `.trivy.yaml` file in your repository root:

```yaml
# Severity levels to report
severity:
  - CRITICAL
  - HIGH
  - MEDIUM

# Vulnerability databases to use
vulnerability:
  type:
    - os
    - library

# File patterns to ignore
ignorefile: .trivyignore
```

### Custom MegaLinter Configuration

Create a `.mega-linter.yml` file in your repository root:

```yaml
# Enable/disable specific linters
ENABLE_LINTERS:
  - YAML_YAMLLINT
  - JSON_JSONLINT
  - JAVASCRIPT_ES
  - TYPESCRIPT_ES
  - PYTHON_FLAKE8

# Disable problematic linters
DISABLE_LINTERS:
  - COPYPASTE_JSCPD
  - SPELL_CSPELL

# File patterns to exclude
FILTER_REGEX_EXCLUDE: '(node_modules/|\.git/|dist/)'

# Output configuration
SHOW_ELAPSED_TIME: true
FILEIO_REPORTER: false
```

### Build Control Strategies

**Strategy 1: Security-First Pipeline**
```yaml
# Only run security and quality checks
with:
  enable_java_build: false
  enable_angular_build: false
```

**Strategy 2: Conditional Builds**
```yaml
# Enable builds only on main branch
with:
  enable_java_build: ${{ github.ref == 'refs/heads/main' }}
  enable_angular_build: ${{ github.ref == 'refs/heads/main' }}
```

**Strategy 3: Technology-Specific Pipelines**
```yaml
# Java-only pipeline
with:
  enable_angular_build: false
  java_version: '17'
  build_type: 'native'
```

## Troubleshooting

### Common Issues and Solutions

#### Build Issues
- **Java build fails**: Check Java version compatibility and build tool configuration
- **Angular build fails**: Verify Node.js version and package.json dependencies
- **Native build unavailable**: Ensure you're using a Quarkus project (not Spring Boot)

#### Security Scanning Issues
- **SARIF upload fails**: 
  - Check repository permissions for security tab access
  - Reports will fallback to workflow artifacts automatically
- **TruffleHog false positives**: Use `.trufflehogignore` file or adjust `trufflehog_args`
- **Trivy scan errors**: Check `.trivy.yaml` configuration or network connectivity

#### Container Build Issues
- **Docker authentication fails**: Verify `DOCKER_USERNAME` and `DOCKER_TOKEN` secrets
- **Multi-arch build slow**: Consider using `build_platform: 'x86'` for faster builds
- **Image name invalid**: Use format `registry/organization/repository`

#### Lint and Quality Issues
- **MegaLinter fails**: Check file encoding and syntax
- **MegaLinter configuration**: Create `.mega-linter.yml` for custom settings
- **SQL lint errors**: Verify `.sqlfluff` configuration and SQL file paths
- **Too many lint errors**: Linting is non-blocking and won't fail the pipeline
- **Language-specific issues**: MegaLinter supports 70+ languages with auto-detection

### Debug Information

Enable debug logging by setting repository variables:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

### Getting Help

1. **Check workflow logs**: Detailed error messages are provided in job outputs
2. **Review debug messages**: The `get-context` job provides detailed detection information
3. **Validate configuration**: Ensure all required inputs and secrets are properly set
4. **Test locally**: Most tools can be run locally for debugging

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Guidelines
- Follow existing code style and structure
- Test changes with different project types
- Update documentation for new features
- Ensure backward compatibility

### Reporting Issues
- Include workflow logs and configuration
- Specify project type and framework versions
- Provide minimal reproduction steps

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Changelog

### Latest Updates
- ✅ **Replaced Super-linter with MegaLinter** for better stability and performance
- ✅ **Resolved branch detection issues** with modern linter that works on all branches
- ✅ Added build control parameters (`enable_java_build`, `enable_angular_build`)
- ✅ Separated security actions into modular components (TruffleHog, Trivy, Renovate)
- ✅ Improved project detection with individual output flags
- ✅ Enhanced SARIF upload with fallback to artifacts
- ✅ Added comprehensive debug logging
- ✅ Ensured lint and security jobs run independently of build status