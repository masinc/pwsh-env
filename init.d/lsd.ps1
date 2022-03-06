Get-Command lsd >$null

if ($?) {
    function __ll__ {
        lsd -l $args
    }

    function __lh__ {
        lsd -h $args
    }

    Set-Alias -Name ll -Value __ll__
    Set-Alias -Name lh -Value __lh__

}

