Get-Command ghq >$null

if ($?) {

    function Select-Ghq-Repository (
        [Parameter(Mandatory = $false)]
        [string]
        $pattern = ""
    ) {
        (ghq list -p "$pattern") -replace "/", "\"  | fzf --preview 'ghq show -p {1}'
    }

    }

    function __ghq__cd__ {
        Set-Location "$(Select-Ghq-Repository)"
    }

    Set-Alias ghq-select Select-Ghq-Repository
    Set-Alias ghq-cd __ghq__cd__
}
