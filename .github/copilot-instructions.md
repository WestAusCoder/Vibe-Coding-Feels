# AI Coding Agent Instructions for Vibe-Coding-Feels

## Project Overview
This is a PowerShell-focused repository for system administration utilities. The primary pattern demonstrated is parallel processing of remote system operations using PowerShell 7+ features.

## Key Architecture Patterns
- **Parallel Processing**: All scripts use `ForEach-Object -Parallel` with configurable thread throttling (3-5 threads by default)
- **CIM-based Operations**: Uses `Get-CimInstance` instead of WMI for better performance and reliability
- **Structured Error Handling**: Comprehensive try-catch blocks with status tracking
- **CSV Export Pattern**: Consistent output format with UTF-8 encoding and `NoTypeInformation`

## Critical Development Workflows
- **PowerShell 7+ Required**: All scripts require PowerShell 7+ for the `-Parallel` parameter
- **Execution Pattern**: Always include parameter validation, file existence checks, and summary statistics
- **Error Handling**: Return structured objects with Status field (Success/Failed) for all operations
- **Output Format**: Use `Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8`

## Project-Specific Conventions
- **Input Files**: Always expect text files with computer names (one per line, skip empty lines)
- **Thread Management**: Use configurable `$minThreads` and `$maxThreads` variables
- **Status Tracking**: Include Status, LastBootUpTime, Uptime, UptimeDays in output objects
- **Summary Reporting**: Always display success/failure counts and output file location

## File Structure Patterns
```
PowerShell Scripts/
└── [FeatureName]/
    ├── [ScriptName].ps1    # Main script with full documentation
    ├── computers.txt      # Input file (empty by default)
    └── [OutputName].csv   # Generated output file
```

## Integration Points
- **Remote Systems**: Requires appropriate permissions and network connectivity to target computers
- **Performance Considerations**: Thread count should be adjusted based on target system load
- **Error Recovery**: Script continues processing even if individual computers fail

## Code Quality Standards
- **Documentation**: Include comprehensive .SYNOPSIS, .DESCRIPTION, and .NOTES sections
- **Parameter Validation**: Always validate input files and computer lists
- **Error Messages**: Provide clear, actionable error messages
- **Performance**: Use CIM operations instead of legacy WMI methods

## Example Pattern from Get-Uptime.ps1
```powershell
# Parallel processing with throttle limit
$results = $computerNames | ForEach-Object -Parallel {
    $result = Get-ComputerUptime -ComputerName $_
    Write-Output $result
} -ThrottleLimit $maxThreads

# Structured error handling
[PSCustomObject]@{
    ComputerName = $ComputerName
    Status = "Success" # or "Failed: $_"
}
```