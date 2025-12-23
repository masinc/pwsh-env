# Cargo completion for PowerShell 7.5
# This script provides tab completion for cargo commands in PowerShell

using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# Cache for cargo commands
$script:CargoCommandsCache = @()

function Get-CargoCommands {
    if ($script:CargoCommandsCache.Count -eq 0) {
        $script:CargoCommandsCache = cargo --list 2>$null | Select-Object -Skip 1 | ForEach-Object {
            ($_ -split '\s+')[0]
        }
    }
    return $script:CargoCommandsCache
}

function Get-ManifestPath {
    $result = cargo locate-project --message-format plain 2>$null
    return $result
}

function Get-NamesFromManifest {
    param(
        [string]$BlockName
    )
    
    $manifest = Get-ManifestPath
    if (-not $manifest) {
        return @()
    }
    
    $names = @()
    $inBlock = $false
    $lastLine = ""
    
    $content = Get-Content $manifest
    foreach ($line in $content) {
        if ($lastLine -eq "[[$BlockName]]") {
            $inBlock = $true
        }
        elseif ($lastLine -match '\[\[.*\]\]') {
            $inBlock = $false
        }
        
        if ($inBlock -and $line -match 'name\s*=\s*"([^"]+)"') {
            $names += $Matches[1]
        }
        
        $lastLine = $line
    }
    
    return $names
}

function Get-BinNames {
    return Get-NamesFromManifest -BlockName "bin"
}

function Get-TestNames {
    return Get-NamesFromManifest -BlockName "test"
}

function Get-BenchNames {
    return Get-NamesFromManifest -BlockName "bench"
}

function Get-Examples {
    $manifest = Get-ManifestPath
    if (-not $manifest) {
        return @()
    }
    
    $manifestDir = Split-Path $manifest -Parent
    $examplesDir = Join-Path $manifestDir "examples"
    
    if (Test-Path $examplesDir) {
        $examples = Get-ChildItem "$examplesDir\*.rs" -ErrorAction SilentlyContinue | 
            ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) }
        return $examples
    }
    
    return @()
}

function Get-Targets {
    if (Get-Command rustup -ErrorAction SilentlyContinue) {
        rustup target list --installed
    }
    else {
        rustc --print target-list
    }
}

function Get-Toolchains {
    $result = @()
    $toolchains = rustup toolchain list 2>$null
    
    foreach ($line in $toolchains) {
        # Strip " (default)"
        $line = $line -replace '\s+\(default\)$', ''
        
        # Match pattern: channel(-date)?(-host)
        if ($line -match '^(nightly|beta|stable|\d+\.\d+\.\d+)(-(\d{4}-\d{2}-\d{2}))?(-.*)?') {
            $channel = $Matches[1]
            $date = $Matches[3]
            
            if ($date) {
                $result += "+$channel-$date"
            }
            else {
                $result += "+$channel"
            }
            $result += "+$line"
        }
        else {
            $result += "+$line"
        }
    }
    
    return $result | Select-Object -Unique
}

