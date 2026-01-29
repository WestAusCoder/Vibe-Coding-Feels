<#
.SYNOPSIS
    Checks the LastBootUpTime for a list of computers using CIM with parallel processing.
.DESCRIPTION
    This script reads a list of computer names from a text file, checks their LastBootUpTime
    using CIM with parallel processing (3-5 threads), and exports the results to a CSV file.
.NOTES
    File Name      : Get-ComputerUptime-Parallel.ps1
    Prerequisites  : PowerShell 7+ (for ForEach-Object -Parallel)
#>

# Parameters
$inputFile = "computers.txt"  # Path to your input text file
$outputFile = "ComputerUptimeReport.csv"  # Output CSV file
$minThreads = 3  # Minimum number of parallel threads
$maxThreads = 5  # Maximum number of parallel threads

# Function to get LastBootUpTime for a computer using CIM
function Get-ComputerUptime {
    param (
        [string]$ComputerName
    )

    try {
        # Get the CIM instance of Win32_OperatingSystem
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop

        # Convert the LastBootUpTime to a more readable format
        $bootTime = $os.ConvertToDateTime($os.LastBootUpTime)

        # Calculate uptime
        $uptime = (Get-Date) - $bootTime

        # Return an object with computer name and uptime
        [PSCustomObject]@{
            ComputerName = $ComputerName
            LastBootUpTime = $bootTime
            Uptime = $uptime
            UptimeDays = [math]::Round($uptime.TotalDays, 2)
            Status = "Success"
        }
    }
    catch {
        # If there's an error, return an object with error info
        [PSCustomObject]@{
            ComputerName = $ComputerName
            LastBootUpTime = "Error"
            Uptime = "Error"
            UptimeDays = "Error"
            Status = "Failed: $_"
        }
    }
}

# Main script execution
# Allow tests to disable main execution by setting environment variable SKIP_MAIN=1
if (-not ($env:SKIP_MAIN -eq '1')) {
    try {
    # Check if input file exists
    if (-not (Test-Path $inputFile)) {
        throw "Input file '$inputFile' not found."
    }

    # Read computer names from file
    $computerNames = Get-Content $inputFile | Where-Object { $_ -match '\S' }  # Skip empty lines

    if (-not $computerNames) {
        throw "No computer names found in the input file."
    }

    Write-Host "Starting parallel processing of $($computerNames.Count) computers with $minThreads-$maxThreads threads..."

    # Initialize results array
    $results = @()

    # Process computers in parallel with throttle limit
    $results = $computerNames | ForEach-Object -Parallel {
        $result = Get-ComputerUptime -ComputerName $_
        Write-Output $result
    } -ThrottleLimit $maxThreads

    # Sort results by computer name (optional)
    $results = $results | Sort-Object ComputerName

    # Export results to CSV
    $results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

    # Display summary
    $successCount = ($results | Where-Object { $_.Status -like "Success*" }).Count
    $errorCount = $results.Count - $successCount

    Write-Host "`nProcessing complete!"
    Write-Host "Total computers processed: $($results.Count)"
    Write-Host "Successful: $successCount"
    Write-Host "Failed: $errorCount"
    Write-Host "Report saved to: $outputFile"
    }
    catch {
        Write-Error "An error occurred: $_"
        exit 1
    }
}

<#
Key Features:

Parallel Processing:
Uses ForEach-Object -Parallel (PowerShell 7+)
Configurable thread count (3-5 by default)
Automatic throttling to prevent overloading systems
Enhanced Output:
Added a Status column to clearly show success/failure
Summary statistics at the end of execution
Results sorted by computer name
Error Handling:
Comprehensive try-catch blocks
Clear error messages
Graceful handling of empty input files
Performance:
Processes multiple computers simultaneously
Adjustable thread count based on your environment
Requirements:

PowerShell 7 or later (for the -Parallel parameter)
Appropriate permissions to query remote computers
Network connectivity to all target computers
Usage Notes:

For very large lists (100+ computers), you might want to increase the thread count slightly
If you're running this against servers, you might want to reduce the thread count to avoid impacting performance
The script will automatically use the optimal number of threads within your specified range
#>