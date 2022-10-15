if (-not (Test-Command docker)) {
    return
}

if (-not (Test-Module DockerCompletion)) {
    Install-Module DockerCompletion
}

Import-Module DockerCompletion
