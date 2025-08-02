# Exemples d'utilisation des builds multi-architecture

## Builds Java Natifs Multi-Architecture avec Container

```yaml
name: Multi-Arch Native Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v1
    with:
      java_version: '21'
      build_type: 'native'
      build_platforms: '["amd64", "arm64"]'
      container_build: true
      docker_image_name: 'myorg/myapp'
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
```

**Résultat:**
- Deux builds natifs en parallèle : `java-build (amd64)` et `java-build (arm64)`
- Chaque build produit un binaire natif optimisé pour son architecture
- Les images Docker sont taguées avec l'architecture : `myapp:v1.0.0-amd64` et `myapp:v1.0.0-arm64`
- Un manifest multi-arch est créé : `myapp:v1.0.0` pointant vers les deux digests

## Build Angular Multi-Architecture

```yaml
name: Angular Multi-Arch

on:
  push:

jobs:
  build:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v1
    with:
      node_version: '20'
      build_platforms: '["amd64", "arm64"]'
      container_build: true
      docker_image_name: 'myorg/frontend'
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
```

## Build Single Architecture (Compatibilité)

```yaml
# Ancien paramètre build_platform toujours supporté
name: Legacy Single Build

jobs:
  build:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v1
    with:
      build_platform: 'arm64'  # Ancien paramètre
      container_build: true
      docker_image_name: 'myorg/app'
```

## Fonctionnement Technique

### Workflow de Build Multi-Architecture

1. **Matrice de Build** : Le workflow crée des jobs parallèles basés sur `build_platforms`
   ```yaml
   strategy:
     matrix:
       platform: ${{ fromJSON(inputs.build_platforms) }}
   ```

2. **Build par Plateforme** : Chaque job build pour une architecture spécifique
   - `java-build (amd64)` : Compilation native x86_64
   - `java-build (arm64)` : Compilation native ARM64

3. **Images Docker par Plateforme** : Chaque build pousse une image taguée
   - `myapp:v1.0.0-amd64`
   - `myapp:v1.0.0-arm64`

4. **Création du Manifest** : Le job `amd64` (dernier) crée le manifest multi-arch
   ```bash
   docker manifest create myapp:v1.0.0 \
     myapp:v1.0.0-amd64 \
     myapp:v1.0.0-arm64
   ```

### Utilisation du Manifest

Quand vous tirez l'image, Docker sélectionne automatiquement la bonne architecture :

```bash
# Sur une machine x86_64
docker pull myorg/myapp:v1.0.0  # → tire automatiquement l'image amd64

# Sur une machine ARM64 (Apple Silicon, ARM servers)
docker pull myorg/myapp:v1.0.0  # → tire automatiquement l'image arm64
```

## Migration depuis build_platform

```yaml
# Avant (un seul build)
build_platform: 'amd64'

# Après (multi-arch)
build_platforms: '["amd64", "arm64"]'

# Ou maintenir un seul build
build_platforms: '["amd64"]'
```

Le paramètre `build_platform` reste supporté pour la compatibilité ascendante.
