#!/bin/bash

# Function to create a file with content
create_file() {
    local file_path="$1"
    local content="$2"
    mkdir -p "$(dirname "$file_path")"
    echo "$content" > "$file_path"
}

# Create project directory
project_name="my-electron-app"
mkdir "$project_name"
cd "$project_name"

# Create package.json
create_file "package.json" '{
  "name": "my-electron-app",
  "version": "1.0.0",
  "description": "An Electron app for Red Hat",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "build": "electron-builder --linux rpm",
    "package": "electron-packager . app --platform linux --arch x64 --out dist/",
    "rpm": "electron-installer-redhat --src dist/app-linux-x64/ --dest dist/installers/ --arch x86_64"
  },
  "author": "Your Name",
  "license": "MIT",
  "devDependencies": {
    "electron": "^latest",
    "electron-builder": "^latest",
    "electron-packager": "^latest",
    "electron-installer-redhat": "^latest"
  },
  "build": {
    "appId": "com.example.myapp",
    "productName": "My Electron App",
    "linux": {
      "target": ["rpm"],
      "category": "Utility"
    }
  }
}'

# Create main.js
create_file "main.js" "const { app, BrowserWindow } = require('electron')

function createWindow () {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true
    }
  })

  win.loadFile('index.html')
}

app.whenReady().then(createWindow)

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow()
  }
})"

# Create index.html
create_file "index.html" '<!DOCTYPE html>
<html>
  <head>
    <title>Electron App for Red Hat</title>
  </head>
  <body>
    <h1>Hello Red Hat!</h1>
    <p>This is an Electron app running on Red Hat.</p>
  </body>
</html>'

# Create README.md
create_file "README.md" "# Electron App for Red Hat

This is a simple Electron application packaged for Red Hat Linux.

## Development

To install dependencies:

\`\`\`
pnpm install
\`\`\`

To run the app:

\`\`\`
pnpm start
\`\`\`

## Building for Red Hat

To build the app:

\`\`\`
pnpm run package
pnpm run rpm
\`\`\`

The RPM package will be available in the \`dist/installers/\` directory."

# Create .github/workflows/build.yml
create_file ".github/workflows/build.yml" "name: Build Electron App

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '22.7.0'  # Specify the latest LTS version explicitly

    - name: Run setup script
      run: |
        chmod +x generate_electron_project.sh
        ./generate_electron_project.sh

    - name: Install pnpm
      run: npm install -g pnpm

    - name: Install dependencies
      run: pnpm install

    - name: Package app
      run: pnpm run package

    - name: Build RPM
      run: pnpm run rpm

    - name: Upload RPM artifact
      uses: actions/upload-artifact@v2
      with:
        name: rpm-package
        path: dist/installers/*.rpm"

# Create generate_electron_project.sh
create_file "generate_electron_project.sh" '#!/bin/bash
sudo apt-get update
sudo apt-get install -y python3 make g++
npm config set python /usr/bin/python3'

# Make generate_electron_project.sh executable
chmod +x generate_electron_project.sh

echo "Electron app structure created successfully!"
echo "To set up and build the project, run the following commands:"
echo "cd $project_name"
echo "./generate_electron_project.sh  # Run this first to set up the environment"
echo "pnpm install"
echo "pnpm start     # To run the app"
echo "pnpm run package  # To package the app"
echo "pnpm run rpm      # To create the RPM package"
