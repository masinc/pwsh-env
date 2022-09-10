if (-not (Test-Command starship)) {
    return
}


Invoke-Expression (&starship init powershell)
