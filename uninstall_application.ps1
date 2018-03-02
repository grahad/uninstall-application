<#
.SYNOPSIS
Uninstalls application from workstation
.EXAMPLE
Running from command line:

powershell -executionPolicy bypass -NonInteractive -NoProfile -file ".\uninstall_application.ps1" -applicationName Foobar
EXIT /B %ERRORLEVEL%

.PARAMETER applicationName
The name of the applicatoin you would like to uninstall.
.PARAMETER logName
The name of the application log that you would like to use in windows event log aka Source.
#>
Param(
        [Parameter(Mandatory=$true)][string]$applicationName,
        [string]$logName='PSUninstall'
    )

New-EventLog -LogName Application -Source $logName -ErrorAction SilentlyContinue
Checkpoint-Computer -Description "Before powerhell script" -RestorePointType APPLICATION_INSTALL


# Check to see if script is running on a server.
$wmiStore = Get-WmiObject -Class Win32_OperatingSystem
$osName = $wmiStore.caption
if($osName -like "*Server*") {
    Exit
}

try {
    $application = Get-WmiObject Win32_Product -filter "Name='$applicationName'"
    if ($application) {
        $result = $application.Uninstall()
        Write-EventLog `
            -LogName Application `
            -Source $logName `
            -Message "Application: $applicationName, Removed`nReturn value: $($result.ReturnValue)" `
            -EventId 0 `
            -EntryType Information
    } else {
        Write-EventLog `
            -LogName Application `
            -Source $logName `
            -Message "Application: $applicationName, not found" `
            -EventId 1 `
            -EntryType Information
    }
} catch {
    Write-EventLog `
        -LogName Application `
        -Source $logName `
        -Message "Unable to uninstall applcation: $applicationName`n $_" `
        -EventId 2 `
        -EntryType Error
    Exit 1 #Exit out to command prompt with non 0
}