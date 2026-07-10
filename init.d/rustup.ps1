if (-not (Test-Command rustup)) {
    return
}

Register-LazyArgumentCompleter -CommandName 'rustup' -Generator {
    $script:captured = $null
    function Register-ArgumentCompleter {
        param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
        $script:captured = $ScriptBlock
    }
    Invoke-Expression (& rustup completions powershell rustup | Out-String)
    return $script:captured
}
