Register-LazyArgumentCompleter -CommandName 'docker' -Generator {
    if (-not (Test-Command docker)) {
        return $null
    }
    $script:captured = $null
    function Register-ArgumentCompleter {
        param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
        $script:captured = $ScriptBlock
    }
    Invoke-Expression (& docker completion powershell | Out-String)
    return $script:captured
}
