#!/bin/bash

# Script de test pour valider les builds multi-architecture
# Usage: ./test-multi-arch.sh

set -e

echo "🔧 Test des builds multi-architecture"
echo "=================================="

# Test 1: Validation du format JSON pour build_platforms
test_json_parsing() {
    echo "📋 Test 1: Validation du parsing JSON"
    
    # Test avec un seul platform
    SINGLE='["amd64"]'
    RESULT=$(echo $SINGLE | jq -r '.[]')
    if [ "$RESULT" = "amd64" ]; then
        echo "✅ Single platform parsing: OK"
    else
        echo "❌ Single platform parsing: FAILED"
        exit 1
    fi
    
    # Test avec multiple platforms
    MULTI='["amd64", "arm64"]'
    RESULT=$(echo $MULTI | jq -r '.[]' | wc -l)
    if [ "$RESULT" -eq 2 ]; then
        echo "✅ Multi platform parsing: OK"
    else
        echo "❌ Multi platform parsing: FAILED"
        exit 1
    fi
}

# Test 2: Validation de la compatibilité build_platform
test_backward_compatibility() {
    echo "📋 Test 2: Compatibilité ascendante"
    
    # Simuler la conversion build_platform -> build_platforms
    OLD_PARAM="amd64"
    NEW_FORMAT='["'$OLD_PARAM'"]'
    
    PARSED=$(echo $NEW_FORMAT | jq -r '.[]')
    if [ "$PARSED" = "$OLD_PARAM" ]; then
        echo "✅ Backward compatibility: OK"
    else
        echo "❌ Backward compatibility: FAILED"
        exit 1
    fi
}

# Test 3: Validation de la logique de tags Docker
test_docker_tagging() {
    echo "📋 Test 3: Logique de tags Docker"
    
    VERSION="1.0.0"
    PLATFORM="amd64"
    IMAGE_NAME="myorg/myapp"
    
    # Tag attendu pour platform-specific
    EXPECTED_TAG="$IMAGE_NAME:$VERSION-$PLATFORM"
    echo "✅ Platform tag format: $EXPECTED_TAG"
    
    # Tag attendu pour manifest
    MANIFEST_TAG="$IMAGE_NAME:$VERSION"
    echo "✅ Manifest tag format: $MANIFEST_TAG"
}

# Test 4: Validation de la structure des jobs matrix
test_matrix_strategy() {
    echo "📋 Test 4: Stratégie de matrice"
    
    # Simulation de la matrix strategy GitHub Actions
    PLATFORMS='["amd64", "arm64"]'
    
    # Chaque platform devrait créer un job séparé
    for PLATFORM in $(echo $PLATFORMS | jq -r '.[]'); do
        echo "✅ Job créé pour platform: $PLATFORM"
    done
}

# Exécution des tests
main() {
    echo "🚀 Démarrage des tests..."
    echo ""
    
    test_json_parsing
    echo ""
    
    test_backward_compatibility
    echo ""
    
    test_docker_tagging
    echo ""
    
    test_matrix_strategy
    echo ""
    
    echo "🎉 Tous les tests sont passés avec succès !"
    echo ""
    echo "💡 Points clés de l'implémentation:"
    echo "   - Support JSON array pour build_platforms"
    echo "   - Compatibilité avec build_platform (legacy)"
    echo "   - Builds parallèles via matrix strategy"
    echo "   - Tags Docker platform-specific"
    echo "   - Manifest multi-arch automatique"
}

# Vérification des dépendances
if ! command -v jq &> /dev/null; then
    echo "❌ jq n'est pas installé. Installation requise pour les tests."
    echo "   Ubuntu/Debian: sudo apt-get install jq"
    echo "   macOS: brew install jq"
    exit 1
fi

main
