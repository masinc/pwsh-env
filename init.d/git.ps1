if (Test-Command git) {
    Register-DeferredPromptHook {
        Import-Module git-completion
    }
}
