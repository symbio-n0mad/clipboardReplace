param (
    [Alias("folder1", "searchFolder")]
    [string]$searchFolderPath = "",   
    [Alias("folder2", "replaceFolder")]          
    [string]$replaceFolderPath = "",
    [Alias("file1", "searchFile")]
    [string]$searchFilePath = "",   
    [Alias("outputName", "saveFileName", "outName", "saveAs")]
    [string]$fileName = "",   
    [Alias("file2", "replaceFile")]          
    [string]$replaceFilePath = "",
    [Alias("text1", "search", "find", "findText")]
    [string]$searchText = "",   
    [Alias("text2", "replace", "displace", "substitute")]          
    [string]$replaceText = "",
    [Alias("showHelp", "h", "hint", "usage")]          
    [switch]$Help = $false,
    [Alias("caseInsensitive", "caseMattersNot", "ignoreCase", "ic")]          
    [switch]$ci = $false,
    [Alias("toFile", "f", "save", "write", "fileOut")]          
    [switch]$fileOutput = $false,
    [Alias("standard", "s", "normal", "n")]          
    [switch]$standardSettings,  
    [Alias("regularExpressions", "RegEx", "advanced", "regExP")]          
    [switch]$r,  
    [Alias("termOpen", "stay", "windowPersist", "confirm", "p")]          
    [switch]$persist = $false,  
    [Alias("grep", "ext", "e", "x", "extract")]          
    [switch]$extractMatch  
)
if ($standardSettings) {
    Write-Host "Standard settings activated:"
    $searchFilePath = "SEARCH.txt"
    $replaceFilePath = "REPLACE.txt"
    Write-Host "File for search patterns is $searchFilePath"
    Write-Host "File for replacement patterns is $replaceFilePath"
}
if (
    $Help.IsPresent -or
    (
        ($searchFolderPath.Trim().Length -eq 0) -and
        ($searchFilePath.Trim().Length -eq 0) -and
        ($searchText.Trim().Length -eq 0)
    )
) {
    Write-Host "Usage:"
    Write-Host "  -searchFolderPath   Path to folder with search files"
    Write-Host "  -searchFilePath     File with lines to search for"
    Write-Host "  -searchText         Text to search for"
    Write-Host "or"
    Write-Host "  -standard           Load the standard filenames SEARCH.txt and REPLACE.txt"
    Write-Host ""
    Write-Host "  -r / -RegEx         Permit use of Regular Expressions"
    Write-Host "  -x / -grep          Search and extract patterns"
    Write-Host ""

    Write-Host "  -persist / -p       After running the script, terminal will wait for confirmation"
    Start-Sleep -Milliseconds 1250
    # Read-Host -Prompt "Press Enter to end program!"
    exit
}

# Read text from clipboard
$clipboardText = Get-Clipboard

# Read file contents explicitly as arrays, but only if they exist
if (-not [string]::IsNullOrWhiteSpace($searchFilePath)) {
    $searchLines = @(Get-Content -Path $searchFilePath)
}
if (-not [string]::IsNullOrWhiteSpace($searchText)) {
    $searchLines += $searchText
}

if (-not [string]::IsNullOrWhiteSpace($replaceFilePath)) {
    $replaceLines = @(Get-Content -Path $replaceFilePath)
}
if (-not [string]::IsNullOrWhiteSpace($replaceText)) {
    $replaceLines += $replaceText
}

if (-not $extractMatch) { # If only extraction is wanted then no check is needed
    if ($searchLines.Count -ne $replaceLines.Count) {
        Write-Error "Error: Line count of provided files not usable, check entries!"
        Read-Host -Prompt "Press enter to end program"
        exit
    }
}
if (-not [string]::IsNullOrWhiteSpace($searchFilePath) -and
    -not [string]::IsNullOrWhiteSpace($replaceFilePath)
    ) {
    while ($replaceLines.Count -lt $searchLines.Count) { 
        $replaceLines += '' # because empty lines are not recognized as lines, array will be filled with empty entries here for every empty line
    }
}
else {
    $searchLines = @($searchText)
}

#You Search for a Search?
#or just a search?

