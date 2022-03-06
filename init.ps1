# encoding
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# append \bins\* to the PATH environment variable
Get-ChildItem -Directory "$PSScriptRoot\bins"
| ForEach-Object { $env:PATH += ";" + $_.FullName }

# load init.d\*.ps1
Get-ChildItem "$PSScriptRoot\init.d\*.ps1"
| ForEach-Object { . $_.FullName }

# load init.generated.d\*.ps1
if (Test-Path "$PSScriptRoot\init.d\*.ps1") {
    Get-ChildItem "$PSScriptRoot\init.generated.d\*.ps1"
    | ForEach-Object { . $_.FullName }
}

# load cmdlet.d\*.ps1
Get-ChildItem "$PSScriptRoot\cmdlet.d\*.ps1"
| ForEach-Object { . $_.FullName }
