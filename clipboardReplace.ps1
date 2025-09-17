param (
    [Alias("folder1", "searchFolder")]
    [string]$searchFolderPath = "",   
    [Alias("folder2", "replaceFolder")]          
    [string]$replaceFolderPath = "",
    [Alias("file1", "searchFile")]
    [string]$searchFilePath = "",    
    [Alias("file2", "replaceFile")]          
    [string]$replaceFilePath = "",
    [Alias("text1", "search", "find", "findText")]
    [string]$searchText = "",   
    [Alias("text2", "replace", "displace", "substitute")]          
    [string]$replaceText = "",
    [Alias("showHelp", "h", "hint", "usage")]          
    [switch]$Help = $false,
    [Alias("caseInsensitive", "caseMattersNot", "ignoreCase", "ic", "i")]          
    [switch]$ci = $false,
    [Alias("toFile", "f", "save", "write", "w", "fileOut", "toOutput")]          
    [switch]$fileOutput = $false,
    [Alias("outputName", "saveFileName", "outName", "saveAs", "o", "out", "output")]
    [string]$fileName = "",  
    [Alias("standard", "s", "normal", "n", "default")]          
    [switch]$standardSettings,  
    [Alias("regularExpressions", "regEx", "advanced", "regExP")]          
    [switch]$r,  
    [Alias("termOpen", "stay", "windowPersist", "confirm", "p")]          
    [switch]$persist = $false,  
    [Alias("grep", "ext", "e", "x", "extract")]          
    [switch]$extractMatch  
)

function set-Standard() {
    # $searchFilePath = $null
    # $replaceFilePath = $null
    # $searchFolderPath = $null
    # $replaceFolderPath = $null

    # Standard paths
    $searchFile = ".\SEARCH.txt"
    $replaceFile = ".\REPLACE.txt"
    $searchFolder = ".\SEARCH\"
    $replaceFolder = ".\REPLACE\"

    # Check existence
    $filesExist = (Test-Path $searchFile -PathType Leaf) -and (Test-Path $replaceFile -PathType Leaf)
    $foldersExist = (Test-Path $searchFolder -PathType Container) -and (Test-Path $replaceFolder -PathType Container)

    # Conditional assignment
    if ($filesExist) {
        $script:searchFilePath = $searchFile
        $script:replaceFilePath = $replaceFile
        Write-Host "File for search patterns is $searchFilePath"
        Write-Host "File for replacement patterns is $replaceFilePath"
    }
    if ($foldersExist) {
        $script:searchFolderPath = $searchFolder
        $script:replaceFolderPath = $replaceFolder
        Write-Host "Folder for search patterns is $searchFolderPath"
        Write-Host "Folder for replacement patterns is $replaceFolderPath"
    }
    if (!($filesExist) -and -Not($foldersExist)) {
        Write-Error "Neither the required files nor the required folders exist. Please check the paths."
        exit
    }

    # Return object
    # return [PSCustomObject]@{
    #     SearchFilePath   = $searchFilePath
    #     ReplaceFilePath  = $replaceFilePath
    #     SearchFolderPath = $searchFolderPath
    #     ReplaceFolderPath = $replaceFolderPath
    # }
}

function show-Helptext() {
    Write-Host "This PowerShell script is intended to apply basic search (and replace) actions to the content of the clipboard. Search/Replace strings may not only be provided as CLI arguments, but also in the form of lists as predefined files/folders with suitable content."
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  -searchFolderPath   Path to folder with search files as string"
    Write-Host "  -searchFilePath     Path to file with lines to search for as string"
    Write-Host "  -searchText         String to search for"
    Write-Host "and corresponding"
    Write-Host "  -replaceFolderPath   Path to folder with replace files as string"
    Write-Host "  -replaceFilePath     Path to file with replacement lines as string"
    Write-Host "  -replaceText         Replacement string"
    Write-Host "or"
    Write-Host "  -s / -standardSettings           Load the standard file/folder names SEARCH.txt and REPLACE.txt resp. SEARCH\ and REPLACE\"
    Write-Host "further"
    Write-Host "  -r / -RegEx         Permit use of Regular Expressions"
    Write-Host "  -x / -grep          Search and extract patterns (cancels replacement)"
    Write-Host "  -i / -ignoreCase    Ignore case while searching"
    Write-Host ""
    Write-Host "  -w / -fileOutput    Write to file, not clipboard"
    Write-Host "  -o / -saveAs        Provide output filename as string"
    Write-Host ""
    Write-Host "  -p / -persist       After running the script, terminal will wait for confirmation"
}

function check-Folder {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Check whether path is a folder
    if (-not (Test-Path $Path -PathType Container)) {
        return $false
    }

    # To accept relative or absolute paths
    $fullPath = Convert-Path $Path

    # Call top layer of files
    $files = Get-ChildItem -Path $fullPath -File

    # Check for files
    if ($files.Count -eq 0) {
        return $false
    }

    # Check for file content (size > 0)
    foreach ($file in $files) {
        if ($file.Length -eq 0) {
            return $false
        }
    }

    return $true
}


# Read text from clipboard
$clipboardText = Get-Clipboard
$clipboardUnchanged = Get-Clipboard

if ([string]::IsNullOrWhiteSpace($clipboardText)) {
    "No clipboard available. Nothing to do!"
    exit
}

