if (-not (Test-Command docker)) {
    return
}

Register-LazyArgumentCompleter -CommandName 'docker' -Generator {
    $script:captured = $null
    function Register-ArgumentCompleter {
        param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
        $script:captured = $ScriptBlock
    }
    Invoke-Expression (& docker completion powershell | Out-String)
    return $script:captured
}
