. "$PSScriptRoot/init.ps1"
New-Item -Force -ItemType Directory -Path "$PSScriptRoot/completion.generated.d" > $null

if (Test-Command kubectl) {
    kubectl completion powershell > "$PSScriptRoot/completion.generated.d/kubectl.ps1"

    # alias k
    Copy-Item "$PSScriptRoot/completion.generated.d/kubectl.ps1" "$PSScriptRoot/completion.generated.d/k.ps1"
    kubectl completion powershell | ForEach-Object { $_ -replace "-CommandName 'kubectl'", "-CommandName 'k'" } | Set-Content "$PSScriptRoot/completion.generated.d/k.ps1"
    $_k 
}

if (Test-Command gh) {
    gh completion -s powershell > "$PSScriptRoot/completion.generated.d/gh.ps1"
} 

if (Test-Command task) {
    $p = Split-Path -Parent $(scoop which task)
    Copy-Item ${p}\completion\ps\task.ps1 "$PSScriptRoot/completion.generated.d/task.ps1"
}

if (Test-Command docker) {
    docker completion powershell > "$PSScriptRoot/completion.generated.d/docker.ps1"
}

if (Test-Command uv) {
    uv generate-shell-completion powershell > "$PSScriptRoot/completion.generated.d/uv.ps1"
}

if (Test-Command rustup) {
    rustup completions powershell rustup > "$PSScriptRoot/completion.generated.d/rustup.ps1"
}

# pwsl not supported
# if (Test-Command cargo) {
#     rustup completions powershell cargo > "$PSScriptRoot/completion.generated.d/cargo.ps1"
# }
