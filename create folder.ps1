Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==========================
# Node.js install check
# ==========================
$node = Get-Command node -ErrorAction SilentlyContinue

if (-not $node) {
    # Form create
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Node.js Not Found"
    $form.Size = New-Object System.Drawing.Size(350,150)
    $form.StartPosition = "CenterScreen"

    # Label
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Please download and install Node.js"
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(50,20)
    $form.Controls.Add($label)

    # Download button
    $downloadButton = New-Object System.Windows.Forms.Button
    $downloadButton.Text = "Download"
    $downloadButton.Size = New-Object System.Drawing.Size(100,30)
    $downloadButton.Location = New-Object System.Drawing.Point(50,60)
    $downloadButton.Add_Click({
        Start-Process "https://nodejs.org/dist/v22.18.0/node-v22.18.0-x64.msi"
        $form.Close()
    })
    $form.Controls.Add($downloadButton)

    # Close button
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Text = "Close"
    $closeButton.Size = New-Object System.Drawing.Size(100,30)
    $closeButton.Location = New-Object System.Drawing.Point(170,60)
    $closeButton.Add_Click({ $form.Close() })
    $form.Controls.Add($closeButton)

    $form.ShowDialog() | Out-Null
    exit
}

# ==========================
# Create folder structure
# ==========================
$docPath = [Environment]::GetFolderPath("MyDocuments")
$newFolderName = "MyNewFolder"
$newFolderPath = Join-Path -Path $docPath -ChildPath $newFolderName

if (-Not (Test-Path -Path $newFolderPath)) {
    New-Item -ItemType Directory -Path $newFolderPath | Out-Null
    Write-Output "Folder created at $newFolderPath"
} else {
    Write-Output "Folder already exists at $newFolderPath"
}

$subFolders = @("project", "assets")
foreach ($folder in $subFolders) {
    $subFolderPath = Join-Path -Path $newFolderPath -ChildPath $folder
    if (-Not (Test-Path -Path $subFolderPath)) {
        New-Item -ItemType Directory -Path $subFolderPath | Out-Null
        Write-Output "Subfolder created: $subFolderPath"
    } else {
        Write-Output "Subfolder already exists: $subFolderPath"
    }
}

# ==========================
# Create package.json (BOM-free UTF-8)
# ==========================
$packageFilePath = Join-Path -Path $newFolderPath -ChildPath "package.json"

$jsonContent = @'
{
  "name": "electron-app",
  "version": "1.0.0",
  "description": "",
  "main": "assets/main.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "electron .",
    "prebuild": "powershell -ExecutionPolicy Bypass -File assets/appname.ps1 && node assets/updateProductName.js",
    "postbuild": "del /f /q dist\\builder-debug.yml dist\\builder-effective-config.yaml dist\\*.blockmap",
    "build": "electron-builder"
  },
  "author": "Darshana",
  "license": "ISC",
  "devDependencies": {
    "electron": "^37.2.6",
    "electron-builder": "^26.0.12"
  },
  "build": {
    "appId": "com.myapp.id",
    "productName": "App8",
    "win": {
      "target": "nsis",
      "icon": "project/favicon.ico",
      "artifactName": "${productName} Installer.exe"
    },
    "nsis": {
      "oneClick": false,
      "perMachine": false,
      "allowToChangeInstallationDirectory": true
    }
  }
}
'@

# Save without BOM
Set-Content -Path $packageFilePath -Value $jsonContent -Encoding UTF8
Write-Output "package.json file created with JSON content"

# ==========================
# Install dependencies
# ==========================
Push-Location $newFolderPath
Write-Output "Installing electron..."
npm install --save-dev electron
Write-Output "Installing electron-builder..."
npm install --save-dev electron-builder
Pop-Location

Write-Output "Setup completed successfully in $newFolderPath"
