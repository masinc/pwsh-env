if (Test-Command nvim) {
    function __view__ {
        nvim -R $args
    }

    Set-Alias vi nvim
    Set-Alias vim nvim
    Set-Alias view __view__
}