# Define option sets
$script:CargoOptions = @{
    # Common options
    Common = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color')
    Color = @('auto', 'always', 'never')
    MessageFormat = @('human', 'json', 'short')
    VCS = @('git', 'hg', 'none', 'pijul', 'fossil')
    
    # Command-specific options
    NoCmdOptions = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-V', '--version', '--list', '--explain')
    
    add = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--features', '--default-features', '--no-default-features', '--manifest-path', '--optional', '--no-optional', '--rename', '--dry-run', '--path', '--git', '--branch', '--tag', '--rev', '--registry', '--dev', '--build', '--target', '--ignore-rust-version')
    
    bench = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--all', '--exclude', '--workspace', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '-j', '--jobs', '--lib', '--bin', '--bins', '--example', '--examples', '--test', '--tests', '--bench', '--benches', '--all-targets', '--message-format', '--target', '--no-run', '--no-fail-fast', '--target-dir', '--ignore-rust-version')
    
    build = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--all', '--exclude', '--workspace', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '-j', '--jobs', '--keep-going', '--lib', '--bin', '--bins', '--example', '--examples', '--test', '--tests', '--bench', '--benches', '--all-targets', '--message-format', '--target', '--release', '--profile', '--target-dir', '--ignore-rust-version')
    
    check = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--all', '--exclude', '--workspace', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '-j', '--jobs', '--keep-going', '--lib', '--bin', '--bins', '--example', '--examples', '--test', '--tests', '--bench', '--benches', '--all-targets', '--message-format', '--target', '--release', '--profile', '--target-dir', '--ignore-rust-version')
    
    clean = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--manifest-path', '--frozen', '--locked', '--offline', '--target', '--release', '--doc', '--target-dir', '--profile')
    
    clippy = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--all', '--exclude', '--workspace', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '-j', '--jobs', '--keep-going', '--lib', '--bin', '--bins', '--example', '--examples', '--test', '--tests', '--bench', '--benches', '--all-targets', '--message-format', '--target', '--release', '--profile', '--target-dir', '--no-deps', '--fix')
    
    doc = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--all', '--exclude', '--workspace', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '-j', '--jobs', '--keep-going', '--message-format', '--bin', '--bins', '--lib', '--target', '--open', '--no-deps', '--release', '--document-private-items', '--target-dir', '--profile', '--ignore-rust-version')
    
    fetch = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--manifest-path', '--frozen', '--locked', '--offline', '--target')
    
    fix = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--all', '--exclude', '--workspace', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '-j', '--jobs', '--keep-going', '--lib', '--bin', '--bins', '--example', '--examples', '--test', '--tests', '--bench', '--benches', '--all-targets', '--frozen', '--locked', '--offline', '--release', '--target', '--message-format', '--broken-code', '--edition', '--edition-idioms', '--allow-no-vcs', '--allow-dirty', '--allow-staged', '--profile', '--target-dir', '--ignore-rust-version')
    
    'generate-lockfile' = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--manifest-path', '--frozen', '--locked', '--offline')
    
    init = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--frozen', '--locked', '--offline', '--bin', '--lib', '--name', '--vcs', '--edition', '--registry')
    
    install = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-F', '--features', '--all-features', '--no-default-features', '-j', '--jobs', '--keep-going', '--frozen', '--locked', '--offline', '-f', '--force', '--bin', '--bins', '--branch', '--debug', '--example', '--examples', '--git', '--list', '--path', '--rev', '--root', '--tag', '--version', '--registry', '--target', '--profile', '--no-track', '--ignore-rust-version')
    
    'locate-project' = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--manifest-path', '--frozen', '--locked', '--offline', '--message-format', '--workspace')
    
    login = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--frozen', '--locked', '--offline', '--registry')
    
    metadata = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '--format-version=1', '--no-deps', '--filter-platform')
    
    new = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--frozen', '--locked', '--offline', '--vcs', '--bin', '--lib', '--name', '--edition', '--registry')
    
    owner = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--frozen', '--locked', '--offline', '-a', '--add', '-r', '--remove', '-l', '--list', '--index', '--token', '--registry')
    
    package = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--manifest-path', '-F', '--features', '--all-features', '--no-default-features', '--frozen', '--locked', '--offline', '-j', '--jobs', '--keep-going', '--allow-dirty', '-l', '--list', '--no-verify', '--no-metadata', '--index', '--registry', '--target', '--target-dir')
    
    pkgid = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--manifest-path', '--frozen', '--locked', '--offline', '-p', '--package')
    
    publish = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--manifest-path', '-F', '--features', '--all-features', '--no-default-features', '--frozen', '--locked', '--offline', '-j', '--jobs', '--keep-going', '--allow-dirty', '--dry-run', '--token', '--no-verify', '--index', '--registry', '--target', '--target-dir')
    
    remove = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--frozen', '--locked', '--offline', '--manifest-path', '--dry-run', '--dev', '--build', '--target')
    
    report = @('-h', '--help', '-v', '--verbose', '--color', 'future-incompat', 'future-incompatibilities')
    
    'report future-incompat' = @('-h', '--help', '-v', '--verbose', '--color', '-p', '--package', '--id')
    
    run = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '-j', '--jobs', '--keep-going', '--message-format', '--target', '--bin', '--example', '--release', '--target-dir', '--profile', '--ignore-rust-version')
    
    rustc = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '-j', '--jobs', '--keep-going', '--lib', '--bin', '--bins', '--example', '--examples', '--test', '--tests', '--bench', '--benches', '--all-targets', '-L', '--crate-type', '--extern', '--message-format', '--profile', '--target', '--release', '--target-dir', '--ignore-rust-version')
    
    rustdoc = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '-j', '--jobs', '--keep-going', '--lib', '--bin', '--bins', '--example', '--examples', '--test', '--tests', '--bench', '--benches', '--all-targets', '--message-format', '--target', '--release', '--open', '--target-dir', '--profile', '--ignore-rust-version')
    
    search = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--frozen', '--locked', '--offline', '--limit', '--index', '--registry')
    
    test = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--all', '--exclude', '--workspace', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '-j', '--jobs', '--lib', '--bin', '--bins', '--example', '--examples', '--test', '--tests', '--bench', '--benches', '--all-targets', '--message-format', '--doc', '--target', '--no-run', '--release', '--no-fail-fast', '--target-dir', '--profile', '--ignore-rust-version')
    
    tree = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '-p', '--package', '--all', '--exclude', '--workspace', '-F', '--features', '--all-features', '--no-default-features', '--manifest-path', '--frozen', '--locked', '--offline', '--target', '-i', '--invert', '--prefix', '--no-dedupe', '--duplicates', '-d', '--charset', '-f', '--format', '-e', '--edges')
    
    uninstall = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--frozen', '--locked', '--offline', '-p', '--package', '--bin', '--root')
    
    update = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--manifest-path', '--frozen', '--locked', '--offline', '-p', '--package', '--aggressive', '--recursive', '--precise', '--dry-run')
    
    vendor = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--manifest-path', '--frozen', '--locked', '--offline', '-s', '--sync', '--no-delete', '--respect-source-config', '--versioned-dirs')
    
    version = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--frozen', '--locked', '--offline')
    
    yank = @('-h', '--help', '-v', '--verbose', '-q', '--quiet', '--color', '--frozen', '--locked', '--offline', '--version', '--undo', '--index', '--token', '--registry')
}

