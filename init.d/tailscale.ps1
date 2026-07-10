Register-LazyArgumentCompleter -CommandName 'tailscale' -Generator {
    if (-not (Test-Command tailscale)) {
        return $null
    }
    $script:captured = $null
    function Register-ArgumentCompleter {
        param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
        $script:captured = $ScriptBlock
    }
    Invoke-Expression (& tailscale completion powershell | Out-String)
    return $script:captured
}
