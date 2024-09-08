if (-not (Test-Command tailscale)) {
    return
}

Set-Alias ts tailscale
