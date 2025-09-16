
#Defining variables
#Defining paths
$downlaodsPath = "C:\Users\Lizard\Downloads"
$citrixExe = "C:\programFiles (x86)\Citrix\ICA Client\wfcrun32.exe"

#Define resolution based on VDI name (VDIs names are short names)
$resolutions = @{
    "VDI1" = @{H=1024; V=768}
    "VDI2" = @{H=1600; V=1200}
    "VDI3" = @{H=1024; V=768}
}

#Get lastest ICA file from downloads
$icaFile = Get-ChildItem -Path $downlaodsPath -Filter *.ica | Sort-Object LastWriteTime -Descending | Select-Object -First 1

If (-not $icaFile) {
    Write-Host "No ICA file found in Downloads folder."
    Exit
}

$icaPath = $icaFile.FullName
Write-Host "Found ICA file $icaPath"

#Read ICA file content
$content = Get-Content $icaPath

#Extract VDI name from ICA file
$vdiName = ($content | Select-String "Tile=").ToString().Split("=")[1]
Write-Host "VDi name detected $vdiName"

#Check if mapping exists
if ($resolutions.Conta($vdiName)) {
    $res = $resolutions[$vdiName]
    Write-Host "Applying resolution $($res.H)x$($res.V)"
}

#Replace or add TWIMode (Specifies whether or not to use seamless mode for the connection)
if ($content -match "^TWIMode=") {
    $content = $content -replace "^TWIMode=.*","TWIMode=Off"
Else
    $content += "TWIMode=Off"
}

#Replace or add ConnectionBar=0
if ($content -match "^ConnectionBar=") {
    $content = $content -replace "^ConnectionBar=.*","ConnectionBar=0"
Else
    $content += "ConnectionBar=0"
}

#Replace or add DesiredHRES (Horizontal Resolution in pixels)
if ($content -match "^DesiredHRES=") {
    $content = $content -replace "^DesiredHRES=.*","DesiredHRES=$($res.H)"
Else
    $content += "DesiredHRES=$($res.H)"
}

#Replace or add DesiredVRES (Vertical Resolution in pixels)
if ($content -match "^DesiredVRES=") {
    $content = $content -replace "^DesiredVRES=.*","DesiredVRES=$($res.V)"
Else
    $content += "DesiredVRES=$($res.V)"
}

#Replace or add DesktopScale
if ($content -match "^DesktopScale=") {
    $content = $content -replace "^DesktopScale=.*","DesktopScale=0"
Else
    $content += "DesktopScale=0"
}

#Replace or add ScreenPercent
if ($content -match "^ScreenPercent=") {
    $content = $content -replace "^ScreenPercent=.*","ScreenPercent=0"
Else
    $content += "ScreenPercent=0"
}

#Save modified ICA file
Set-Content $icaPath $content

#Launch Citrix VDI with modified ICA
$Start-Process -FilePath $citrixExe -ArgumentList "`"$icaPath`""