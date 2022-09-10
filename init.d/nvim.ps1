if (-not (Test-Command nvim)) {
    return
}
function __nvim_view__ {
    nvim -R $args
}

Set-Alias vi nvim
Set-Alias vim nvim
Set-Alias view __nvim_view__

