if (-not (Test-Command kubectl)) {
    return
}

Set-Alias -Name k -Value kubectl
