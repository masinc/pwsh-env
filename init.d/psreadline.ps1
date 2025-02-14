# https://docs.microsoft.com/en-us/powershell/module/psreadline/about/about_psreadline

# disable beep
Set-PSReadLineOption -BellStyle None

# history
Set-PSReadLineOption -PredictionViewStyle InlineView

try {
    Set-PSReadLineOption -PredictionSource History
}
catch {
    # ignore
}



# emacs mode
Set-PSReadLineOption -EditMode Emacs

# allow history search
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward


# ctrl+q/Q: tab completion
Set-PSReadLineKeyHandler -Key Ctrl+q -Function TabCompleteNext
Set-PSReadLineKeyHandler -Key Ctrl+Q -Function TabCompletePrevious

# ctrl+c ctrl+v : copy and paste
Set-PSReadLineKeyHandler -Key Ctrl+C -Function Copy
Set-PSReadLineKeyHandler -Key Ctrl+v -Function Paste
