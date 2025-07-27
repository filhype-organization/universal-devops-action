#!/bin/bash

# Script de débogage pour les manifests Docker multi-architecture
# Usage: ./debug-manifests.sh <image_name> <version>

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <image_name> <version>"
    echo "Example: $0 myorg/myapp v1.0.0"
    exit 1
fi

IMAGE_NAME="$1"
VERSION="$2"

echo "🔍 Débogage des manifests Docker pour $IMAGE_NAME:$VERSION"
echo "============================================================"

# Fonction pour afficher des informations sur un manifest/image
inspect_manifest() {
    local tag="$1"
    local description="$2"
    
    echo ""
    echo "📋 $description: $tag"
    echo "----------------------------------------"
    
    if docker manifest inspect "$tag" >/dev/null 2>&1; then
        local manifest=$(docker manifest inspect "$tag")
        local media_type=$(echo "$manifest" | jq -r '.mediaType // "unknown"')
        local schema_version=$(echo "$manifest" | jq -r '.schemaVersion // "unknown"')
        
        echo "✅ Manifest trouvé"
        echo "   Media Type: $media_type"
        echo "   Schema Version: $schema_version"
        
        if echo "$manifest" | jq -e '.manifests[]' >/dev/null 2>&1; then
            echo "   Type: Manifest List (Multi-arch)"
            echo "   Plateformes disponibles:"
            echo "$manifest" | jq -r '.manifests[] | "     - \(.platform.architecture // "unknown")/\(.platform.os // "unknown")"'
        else
            echo "   Type: Image Manifest (Single platform)"
            local arch=$(echo "$manifest" | jq -r '.architecture // "unknown"')
            local os=$(echo "$manifest" | jq -r '.os // "unknown"')
            echo "   Plateforme: $arch/$os"
        fi
    else
        echo "❌ Manifest non trouvé"
    fi
}

# Vérifier les images platform-specific
inspect_manifest "$IMAGE_NAME:$VERSION-amd64" "Image AMD64"
inspect_manifest "$IMAGE_NAME:$VERSION-arm64" "Image ARM64"

# Vérifier le manifest multi-arch
inspect_manifest "$IMAGE_NAME:$VERSION" "Manifest Multi-arch"

# Vérifier latest si applicable
if [[ ! "$VERSION" =~ "-snapshot" ]]; then
    inspect_manifest "$IMAGE_NAME:latest" "Manifest Latest"
fi

echo ""
echo "🛠️  Commandes de débogage utiles:"
echo "----------------------------------------"
echo "# Vérifier tous les tags disponibles:"
echo "curl -s \"https://registry-1.docker.io/v2/$IMAGE_NAME/tags/list\" | jq '.tags[]' | sort"
echo ""
echo "# Supprimer un manifest corrompu:"
echo "docker manifest rm $IMAGE_NAME:$VERSION"
echo ""
echo "# Créer manuellement un manifest multi-arch:"
echo "docker manifest create $IMAGE_NAME:$VERSION \\"
echo "  $IMAGE_NAME:$VERSION-amd64 \\"
echo "  $IMAGE_NAME:$VERSION-arm64"
echo "docker manifest push $IMAGE_NAME:$VERSION"
echo ""
echo "# Tester le pull multi-arch:"
echo "docker pull $IMAGE_NAME:$VERSION --platform linux/amd64"
echo "docker pull $IMAGE_NAME:$VERSION --platform linux/arm64"

echo ""
echo "✅ Analyse terminée!"
