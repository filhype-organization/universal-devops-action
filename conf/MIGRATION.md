# Guide de Migration : build_platform → build_platforms

## Vue d'ensemble

La nouvelle version supporte les builds multi-architecture via le paramètre `build_platforms` qui accepte un tableau JSON de plateformes au lieu d'une seule plateforme.

## Changements

### Avant (v1.x)
```yaml
with:
  build_platform: 'amd64'          # Une seule plateforme
  container_build: true
```

### Après (v2.x)
```yaml
with:
  build_platforms: '["amd64"]'     # Tableau avec une plateforme
  container_build: true
```

### Multi-Architecture (Nouveau)
```yaml
with:
  build_platforms: '["amd64", "arm64"]'  # Builds parallèles
  container_build: true
```

## Étapes de Migration

### 1. Migration Simple (Une Plateforme)
```diff
  with:
-   build_platform: 'amd64'
+   build_platforms: '["amd64"]'
```

### 2. Migration vers Multi-Architecture
```diff
  with:
-   build_platform: 'amd64'
+   build_platforms: '["amd64", "arm64"]'
```

### 3. Impacts sur les Images Docker

#### Avant
```
myorg/myapp:v1.0.0  # Une seule architecture
```

#### Après (Single)
```
myorg/myapp:v1.0.0-amd64  # Image platform-specific
myorg/myapp:v1.0.0        # Manifest pointant vers amd64
```

#### Après (Multi-Arch)
```
myorg/myapp:v1.0.0-amd64  # Image x86_64
myorg/myapp:v1.0.0-arm64  # Image ARM64
myorg/myapp:v1.0.0        # Manifest multi-arch
```

## Compatibilité

> **Note :** L'ancien paramètre `build_platform` (singulier) n'est plus supporté. Il faut utiliser `build_platforms` (pluriel) avec un tableau JSON.

Si `build_platforms` n'est pas fourni, la valeur par défaut `["amd64"]` est utilisée.

## Exemples de Migration

### Projet Java Spring Boot
```yaml
# Avant
jobs:
  build:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v1
    with:
      build_type: 'legacy'
      build_platform: 'amd64'
      container_build: true

# Après (même comportement)
jobs:
  build:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v2
    with:
      build_type: 'legacy'
      build_platforms: '["amd64"]'
      container_build: true

# Nouveau (multi-arch)
jobs:
  build:
    uses: filhype-organization/universal-devops-action/.github/workflows/github-actions.yml@v2
    with:
      build_type: 'legacy'
      build_platforms: '["amd64", "arm64"]'
      container_build: true
```

### Projet Quarkus Native
```yaml
# Avant (un seul build natif)
with:
  build_type: 'native'
  build_platform: 'amd64'

# Après (builds natifs parallèles)
with:
  build_type: 'native'
  build_platforms: '["amd64", "arm64"]'
```

### Projet Angular
```yaml
# Avant
with:
  build_platform: 'amd64'
  container_build: true

# Après (multi-arch)
with:
  build_platforms: '["amd64", "arm64"]'
  container_build: true
```

## Impact sur les Performances

### Single Platform
- ⏱️ Temps de build : identique
- 💾 Ressources : identiques

### Multi-Architecture
- ⏱️ Temps de build : +50-100% (builds parallèles)
- 💾 Ressources : +100% (deux images)
- 🚀 Bénéfice : Support natif multi-arch

## Stratégie de Migration Recommandée

### Phase 1 : Migration Simple
1. Remplacer `build_platform` par `build_platforms`
2. Garder une seule plateforme
3. Tester le comportement

### Phase 2 : Multi-Architecture
1. Ajouter la deuxième plateforme
2. Vérifier les temps de build
3. Tester les manifests Docker

### Phase 3 : Optimisation
1. Ajuster selon les besoins
2. Configurer les caches si nécessaire
3. Monitorer les performances

## Vérification de la Migration

### Test Local
```bash
# Vérifier le manifest multi-arch
docker manifest inspect myorg/myapp:v1.0.0

# Vérifier les plateformes supportées
docker manifest inspect myorg/myapp:v1.0.0 | jq '.manifests[].platform'
```

### Test CI/CD
```yaml
# Ajouter un job de vérification
verify-manifest:
  runs-on: ubuntu-latest
  needs: [build]
  steps:
    - name: Verify Multi-Arch Manifest
      run: |
        docker manifest inspect ${{ inputs.docker_image_name }}:${{ github.sha }}
        echo "✅ Multi-arch manifest created successfully"
```

## Support et Troubleshooting

### Problèmes Courants

1. **Erreur JSON** : Vérifier le format du tableau
   ```yaml
   # ❌ Incorrect
   build_platforms: ["amd64", "arm64"]
   
   # ✅ Correct
   build_platforms: '["amd64", "arm64"]'
   ```

2. **Manifest non créé** : Vérifier que les deux builds ont réussi

3. **Temps de build élevé** : Considérer la mise en cache ou les builds conditionnels

### Contacts
- 📚 Documentation complète dans README.md
- 🐛 Issues GitHub pour les bugs
- 💬 Discussions pour les questions
