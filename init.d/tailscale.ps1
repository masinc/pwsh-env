if (-not (Test-Command tailscale)) {
    return
}

Set-Alias ts tailscale

tailscale completion powershell | Out-String | Invoke-Expression
