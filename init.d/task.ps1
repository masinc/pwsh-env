if (-not (Test-Command task)) {
    return
}

Register-LazyArgumentCompleter -CommandName 'task' -Generator {
    $script:captured = $null
    function Register-ArgumentCompleter {
        param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
        $script:captured = $ScriptBlock
    }
    Invoke-Expression (& task --completion powershell | Out-String)
    return $script:captured
}
