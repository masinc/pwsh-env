if (-not (Test-Command git)) {
    return
}

if (-not (Test-Module posh-git)) {
    Install-Module posh-git
}

Import-Module posh-git

