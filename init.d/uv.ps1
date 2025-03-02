if (-not (Test-Command uv)) {
    return
}

$env:UV_CACHE_DIR = "d:\cache\uv"
