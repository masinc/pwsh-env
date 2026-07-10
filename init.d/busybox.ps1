if (Test-Command busybox) {
    [System.Environment]::SetEnvironmentVariable("LANG", "C.UTF-8")
}
