# Document folder path ගන්න
$docPath = [Environment]::GetFolderPath("MyDocuments")

# නව folder එකේ නම
$newFolderName = "MyNewFolder"

# නව folder එකේ full path එක
$newFolderPath = Join-Path -Path $docPath -ChildPath $newFolderName

# නව folder එක හදා ගන්න (නැතිනම්)
if (-Not (Test-Path -Path $newFolderPath)) {
    New-Item -ItemType Directory -Path $newFolderPath | Out-Null
    Write-Output "Folder created at $newFolderPath"
} else {
    Write-Output "Folder already exists at $newFolderPath"
}

# subfolders ලයිස්තුව
$subFolders = @("project", "assets")

# subfolders හදා ගන්න
foreach ($folder in $subFolders) {
    $subFolderPath = Join-Path -Path $newFolderPath -ChildPath $folder
    if (-Not (Test-Path -Path $subFolderPath)) {
        New-Item -ItemType Directory -Path $subFolderPath | Out-Null
        Write-Output "Subfolder created: $subFolderPath"
    } else {
        Write-Output "Subfolder already exists: $subFolderPath"
    }
}

# package.json file එකේ path එක
$packageFilePath = Join-Path -Path $newFolderPath -ChildPath "assets/package.json"

# JSON content එක define කරගන්න
$jsonContent = @'
  history: "This is a sample package.json file",
'@

# JSON content එක file එකට save කරන්න
$jsonContent | Out-File -FilePath $packageFilePath -Encoding UTF8 -Force

Write-Output "package.json file created with JSON content"
