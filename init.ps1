# encoding
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# add pwsh modules
. (Join-Path $PSScriptRoot "psmodules" "import.ps1")

# import env
if (Test-Path "$PSScriptRoot\.env.ps1") {
    . $PSScriptRoot\.env.ps1
}

# append PATH environment variable
if ($env:PATH -notcontains ";~\bin") {
    $env:PATH += ";~\bin"
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
if (Test-Path "$PSScriptRoot\bins") {
    Get-ChildItem -Directory "$PSScriptRoot\bins"
    | ForEach-Object { $env:PATH += ";" + $_.FullName }
}


# load cmdlet.d\*.ps1
if (Test-Path "$PSScriptRoot\cmdlet.d\") {
    Get-ChildItem "$PSScriptRoot\cmdlet.d\*.ps1"
    | ForEach-Object { . $_.FullName }
}

# load init.d\*.ps1
Get-ChildItem "$PSScriptRoot\init.d\*.ps1"
| ForEach-Object { . $_.FullName }

# load completion.d\*.ps1
if (Test-Path "$PSScriptRoot\completion.d\*.ps1") {
    Get-ChildItem "$PSScriptRoot\completion.d\*.ps1"
    | ForEach-Object { . $_.FullName }
}

# load completion.generate.d\*.ps1
if (Test-Path "$PSScriptRoot\completion.generated.d\*.ps1") {
    Get-ChildItem "$PSScriptRoot\completion.generated.d\*.ps1"
    | ForEach-Object { . $_.FullName }
}

# load alias.d\*.ps1
Get-ChildItem "$PSScriptRoot\alias.d\*.ps1"
| ForEach-Object { . $_.FullName }
