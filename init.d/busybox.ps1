if (-not (Test-Command busybox)) {
    return
}

[System.Environment]::SetEnvironmentVariable("LANG", "C.UTF-8")
