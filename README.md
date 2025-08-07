# clipboardReplace
PowerShell Script Performing a Search and Replace Action on Content of Clipboard

Prior to usage two textfiles need to be prepared, they have to contain search phrases resp. replace phrases which will be processed correspondingly line by line. For every line in the search-file the found content will be replaced by corresponding line of the replace-file. Search and replace is performed line by line starting with the first line - literally (no RegEx allowed yet).

Expected filenames are SEARCH.txt and REPLACE.txt in the same directory (when running the script with the -standard flag). Alternative filenames may be provided as arguments to the script (-file1/-searchFile/-searchFilePath "FILENAME", -file2/-replaceFile/-replaceFilePath "FILENAME").
For basic grep functionality call script like this: <scriptname>.ps1 -grep -searchText "searchString"
