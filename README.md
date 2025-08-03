# clipboardReplace
PowerShell Script Performing a Search and Replace Action on Content of Clipboard

The prepared files are evaluated line by line. For every line in the search-file the found content will be replaced by corresponding line of the replace-file. Search and replace is performed line by line starting with the first line - literally (no RegEx allowed yet).

Expected filenames are SEARCH.txt and REPLACE.txt in the same directory. Alternative filenames may be provided by arguments to the script (-file1/-searchFile/-searchFilePath, -file2/-replaceFile/-replaceFilePath).
