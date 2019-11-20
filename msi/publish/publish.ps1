Get-Content .\$env:BUILDENV | Select-String -Match "^export" -Replace "export ",""| ForEach-Object {
    $array= $_[0].ToString().split("=")
    [System.Environment]::SetEnvironmentVariable($array[0], $array[1])
}

Write-Host "Copying binaries to $($env:MSIDIR)"
if(-not Test-Path $env:MSIDIR) {
  New-Item -ItemType Directory -Path $env:MSIDIR
}

Get-ChildItem -Path '.\msi\build\bin\Release\en-US\*' -File -Include *.msi,*.msi.sha256 | Copy-Item -Destination $env:MSIDIR

Get-ChildItem -Path $env:MSIDIR
