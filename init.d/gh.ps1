if (-not (Test-Command gh)) {
    return
}

Register-LazyArgumentCompleter -CommandName 'gh' -Generator {
    $script:captured = $null
    function Register-ArgumentCompleter {
        param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
        $script:captured = $ScriptBlock
    }
    Invoke-Expression (& gh completion -s powershell | Out-String)
    return $script:captured
}
