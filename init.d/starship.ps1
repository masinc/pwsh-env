Get-Command starship >$null

if ($?) {
    Invoke-Expression (&starship init powershell)
}
