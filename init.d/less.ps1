Get-Command less >$null

if ($?) {
    $env:PAGER = "less.exe"
    [System.Environment]::SetEnvironmentVariable("LESS", "-i -M -R")
}
