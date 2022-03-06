function Get-SpecialFolder(
    [ValidateSet(
        'MyDocuments', 
        'MyMusic', 
        'MyPictures', 
        'MyVideos', 
        'Desktop', 
        'ApplicationData', 
        'CommonApplicationData', 
        'LocalApplicationData', 
        'Personal', 
        'CommonDocuments', 
        'CommonMusic', 
        'CommonPictures', 
        'CommonVideos', 
        'CommonDesktopDirectory', 
        'Cookies', 
        'History', 
        'InternetCache', 
        'Recent', 
        'SendTo', 
        'StartMenu', 
        'Startup', 
        'System', '
        SystemX86', 
        'Windows')] 
    $FolderName
) {
    $SpecialFolder = [System.Environment]::GetFolderPath($FolderName)
    if ( Test-Directory($SpecialFolder) ) {
        return $SpecialFolder
    }
    return $null
}
