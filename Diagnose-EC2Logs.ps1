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
    # TODO: Simulate S3 download of zipped IIS log and extract
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
# 3. Parse log and filter for errors
# 4. Generate diagnostic report

#endregion