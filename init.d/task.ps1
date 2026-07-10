Register-LazyArgumentCompleter -CommandName 'task' -Generator {
    if (-not (Test-Command task)) {
        return $null
    }
    $script:captured = $null
    function Register-ArgumentCompleter {
        param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
        $script:captured = $ScriptBlock
    }
    Invoke-Expression (& task --completion powershell | Out-String)
    return $script:captured
}
