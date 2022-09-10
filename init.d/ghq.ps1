if (-not (Test-Command ghq)) {
    return;
}

function Select-GhqRepository (
    [Parameter(Mandatory = $false)]
    [string]
    $pattern = ""
) {
    ghq list -p "$pattern" | fzf --preview 'ghq show -p {1}'
}

function Import-GhqRepository (
    [Parameter(
        Mandatory = $true
    )]
    [string]
    $url
) {
    ghq get $url --shallow
}

function Enter-GhqLocation {
    Set-Location "$(Select-GhqRepository)"
}

function Get-GhqRepository (
    [Parameter(Mandatory = $false)]
    [string]
    $pattern = ""
) {                
    ghq list -p "$pattern"
}

Set-Alias ghq-select Select-GhqRepository
Set-Alias ghq-cd Enter-GhqLocation
Set-Alias ghq-clone Import-GhqRepository
Set-Alias ghq-get Import-GhqRepository
Set-Alias ghq-list Get-GhqRepository

