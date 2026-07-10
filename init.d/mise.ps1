if (Test-Command mise) {
    Register-DeferredPromptHook {
        Invoke-Expression (& mise activate pwsh | Out-String)
    }
}
