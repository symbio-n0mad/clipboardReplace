# 📋 clipboardReplace.ps1

A lightweight PowerShell script for **search & replace operations** directly on your **clipboard content**.


- Supports **text files** (`SEARCH.txt`, `REPLACE.txt`) or **inline strings** as search and replace targets
- Optional **RegEx** (`-r`) and **case-insensitive** (`-i`) modes
- Includes a **grep-like search mode** (`-grep`) for quick text filtering 🔍 
- Can **output to file** instead of clipboard (`-w`, `-saveAs`)   

### 🧭 Examples
```powershell

# Basic use: Inline literal replacement
clipboardReplace.ps1 -searchText "foo" -replaceText "bar"

# Grep-like search
clipboardReplace.ps1 -grep -persist -searchText "pattern"

# RegEx and case-insensitive
clipboardReplace.ps1 -r -i -searchText "foo.*bar" -replaceText "baz"

# Write result to file (uses SEARCH.txt / REPLACE.txt)
clipboardReplace.ps1 -standard -fileOutput -saveAs "output.txt"
