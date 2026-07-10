$env:UV_CACHE_DIR = "d:\cache\uv"

Register-LazyArgumentCompleter -CommandName 'uv' -Generator {
    if (-not (Test-Command uv)) {
        return $null
    }
    $script:captured = $null
    function Register-ArgumentCompleter {
        param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
        $script:captured = $ScriptBlock
    }
    Invoke-Expression (& uv generate-shell-completion powershell | Out-String)
    return $script:captured
}
