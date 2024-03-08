if (-not (Test-Command direnv)) {
    return
}

$env:DIRENV_CONFIG = "$APPDATA\direnv"
$env:XDG_CACHE_HOME = "$APPDATA\direnv\cache"
$env:XDG_DATA_HOME = "$APPDATA\direnv\data"

Invoke-Expression "$(direnv hook pwsh)"
