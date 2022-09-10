if (-not (Test-Command docker)) {
    return
}

Import-Module DockerCompletion
