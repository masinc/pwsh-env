Get-Command busybox >$null

if ($?) {
    [System.Environment]::SetEnvironmentVariable("LANG", "C.UTF-8")
}
