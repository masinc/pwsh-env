if (Test-Command less) {
    $env:PAGER = "less.exe"
    [System.Environment]::SetEnvironmentVariable("LESS", "-i -M -R")
}
