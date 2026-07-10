Set-Alias k kubectl

$script:KubectlCompleterLoaded = $false

$kubectlCompleter = {
    param($wordToComplete, $commandAst, $cursorPosition)

    if (-not $script:KubectlCompleterLoaded) {
        $script:captured = $null
        function Register-ArgumentCompleter {
            param([string[]]$CommandName, [scriptblock]$ScriptBlock, [switch]$Native)
            $script:captured = $ScriptBlock
        }
        Invoke-Expression (& kubectl completion powershell | Out-String)
        $script:KubectlCompleter = $script:captured
        $script:KubectlCompleterLoaded = $true
    }

    if ($script:KubectlCompleter -is [scriptblock]) {
        & $script:KubectlCompleter -wordToComplete $wordToComplete -commandAst $commandAst -cursorPosition $cursorPosition
    }
}

Register-ArgumentCompleter -Native -CommandName 'kubectl' -ScriptBlock $kubectlCompleter
Register-ArgumentCompleter -Native -CommandName 'k' -ScriptBlock $kubectlCompleter
