function Convert-ToUncompressedZip {
    <#
    .SYNOPSIS
    圧縮されたZIPファイルを無圧縮ZIPファイルに変換して置き換えます。

    .DESCRIPTION
    このコマンドレットは、既存の圧縮ZIPファイルを一度解凍し、
    無圧縮（ストア）形式で再度ZIPファイルを作成して元のファイルを置き換えます。
    7z.exeがPATHに通っている必要があります。

    .PARAMETER Path
    変換元のZIPファイルのパス。複数指定可能。

    .PARAMETER BackupDirectory
    元ファイルのバックアップ先ディレクトリ。
    指定しない場合はバックアップを作成しません。

    .PARAMETER Force
    確認なしで実行します。

    .EXAMPLE
    Convert-ToUncompressedZip -Path "C:\data\compressed.zip"
    compressed.zipを無圧縮ZIPに変換して置き換えます。

    .EXAMPLE
    Convert-ToUncompressedZip -Path "*.zip" -BackupDirectory "C:\backup"
    全てのZIPファイルを無圧縮に変換し、元ファイルをC:\backupにバックアップしてから置き換えます。

    .EXAMPLE
    Get-ChildItem -Filter "*.zip" -Recurse | Convert-ToUncompressedZip -Force
    サブディレクトリを含む全てのZIPファイルを無圧縮版で置き換えます。

    .EXAMPLE
    cuz *.zip -b ".\backup"
    カレントディレクトリの全ZIPファイルを変換し、backupフォルダにバックアップします。
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
                if (-not (Test-Path $_)) {
                    throw "ファイルが見つかりません: $_"
                }
                if ((Get-Item $_).Extension -ne '.zip') {
                    throw "ZIPファイルではありません: $_"
                }
                return $true
            })]
        [string[]]$Path,

        [Parameter()]
        [Alias('b')]
        [ValidateScript({
                if ($_ -and -not (Test-Path $_)) {
                    New-Item -ItemType Directory -Path $_ -Force | Out-Null
                }
                return $true
            })]
        [string]$BackupDirectory,

        [Parameter()]
        [Alias('f')]
        [switch]$Force
    )

    begin {
        # 7z.exeの検索
        $7zExe = Get-Command "7z.exe" -ErrorAction SilentlyContinue
        if (-not $7zExe) {
            # 7za.exeも試す
            $7zExe = Get-Command "7za.exe" -ErrorAction SilentlyContinue
        }
        
        if (-not $7zExe) {
            throw "7z.exeまたは7za.exeがPATHに見つかりません。7-Zipをインストールし、PATHに追加してください。"
        }

        $script:SevenZipExe = $7zExe.Path
        Write-Verbose "使用する7-Zip: $script:SevenZipExe"

        # 統計情報の初期化
        $script:totalFiles = 0
        $script:processedFiles = 0
        $script:totalOriginalSize = 0
        $script:totalNewSize = 0
    }

    process {
        foreach ($zipFile in $Path) {
            $script:totalFiles++
            
            try {
                # ファイル情報取得
                $sourceFile = Get-Item $zipFile
                $originalSize = $sourceFile.Length
                
                # ZIPファイルの整合性チェック（オプション）
                if ($sourceFile.Length -eq 0) {
                    Write-Warning "空のファイルです: $($sourceFile.Name)"
                    continue
                }
                
                # ファイルがロックされていないか確認
                try {
                    $stream = [System.IO.File]::Open($sourceFile.FullName, 'Open', 'Read', 'ReadWrite')
                    $stream.Close()
                }
                catch {
                    Write-Error "ファイルがロックされています: $($sourceFile.Name)"
                    continue
                }
                
                # 確認プロンプト（Force指定時はスキップ）
                if (-not $Force -and -not $PSCmdlet.ShouldProcess($sourceFile.FullName, "無圧縮ZIPで置き換え")) {
                    continue
                }

                Write-Host "`n処理中: $($sourceFile.Name)" -ForegroundColor Cyan
                
                # 一時ファイルパス
                $tempOutput = [System.IO.Path]::GetTempFileName()
                $tempDir = Join-Path $env:TEMP "UncompressedZip_$([System.Guid]::NewGuid())"
                
                try {
                    # 一時ディレクトリ作成
                    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

                    # 解凍
                    Write-Verbose "解凍中..."
                    $extractArgs = @(
                        'x',
                        "`"$($sourceFile.FullName)`"",
                        "-o`"$tempDir`"",
                        '-y',
                        '-bd'
                    )
                    
                    # エラー出力を取得
                    $extractOutput = & $script:SevenZipExe $extractArgs 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        $errorDetail = ($extractOutput | Where-Object { $_ -match 'Error:|Warning:' }) -join "`n"
                        if (-not $errorDetail) {
                            $errorDetail = $extractOutput -join "`n"
                        }
                        throw "解凍に失敗しました (終了コード: $LASTEXITCODE)`n詳細: $errorDetail"
                    }

                    # 無圧縮ZIPとして再圧縮
                    Write-Verbose "無圧縮ZIPを作成中..."
                    $compressArgs = @(
                        'a',
                        '-tzip',
                        '-mx0',
                        "`"$tempOutput`"",
                        "`"$tempDir\*`"",
                        '-bd'
                    )
                    
                    # エラー出力を取得
                    $compressOutput = & $script:SevenZipExe $compressArgs 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        $errorDetail = ($compressOutput | Where-Object { $_ -match 'Error:|Warning:' }) -join "`n"
                        if (-not $errorDetail) {
                            $errorDetail = $compressOutput -join "`n"
                        }
                        throw "圧縮に失敗しました (終了コード: $LASTEXITCODE)`n詳細: $errorDetail"
                    }

                    # 新しいファイルのサイズを取得
                    $newSize = (Get-Item $tempOutput).Length
                    $sizeChange = $newSize - $originalSize
                    $sizeChangePercent = [math]::Round(($sizeChange / $originalSize) * 100, 2)

                    # バックアップ作成（指定された場合）
                    $backupPath = $null
                    if ($BackupDirectory) {
                        $backupPath = Join-Path $BackupDirectory $sourceFile.Name
                        Copy-Item -Path $sourceFile.FullName -Destination $backupPath -Force
                        Write-Verbose "バックアップ作成: $backupPath"
                    }

                    # 元ファイルを置き換え
                    Remove-Item -Path $sourceFile.FullName -Force
                    Move-Item -Path $tempOutput -Destination $sourceFile.FullName -Force
                    
                    # 統計情報を更新
                    $script:processedFiles++
                    $script:totalOriginalSize += $originalSize
                    $script:totalNewSize += $newSize

                    # 結果表示
                    $originalMB = [math]::Round($originalSize / 1MB, 2)
                    $newMB = [math]::Round($newSize / 1MB, 2)
                    
                    if ($sizeChangePercent -gt 5) {
                        Write-Host "  完了: $originalMB MB → $newMB MB (${sizeChangePercent}% 増加)" -ForegroundColor Yellow
                    }
                    elseif ($sizeChangePercent -lt -5) {
                        Write-Host "  完了: $originalMB MB → $newMB MB (${sizeChangePercent}% 減少)" -ForegroundColor Green
                    }
                    else {
                        Write-Host "  完了: $originalMB MB → $newMB MB (${sizeChangePercent}% 変化)" -ForegroundColor Gray
                    }

                    # 結果オブジェクトを出力
                    [PSCustomObject]@{
                        File              = $sourceFile.FullName
                        OriginalSizeMB    = $originalMB
                        NewSizeMB         = $newMB
                        SizeChangePercent = $sizeChangePercent
                        BackupPath        = $backupPath
                    }

                }
                finally {
                    # クリーンアップ
                    if (Test-Path $tempDir) {
                        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
                    }
                    if (Test-Path $tempOutput) {
                        Remove-Item -Path $tempOutput -Force -ErrorAction SilentlyContinue
                    }
                }

            }
            catch {
                Write-Error "エラー ($($sourceFile.Name)): $_"
            }
        }
    }

    end {
        # サマリー表示
        if ($script:processedFiles -gt 0) {
            Write-Host "`n========== 処理結果 ==========" -ForegroundColor Cyan
            Write-Host "処理ファイル数: $script:processedFiles / $script:totalFiles"
            
            $totalOriginalMB = [math]::Round($script:totalOriginalSize / 1MB, 2)
            $totalNewMB = [math]::Round($script:totalNewSize / 1MB, 2)
            $totalChangePercent = [math]::Round((($script:totalNewSize - $script:totalOriginalSize) / $script:totalOriginalSize) * 100, 2)
            
            Write-Host "合計サイズ: $totalOriginalMB MB → $totalNewMB MB ($totalChangePercent% 変化)"
            
            if ($BackupDirectory) {
                Write-Host "バックアップ先: $BackupDirectory" -ForegroundColor DarkGray
            }
        }
    }
}
