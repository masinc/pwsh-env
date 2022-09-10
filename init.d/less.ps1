if (-not (Test-Command less)) {
    return
}

$env:PAGER = "less.exe"
[System.Environment]::SetEnvironmentVariable("LESS", "-i -M -R")
