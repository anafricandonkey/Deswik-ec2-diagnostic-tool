<#
.SYNOPSIS
    Diagnose HTTP 500 errors on an EC2-hosted IIS instance.

.DESCRIPTION
    Automates the initial triage steps when an EC2 instance running IIS returns
    HTTP 500 errors. Mocks the AWS interactions (EC2 state query, S3 log download)
    and parses the IIS log to extract error timestamps and produce a summary.

.PARAMETER InstanceId
    EC2 Instance ID to investigate (e.g., i-0a1b2c3d4e5f67890).

.EXAMPLE
    .\Diagnose-EC2Logs.ps1 -InstanceId "i-0a1b2c3d4e5f67890""
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$InstanceId
)

#region --- Functions ---

function Get-MockInstanceState {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$InstanceId
    )

    # Validate EC2 instance ID format: i- followed by exactly 17 hex characters
    if ($InstanceId -notmatch '^i-[0-9a-fA-F]{17}$') {
        throw "Invalid EC2 Instance ID format: '$InstanceId'. Expected format: i- followed by 17 hex characters (e.g., i-0a1b2c3d4e5f67890)."
    }

    Write-Verbose "Querying EC2 instance state for $InstanceId..."

    [PSCustomObject]@{
        InstanceId       = $InstanceId
        State            = 'running'
        InstanceType     = 't3.medium'
        AvailabilityZone = 'ap-southeast-2a'
        LaunchTime       = [datetime]'2026-02-19T08:30:00Z'
        PrivateIpAddress = '10.0.0.50'
    }
}

function Get-LogFromS3 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$InstanceId,

        [Parameter(Mandatory)]
        [string]$LogFileName
    )

    $tempDir = Join-Path $env:TEMP "EC2Diagnostics_$InstanceId"
    $zipPath = Join-Path $tempDir "$LogFileName.zip"
    $extractPath = Join-Path $tempDir "Extracted"

    # Clean up any previous run
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    New-Item -Path $extractPath -ItemType Directory -Force | Out-Null

    # Locate the log file relative to the script
    $sourceLog = Join-Path $PSScriptRoot $LogFileName
    if (-not (Test-Path $sourceLog)) {
        throw "Log file not found: '$sourceLog'."
    }

    Write-Verbose "Simulating S3 download of $LogFileName.zip to $tempDir..."

    # Simulate the S3 download by zipping and extracting the local log file
    Compress-Archive -Path $sourceLog -DestinationPath $zipPath -Force
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    $extractedFile = Get-ChildItem -Path $extractPath -File | Select-Object -First 1
    if (-not $extractedFile) {
        throw "Zip extraction produced no files."
    }

    Write-Verbose "Log extracted to $($extractedFile.FullName)"
    $extractedFile.FullName
}
function Read-IISLog {
    # TODO: Parse W3C log format, skip comments, filter HTTP 500 entries
}

function Write-DiagnosticReport {
    # TODO: Output formatted summary to console
}

#endregion

#region --- Main ---

# 1. Validate input and query instance state
$instanceState = Get-MockInstanceState -InstanceId $InstanceId
Write-Verbose "Instance $InstanceId is $($instanceState.State)"

# 2. Retrieve log file from S3
$logPath = Get-LogFromS3 -InstanceId $InstanceId -LogFileName 'mockIISLog.txt'
Write-Verbose "Log file ready at $logPath"

# 3. Parse log and filter for errors

# 4. Generate diagnostic report

#endregion