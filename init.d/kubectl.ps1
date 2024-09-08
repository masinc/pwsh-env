if (-not (Test-Command kubectl)) {
    return
}

Set-Alias k kubectl
