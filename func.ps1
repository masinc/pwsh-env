function Test-Command(
    [Parameter(
        Mandatory = $true
    )]
    $Name
) {
    return [bool](Get-Command "$Name" -ErrorAction SilentlyContinue)
}

function Test-Directory(
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
    )]
    $Path
) {
    $type = $Path.GetType()
    if ( ($type.Name -eq "DirectoryInfo") ) {
        return $Path.Exists
    }

    if ( $type.Name -eq "String" ) {
        $Path = [System.IO.Path]::GetFullPath($Path, (Get-Location) )

        if ( [System.IO.Directory]::Exists($Path) ) {
            return $true
        }
    }

    return $false
}

function Test-Module(
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
    )]
    $Name
) {
    return $null -ne (Get-Module $Name)
}

function Update-EnvironmentPath () {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Get-Type(
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
    )]
    $Object
) {
    return $Object.GetType()
}

Set-Alias typeof Get-Type

function Get-SpecialFolder(
    [ValidateSet(
        "AdminTools",
        "ApplicationData",
        "CDBurning",
        "CommonAdminTools",
        "CommonApplicationData",
        "CommonDesktopDirectory",
        "CommonDocuments",
        "CommonMusic",
        "CommonOemLinks",
        "CommonPictures",
        "CommonProgramFiles",
        "CommonProgramFilesX86",
        "CommonPrograms",
        "CommonStartMenu",
        "CommonStartup",
        "CommonTemplates",
        "CommonVideos",
        "Cookies",
        "Desktop",
        "DesktopDirectory",
        "Favorites",
        "Fonts",
        "History",
        "InternetCache",
        "LocalApplicationData",
        "LocalizedResources",
        "MyComputer",
        "MyDocuments",
        "MyMusic",
        "MyPictures",
        "MyVideos",
        "NetworkShortcuts",
        "Personal",
        "PrinterShortcuts",
        "ProgramFiles",
        "ProgramFilesX86",
        "Programs",
        "Recent",
        "Resources",
        "SendTo",
        "StartMenu",
        "Startup",
        "System",
        "SystemX86",
        "Templates",
        "UserProfile",
        "Windows"
    )]
    $FolderName
) {
    $SpecialFolder = [System.Environment]::GetFolderPath($FolderName)
    if ( Test-Directory($SpecialFolder) ) {
        return $SpecialFolder
    }
    throw "The folder '$FolderName' does not exist"
}

function Send-DiscordWebhook {

    param (
        [Parameter(Mandatory)]
        [string] $Url,

        [Parameter(Mandatory)]
        [string] $Content,

        [Parameter()]
        [string] $Username
    )

    $body = @{
        "content" = $Content
    };

    if ( -not [string]::IsNullOrEmpty($username)) {
        $body.Add("username", $username);
    };

    Invoke-WebRequest `
        -Method Post `
        -ContentType 'application/json' `
        -Body ($body | ConvertTo-Json) `
        -Uri $Url
}

function Convert-DocxToPdf(
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
    )]
    [string] $InputPath,

    [Parameter()]
    [string] $OutputPath
) {
    $word = New-Object -ComObject Word.Application;
    try {
        $inputFullPath = $(Convert-Path $InputPath);
        $doc = $word.Documents.OpenNoRepairDialog($inputFullPath);

        if ([String]::IsNullOrEmpty($OutputPath)) {
            $outputFullPath = $([System.IO.Path]::ChangeExtension($inputFullPath, "pdf"));
        }
        else {
            $outputFullPath = $(Convert-Path $OutputPath);
        }

        # 17 is PDF
        # https://learn.microsoft.com/ja-jp/office/vba/api/word.wdsaveformat
        $doc.SaveAs($outputFullPath, 17);
    }
    finally {
        $doc.Close()
        $word.Quit()
    }
}

function Register-LazyArgumentCompleter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $CommandName,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $Generator
    )

    if (-not $script:LazyCompletionStore) {
        $script:LazyCompletionStore = @{}
    }

    Register-ArgumentCompleter -Native -CommandName $CommandName -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        if (-not $script:LazyCompletionStore.ContainsKey($CommandName)) {
            try {
                $completer = & $Generator
                $script:LazyCompletionStore[$CommandName] = $completer
            }
            catch {
                $script:LazyCompletionStore[$CommandName] = $null
            }
        }

        $completer = $script:LazyCompletionStore[$CommandName]
        if ($completer -is [scriptblock]) {
            & $completer -wordToComplete $wordToComplete -commandAst $commandAst -cursorPosition $cursorPosition
        }
    }
}

$script:DeferredPromptInitialized = $false
$script:DeferredPromptActions = [System.Collections.Generic.List[scriptblock]]::new()

function Register-DeferredPromptHook {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $Action
    )

    $script:DeferredPromptActions.Add($Action)

    if (-not $script:DeferredPromptInitialized) {
        $script:DeferredPromptInitialized = $true
    }

    $originalPrompt = $Function:prompt

    function global:prompt {
        $actions = $script:DeferredPromptActions.ToArray()
        $script:DeferredPromptActions.Clear()
        foreach ($deferredAction in $actions) {
            & $deferredAction
        }
        if ($originalPrompt) {
            & $originalPrompt
        }
        else {
            "PS $($executionContext.SessionState.Path.CurrentLocation)> "
        }
    }
}
