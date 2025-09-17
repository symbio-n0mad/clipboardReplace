# clipboardReplace
PowerShell Script Performing a Search and Replace Action on Content of Clipboard

Prior to usage two textfiles may be prepared, they'd have to contain search phrases resp. replace phrases which will be processed correspondingly line by line. For every line in the search-file the found content will be replaced by corresponding line of the replace-file. Search and replace is performed literally line by line starting with the first line.

Instead of provision of files, also strings may be passed to the script accordingly (-searchText and -replaceText).

Usage of RegEx may be activated with the flag -r \ -regEx. Case-insensitivity is achieved with the flag -i \ -ignoreCase.

Expected filenames are SEARCH.txt and REPLACE.txt in the same directory (when running the script with the -standard flag). Alternative filenames may be provided as arguments to the script (-file1/-searchFile/-searchFilePath "FILENAME", -file2/-replaceFile/-replaceFilePath "FILENAME").
For basic grep functionality call script like this: clipboardReplace.ps1 -grep -searchText "searchString"

Do you want the terminal to stay open, waiting for confirmation? Use the -persist (or -termOpen, -stay, -windowPersist, -confirm, -p) flag at calling-time.
Instead of clipboard modification, also a file may be produced as output (-w \ -fileOutput to switch on file output, -o \ -saveAs to optionally provide a filename).

The flag -h \ -usage will print a short overview over flags and usage.
