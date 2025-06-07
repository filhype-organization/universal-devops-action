# Universal DevOps Action

A reusable GitHub Actions workflow that provides a complete CI pipeline with support for Java (Spring/Quarkus) and Angular projects. This workflow automatically detects your project type and executes the appropriate build, test, and quality check steps.

## Features

- 🔍 Automatic project type detection
  - Java (Maven/Gradle)
  - Angular
  - Framework detection (Spring Boot/Quarkus)
- 🏗️ Build Support
  - Java builds (legacy and native compilation for Quarkus)
  - Angular builds with production optimization
  - Multi-architecture support (x86/arm64)
- 🐳 Container Support
  - Docker image building and pushing
  - Multi-arch container builds
  - Automatic container registry authentication
- 🧪 Testing
  - Java unit tests
  - Angular unit tests
  - Configurable test options
- 📊 Quality Checks
  - Code linting (non-blocking)
  - SQL linting with SQLFluff
  - Security scanning with TruffleHog
  - Multiple linter support through Super-linter

## Usage

To use this workflow in your project, create a new workflow file (e.g., `.github/workflows/ci.yml`) with the following content:

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    uses: your-org/universal-devops-action/.github/workflows/github-actions.yml@main
    with:
      # Optional parameters - defaults shown
      java_version: '21'              # Java version
      node_version: '22'              # Node.js version      build_type: 'legacy'           # 'legacy' or 'native' (for Quarkus)
      build_platform: 'x86'          # 'x86' or 'arm64'
      container_build: false         # Enable container builds
      docker_image_name: 'org/repo'  # Required if container_build is true
      build_options: ''             # Additional build options
      test_options: ''              # Additional test options
      sql_lint_path: 'models'       # Path to SQL files
      sql_lint_config: '.sqlfluff'  # SQLFluff config file
      trufflehog_args: '--results=verified,unknown'  # TruffleHog options
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}  # Optional
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}      # Optional
```

## Workflow Details

### Project Detection

The workflow automatically detects your project type based on the presence of specific files:
- `pom.xml` → Java with Maven
- `build.gradle` → Java with Gradle
- `angular.json` → Angular

For Java projects, it also detects the framework:
- Spring Boot: Checks for `org.springframework.boot` dependency
- Quarkus: Checks for `io.quarkus` dependency

### Jobs Description

1. **get-context**
   - Detects project type and framework
   - Sets up environment for subsequent jobs

2. **lint** (non-blocking)
   - Runs various code quality checks
   - SQL linting if SQL files are present
   - Continues pipeline even if checks fail

3. **security**
   - Runs security scans using TruffleHog
   - Checks for sensitive information in code

4. **java-build** (conditional)
   - Runs if Java project is detected
   - Supports both legacy and native builds
   - Native builds only available for Quarkus projects
   - Optional container image building

5. **angular-build** (conditional)
   - Runs if Angular project is detected
   - Builds production-optimized assets
   - Optional container image building

6. **test**
   - Runs appropriate tests based on project type
   - Configurable test options

## Requirements

### Repository Structure
- Only one project type per repository is supported
  - Either a Java project (Spring Boot or Quarkus)
  - Or an Angular project
- Mixed project types in the same repository are not supported (e.g., cannot have both Angular and Spring Boot)

### Authentication
- GitHub token with required permissions (read/write for repositories)

### Native Compilation
- Native compilation is only available for Quarkus projects
- Supported architectures for native builds:
  - x86 (amd64)
  - arm64 (aarch64)

Note: All build tools and dependencies are automatically handled by the GitHub Actions runner, no local installation is required.

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
| build_type | Build type for Java projects | No | legacy |
| build_platform | Target platform for containers | No | x86 |
| container_build | Enable container builds | No | false |
| docker_image_name | Name of your Docker image | Conditional* | N/A |
| build_options | Additional build options | No | '' |
| test_options | Additional test options | No | '' |
| sql_lint_path | Path to SQL files | No | models |
| sql_lint_config | SQLFluff config file | No | .sqlfluff |
| trufflehog_args | TruffleHog arguments | No | --results=verified,unknown |
| tag | Override version tag for Docker images | No | N/A |

\* Required if container_build is true

## Secrets

| Name | Description | Required |
|------|-------------|----------|
| GH_TOKEN | GitHub token for authentication | Yes |
| DOCKER_USERNAME | Docker Hub username | No |
| DOCKER_TOKEN | Docker Hub token | No |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.