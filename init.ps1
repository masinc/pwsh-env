# encoding
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# append PATH environment variable
if ($env:PATH -notcontains ";~\bin") {
    $env:PATH += ";~\bin"
}

if ($env:PATH -notcontains ";$PSScriptRoot\node_modules\.bin") {
    $env:PATH += ";$PSScriptRoot\node_modules\.bin"
}

if (Test-Path "$PSScriptRoot\.path") {
    Get-Content "$PSScriptRoot\.path" 
    | ForEach-Object {
        if ((Test-Path $_) -and ($env:PATH -notcontains $_)) {
            $env:PATH += ";$_"
        }
    }
}

# append \bins\* to the PATH environment variable
Get-ChildItem -Directory "$PSScriptRoot\bins"
| ForEach-Object { $env:PATH += ";" + $_.FullName }

# load cmdlet.d\*.ps1
Get-ChildItem "$PSScriptRoot\cmdlet.d\*.ps1"
| ForEach-Object { . $_.FullName }

# load init.d\*.ps1
Get-ChildItem "$PSScriptRoot\init.d\*.ps1"
| ForEach-Object { . $_.FullName }

# load completion.generate.d\*.ps1
if (Test-Path "$PSScriptRoot\completion.generated.d\*.ps1") {
    Get-ChildItem "$PSScriptRoot\completion.generated.d\*.ps1"
    | ForEach-Object { . $_.FullName }
}

# load alias.d\*.ps1
Get-ChildItem "$PSScriptRoot\alias.d\*.ps1"
| ForEach-Object { . $_.FullName }