# Aliases
$script:CargoOptions['b'] = $script:CargoOptions['build']
$script:CargoOptions['c'] = $script:CargoOptions['check']
$script:CargoOptions['d'] = $script:CargoOptions['doc']
$script:CargoOptions['r'] = $script:CargoOptions['run']
$script:CargoOptions['t'] = $script:CargoOptions['test']
$script:CargoOptions['rm'] = $script:CargoOptions['remove']

# Register the argument completer
Register-ArgumentCompleter -Native -CommandName 'cargo' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    
    $elements = $commandAst.CommandElements
    $completions = @()
    
    # Find the subcommand
    $subcommand = $null
    $subcommandIndex = -1
    $afterDoubleDash = $false
    
    for ($i = 1; $i -lt $elements.Count; $i++) {
        $element = $elements[$i].Extent.Text
        
        if ($element -eq '--') {
            $afterDoubleDash = $true
            break
        }
        
        if ($element -notmatch '^[-+]') {
            $subcommand = $element
            $subcommandIndex = $i
            break
        }
    }
    
    # Get the previous element
    $previousElement = $null
    if ($elements.Count -gt 1) {
        $previousElement = $elements[-2].Extent.Text
    }
    
    # If after --, provide file completion
    if ($afterDoubleDash) {
        # Return empty to trigger default file completion
        return
    }
    
    # Handle specific previous elements
    switch ($previousElement) {
        '--vcs' {
            $completions = $script:CargoOptions.VCS
        }
        '--color' {
            $completions = $script:CargoOptions.Color
        }
        '--message-format' {
            $completions = $script:CargoOptions.MessageFormat
        }
        '--manifest-path' {
            # Return empty to trigger file completion for .toml files
            return
        }
        '--bin' {
            $completions = Get-BinNames
        }
        '--test' {
            $completions = Get-TestNames
        }
        '--bench' {
            $completions = Get-BenchNames
        }
        '--example' {
            $completions = Get-Examples
        }
        '--target' {
            $completions = Get-Targets
        }
        { $_ -in @('--target-dir', '--path') } {
            # Return empty to trigger directory completion
            return
        }
        'help' {
            $completions = Get-CargoCommands
        }
        default {
            # If we have a subcommand, complete its options
            if ($subcommand) {
                # Handle special case for "report future-incompat"
                if ($subcommand -eq 'report' -and $previousElement -match 'future-incompat') {
                    $optionKey = 'report future-incompat'
                }
                else {
                    $optionKey = $subcommand
                }
                
                if ($script:CargoOptions.ContainsKey($optionKey)) {
                    $completions = $script:CargoOptions[$optionKey]
                }
                else {
                    # Try to complete with cargo-subcommand if available
                    $cargoSubcommand = "cargo-$subcommand"
                    if (Get-Command $cargoSubcommand -ErrorAction SilentlyContinue) {
                        # Let the subcommand handle its own completion
                        return
                    }
                    # Otherwise, return empty for file completion
                    return
                }
            }
            # No subcommand yet
            elseif ($wordToComplete -match '^-') {
                $completions = $script:CargoOptions.NoCmdOptions
            }
            elseif ($wordToComplete -match '^\+') {
                $completions = Get-Toolchains
            }
            else {
                $completions = Get-CargoCommands
            }
        }
    }
    
    # Filter and return completions
    $completions | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
