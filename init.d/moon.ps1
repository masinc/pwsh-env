Register-LazyArgumentCompleter -CommandName 'moon' -Generator {
    if (-not (Test-Command moon)) {
        return $null
    }
    $script:captured = $null
    function Register-ArgumentCompleter {
        param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
        $script:captured = $ScriptBlock
    }
    Invoke-Expression (& moon shell-completion --shell powershell | Out-String)
    return $script:captured
}
