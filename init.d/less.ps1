Get-Command less >$null

if ($?) {
    [System.Environment]::SetEnvironmentVariable("LESS", "-i -M -R")
}
