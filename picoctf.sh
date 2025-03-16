name: Build and Release .deb Package

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  build-and-release:
    runs-on: ubuntu-latest

    steps:
      # 1. Checkout repository
      - name: Checkout Repository
        uses: actions/checkout@v3

      # 2. Install dependencies
      - name: Install Dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y shc dpkg-dev debsigs lintian shellcheck gpg

      # 3. Lint Shell Scripts
      - name: Lint Shell Scripts
        run: shellcheck picoctf.sh

      # 4. Build binary from shell script using shc
      - name: Build Binary from Shell Script
        run: |
          chmod +x picoctf.sh
          shc -f picoctf.sh
          mv picoctf.sh.x picoctf
          ls -l picoctf

      # 5. Create .deb package structure with a correctly formatted control file
      - name: Create .deb Package Structure
        run: |
          mkdir -p package/DEBIAN
          mkdir -p package/usr/local/bin
          cp picoctf package/usr/local/bin/
          chmod +x package/usr/local/bin/picoctf

          # Create the control file with proper Debian formatting
          cat <<'EOF' > package/DEBIAN/control
Package: picoctf
Version: 1.0
Section: utils
Priority: optional
Architecture: all
Depends: bash
Maintainer: Mahros <mahros.elqabasy@gmail.com>
Origin: picoctf
Description: A versatile command-line tool for handling picoCTF flags.
 This package provides functionality to wrap input into the picoCTF flag format,
 extract the first picoCTF flag from given text or files, and format input to ensure
 proper capitalization and spacing for picoCTF challenges.
EOF
          cat package/DEBIAN/control

      # 6. Build the .deb package
      - name: Build .deb Package
        run: |
          dpkg-deb --build --root-owner-group package picoctf.deb
          ls -l picoctf.deb

      # 7. Sign the .deb package using debsigs and your GPG key
      - name: Sign .deb Package with GPG
        env:
          GPG_PRIVATE_KEY: ${{ secrets.GPG_PRIVATE_KEY }}
          GPG_PASSPHRASE: ${{ secrets.GPG_PASSPHRASE }}
        run: |
          echo "$GPG_PRIVATE_KEY" | gpg --import
          KEY_ID=$(gpg --list-keys --with-colons | awk -F: '/^pub/ {print $5; exit}')
          echo "Signing using key: $KEY_ID"
          debsigs --sign=origin -k "$KEY_ID" picoctf.deb

      # 8. Validate the package using lintian
      - name: Validate Package with Lintian
        run: |
          lintian picoctf.deb || true

      # 9. Test package installation in a Debian container
      - name: Test Package Installation in Docker Container
        run: |
          docker run --rm -v "$(pwd):/packages" debian:latest bash -c "apt-get update && dpkg -i /packages/picoctf.deb && picoctf --help"

      # 10. Create a GitHub Release and attach the .deb package
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ github.sha }}
          name: Release ${{ github.sha }}
          body: "Automated release of picoCTF package"
          files: picoctf.deb
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
