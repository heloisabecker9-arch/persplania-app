#!/bin/bash
set -e

# Instalar Flutter
echo "Installing Flutter..."
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz
export PATH="$PWD/flutter/bin:$PATH"

# Verificar Flutter
flutter doctor --android-licenses || true
flutter doctor

# Entrar na pasta do app
cd flutter_app

# Instalar dependências
flutter pub get

# Build web
flutter build web --release

echo "Build completed successfully"