if ($extractMatch) {
    # Match extraction
    # Printing line nr of match, match itself, CRLF, full line, CRLF 
    # Define search string as empty variable
    $pattern = ""
    #$r = $true   # true = Regex, false = wörtlich # will be set by argument at script-calling-time

    # Text splitting to lines
    $lines = $clipboardText -split "`r?`n"

    for ($j = 0; $j -lt $searchLines.Count; $j++) {

        $pattern = $searchLines[$j]
        # Check, for content of $searchText
        #newstuff
        # if (-not [string]::IsNullOrWhiteSpace($searchText)) {
        #     $pattern = $searchText
        #     $j--
        #     $searchText = ""
        # }
        #newstuff end

        # Iterate lines
        for ($i = 0; $i -lt $lines.Length; $i++) {
            $lineNumber = $i + 1
            $line = $lines[$i]

            if ($ci) {
                if ($r) {
                    # Regex-search
                    foreach ($m in [regex]::Matches($line, $pattern)) {
                        Write-Output "${lineNumber}: $($m.Value)"  # Match 
                        Write-Output "${lineNumber}: $line"        # Full line
                        Write-Output ""                            # empty line/CRLF
                    }
                } else {
                    # Literal search
                    if ($line -like "*$pattern*") {
                        Write-Output "${lineNumber}: $pattern"    # Match 
                        Write-Output "${lineNumber}: $line"       # Full line
                        Write-Output ""                           # CRLF
                    }
                }
            }
            else {
                if ($r) {
                    # Regex-search (case-sensitive)
                    foreach ($m in [regex]::Matches($line, $pattern, [System.Text.RegularExpressions.RegexOptions]::None)) {
                        Write-Output "${lineNumber}: $($m.Value)"  # Match 
                        Write-Output "${lineNumber}: $line"        # Full line
                        Write-Output ""                            # empty line/CRLF
                    }
                } else {
                    # Literal search (case-sensitive)
                    if ($line.Contains($pattern)) {
                        Write-Output "${lineNumber}: $pattern"    # Match 
                        Write-Output "${lineNumber}: $line"       # Full line
                        Write-Output ""                           # CRLF
                    }
                }

            }
        }
    }
    #END-NEW-TEST
}


# Process line by line
if ($replaceLines -ne $null -and $replaceLines.Count -gt 0 -and $searchLines -ne $null -and $searchLines.Count -gt 0) {  # Only runs if search/replaceLines-Array is existing and has content
    if ($r) {
        for ($i = 0; $i -lt $searchLines.Count; $i++) {
            $searchText = $searchLines[$i]
            $replaceText = $replaceLines[$i]
            if ($replaceText -eq '') {
                # Lösche $searchText aus $clipboardText
                if ($ci) {
                    $clipboardText = $clipboardText -replace $searchText, ''
                }
                else {
                    $clipboardText = $clipboardText -creplace $searchText, ''
                }
            } else {
                if ($ci) {
                    # Ersetze $searchText durch $replaceText
                    $clipboardText = $clipboardText -replace $searchText, $replaceText
                }
                else {
                    $clipboardText = $clipboardText -creplace $searchText, $replaceText
                }
            }
}
    }
    else {
        for ($i = 0; $i -lt $searchLines.Count; $i++) {
            $searchForText = $searchLines[$i]
            $replaceText = $replaceLines[$i]
            if ($replaceText -eq '') {
                # if ($ci) {
                    #$clipboardText = $clipboardText -replace [regex]::Escape($searchForText), ''
                    $clipboardText = $clipboardText.Replace($searchForText, '')
                # }
                # else {
                    # #$clipboardText = $clipboardText.Replace($searchForText, '', [System.StringComparison]::Ordinal) # Not working, meethod is not overloaded
                # }
            } else {
                # if ($ci) {
                    #$clipboardText = $clipboardText -replace [regex]::Escape($searchForText), $replaceText
                    $clipboardText = $clipboardText.Replace($searchForText, $replaceText)
                # }
                # else {
                   #  #$clipboardText = $clipboardText.Replace($searchForText, $replaceText, [System.StringComparison]::Ordinal) # Not working, meethod is not overloaded
                # }
            }
        }
    }
}
if ($fileOutput) { # This runs if output as file is desired
    # Timestamp generation
    $timeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

    # Check, for content of $fileName
    if ([string]::IsNullOrWhiteSpace($fileName)) {
        # empty -> use generic name
        $fileName = "Output_$timeStamp.txt"
    } else {
        # Name provided? ok then use it!
        $extension = [System.IO.Path]::GetExtension($fileName)
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $fileName = "${baseName}_$timeStamp$extension"
    }

    # Save file
    $clipboardText | Out-File -FilePath $fileName -Encoding UTF8

    Write-Output "Datei gespeichert: $fileName"
}
else {
    Set-Clipboard -Value $clipboardText
}


Write-Host 'Clipboard successfully modified.'
if ($persist) {
    Read-Host -Prompt "Press enter to close this window!"
}
