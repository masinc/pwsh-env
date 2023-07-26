if (-not (Test-Command sgpt)) {
    return
}

Set-Alias -Name q -Value sgpt.exe