if ($standardSettings) {
    set-Standard
}

if (
    $Help.IsPresent -or  # Help flag provided or
    (
        ($searchFolderPath.Trim().Length -eq 0) -and    # No folder         or
        ($searchFilePath.Trim().Length -eq 0) -and      # No file           or
        ($searchText.Trim().Length -eq 0)               # No search text    provided
    )
) {
    show-Helptext
    Start-Sleep -Milliseconds 750
    # Read-Host -Prompt "Press Enter to end program!"
    exit
}


# Read file contents explicitly as arrays, but only if they exist
if (-not [string]::IsNullOrWhiteSpace($searchFilePath)) {
    $searchLines = @(Get-Content -Path $searchFilePath)
}
if (-not [string]::IsNullOrWhiteSpace($searchText)) {
    $searchLines += ,$searchText  # So that $searchLines will be an array
}

if (-not [string]::IsNullOrWhiteSpace($replaceFilePath)) {
    $replaceLines = @(Get-Content -Path $replaceFilePath)  # Urgent need of arrays: @( )
}
if (-not [string]::IsNullOrWhiteSpace($replaceText)) {
    $replaceLines += ,$replaceText
}

if ($extractMatch) {
    # Match extraction: extract matches
    # Printing line nr of match, match itself, CRLF, full line, CRLF 

    # Define search string as empty variable
    $pattern = ""
    # Text splitting to lines
    $lines = $clipboardText -split "`r?`n"

    for ($j = 0; $j -lt $searchLines.Count; $j++) {
        $pattern = $searchLines[$j]

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
}
else {  # Else => if (-not $extractMatch) 
    # if ($searchLines.Count -ne $replaceLines.Count) {
    if ($searchLines.Count -lt $replaceLines.Count) {  # Search terms being < replace terms is impossible
        Write-Error "Error: Line count of provided files not usable, check entries!"
        Read-Host -Prompt "Press enter to end program"
        exit
    }
}

if (-not [string]::IsNullOrWhiteSpace($searchFilePath) -and
    -not [string]::IsNullOrWhiteSpace($replaceFilePath)  # Both need to exist
    ) {
    while ($replaceLines.Count -lt $searchLines.Count) {  # Filling replace terms to amount of search terms (possible because replace terms are assumed empty for missing lines)
        $replaceLines += '' # because empty lines are not recognized as lines, array will be filled with empty entries here for every empty line
    }
}
else {
    #$searchLines = @($searchText)
}

# Process line by line
if ($null -ne $replaceLines -and $replaceLines.Count -gt 0 -and $null -ne $searchLines -and $searchLines.Count -gt 0) {  # Only runs if search/replaceLines-Array is existing and has content
    if ($r) {
        for ($i = 0; $i -lt $searchLines.Count; $i++) {
            $searchText = $searchLines[$i]
            $replaceText = $replaceLines[$i]
            if ($replaceText -eq '') {
                # Delete $searchText from $clipboardText
                if ($ci) {
                    $clipboardText = $clipboardText -replace $searchText, ''
                }
                else {
                    $clipboardText = $clipboardText -creplace $searchText, ''
                }
            } else {
                if ($ci) {
                    # Replace $searchText by $replaceText
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
                if ($ci) {
                    $clipboardText = $clipboardText -replace [regex]::Escape($searchForText), ''
                    #$clipboardText = $clipboardText.Replace($searchForText, '')
                }
                else {
                    # #$clipboardText = $clipboardText.Replace($searchForText, '', [System.StringComparison]::Ordinal) # Not working, meethod is not overloaded
                    $clipboardText = $clipboardText.Replace($searchForText, '')
                }
            } else {
                if ($ci) {
                    $clipboardText = $clipboardText -replace [regex]::Escape($searchForText), $replaceText
                    #$clipboardText = $clipboardText.Replace($searchForText, $replaceText)
                }
                else {
                   #  #$clipboardText = $clipboardText.Replace($searchForText, $replaceText, [System.StringComparison]::Ordinal) # Not working, meethod is not overloaded
                   $clipboardText = $clipboardText.Replace($searchForText, $replaceText)
                }
            }
        }
    }
}

# "`$searchFolderPath:"
# $searchFolderPath
# if (-not [string]::IsNullOrWhiteSpace($replaceFolderPath)) {
#     "replaceFolderPath not empty"
# }
# if (-not [string]::IsNullOrWhiteSpace($searchFolderPath)) {
#     if (check-folder($searchFolderPath)) {
#         "Folder check successfull"
#     }
#     else {
#         "Folder check failed"
#     }
# }

if ($fileOutput) { # This runs if output as file is desired, therefore needs to be called at end
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
    Write-Output "Results saved in file: $fileName"
}
else {  # Else = no file output? -> then set clipboard content (only if it changed)
    if ( [String]::CompareOrdinal($clipboardUnchanged, $clipboardText) -ne 0 ){ #byte by byte comparision seems to help here - it works!
        # (Get-Clipboard -Raw)
        Set-Clipboard -Value $clipboardText
        Write-Host 'Clipboard successfully modified.'
    }
    else {
        Write-Host 'Clipboard text has not changed.'
    }
}

if ($persist) {
    Read-Host -Prompt "Press enter to close this window!"
}
