#  clipboardReplace.ps1

A lightweight PowerShell script for **search & replace operations** directly on your **clipboard content**.


- Supports **text files** (`SEARCH.txt`, `REPLACE.txt`) or **inline strings** as search and replace targets
- Optional **RegEx** (`-r`) and **case-insensitive** (`-i`) modes
- Includes a **grep-like search mode** (`-grep`) for quick text filtering 🔍 
- Can **output to file** instead of clipboard (`-w`, `-saveAs`)
- Run with -h or -usage to see all available flags.

###  Examples
```powershell

# Basic use: Inline literal replacement
clipboardReplace.ps1 -searchText "foo" -replaceText "bar"

# Grep-like search
clipboardReplace.ps1 -grep -persist -searchText "pattern"

# RegEx and case-insensitive
clipboardReplace.ps1 -r -i -searchText "foo.*bar" -replaceText "baz"

# Write result to file (uses SEARCH.txt / REPLACE.txt)
clipboardReplace.ps1 -standard -fileOutput -saveAs "output.txt"
´´´
---

##  Tip: Run via Keyboard Shortcut (Windows)

For quick access, it's highly recommended to run the script via a **custom keyboard shortcut** in Windows.  
You can achieve this easily using a **desktop shortcut** that launches PowerShell with the correct arguments.

###  Setup Steps

1. **Create a Shortcut**
   - Right-click on your desktop → **New → Shortcut**  
   - For the location, enter something like:
     ```powershell
     powershell.exe -ExecutionPolicy Bypass -File "C:\Path\To\clipboardReplace.ps1"
     ```
     >  `-ExecutionPolicy Bypass` ensures the script runs without restrictions, even if PowerShell’s default policy is limited.

2. **Assign a Keyboard Shortcut**
   - Right-click the newly created shortcut → **Properties**
   - In the **Shortcut** tab, click inside the *Shortcut key* field and press your desired key combo (e.g. `Ctrl + Alt + R`)
   - Click **Apply** and **OK**

3. **Use It**
   - Now you can simply press your shortcut and run `clipboardReplace.ps1` instantly — perfect for quick clipboard transformations or grep-style searches on the fly.
---
