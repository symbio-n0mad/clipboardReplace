param (
    [Alias("file1", "searchFile")]
    [string]$searchFilePath = "SEARCH.txt",   
    [Alias("file2", "replaceFile")]          
    [string]$replaceFilePath = "REPLACE.txt"                 
)

# Read content of files
$searchLines = @(Get-Content -Path $searchFilePath)
$replaceLines = @(Get-Content -Path $replaceFilePath)

while ($replaceLines.Count -lt $searchLines.Count) {
    $replaceLines += ''
}
if ($searchLines.Count -ne $replaceLines.Count) {
    Write-Error "Error: Line count of provided files not equal."
	Read-Host -Prompt "Press enter to end program!"
    exit
}

# Get text from clipboard
$clipboardText = Get-Clipboard

# Process line by line
for ($i = 0; $i -lt $searchLines.Count; $i++) {
    $searchText = $searchLines[$i]
    $replaceText = $replaceLines[$i]
    if ($replaceText -eq '') {
        #$clipboardText = $clipboardText -replace [regex]::Escape($searchText), ''
		    $clipboardText = $clipboardText.Replace($searchText, '')
    } else {
        #$clipboardText = $clipboardText -replace [regex]::Escape($searchText), $replaceText
		    $clipboardText = $clipboardText.Replace($searchText, $replaceText)
    }
}

Set-Clipboard -Value $clipboardText

Write-Host 'Clipboard successfully modified.'
Read-Host -Prompt "Press enter to close this window!"
