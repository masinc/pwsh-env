if (Test-Command ghq) {

    function Select-Ghq-Repository (
        [Parameter(Mandatory = $false)]
        [string]
        $pattern = ""
    ) {
        (ghq list -p "$pattern") -replace "/", "\"  | fzf --preview 'ghq show -p {1}'
    }

    function Get-Ghq-Repository (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $url
    ) {
        ghq get $url --shallow
    }

    function __ghq__cd__ {
        Set-Location "$(Select-Ghq-Repository)"
    }

    Set-Alias ghq-select Select-Ghq-Repository
    Set-Alias ghq-cd __ghq__cd__
    Set-Alias ghq-clone Get-Ghq-Repository
    Set-Alias ghq-get Get-Ghq-Repository
}
