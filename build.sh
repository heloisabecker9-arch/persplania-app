#!/bin/bash
set -e

echo "Installing Flutter..."

# Criar diretório para Flutter
mkdir -p /tmp/flutter
cd /tmp/flutter

# Baixar Flutter stable release (pre-built)
FLUTTER_VERSION="3.19.6"
echo "Downloading Flutter $FLUTTER_VERSION..."
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -o flutter.tar.xz

echo "Extracting Flutter..."
tar xf flutter.tar.xz

# Configurar PATH
export PATH="/tmp/flutter/flutter/bin:$PATH"
export FLUTTER_HOME="/tmp/flutter/flutter"

# Desabilitar analytics e crash reporting
flutter config --no-analytics
flutter config --no-crash-reporting

# Aceitar licenças
echo "y" | flutter doctor --android-licenses || true

echo "Checking Flutter installation..."
flutter --version

# Voltar para o diretório do projeto
cd /vercel/path0

echo "Installing Flutter dependencies..."
cd flutter_app
flutter pub get

echo "Building web release..."
flutter build web --release

echo "Build completed successfully!"