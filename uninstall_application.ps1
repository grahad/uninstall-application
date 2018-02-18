New-EventLog -LogName Application -Source "LOGNAME" -ErrorAction SilentlyContinue

# Check to see if script is running on a server.
$osName = Get-ComputerInfo -Property OsName
if($osName -like "*Server*") {
    Exit
}

try {
    $application = Get-WmiObject Win32_Product -filter "Name='UnwantedProgram'"
    if ($application) {
        $application.Uninstall()
        Write-EventLog -LogName Application -Source "LOGNAME" -Message "Application Removed" -EventId 0 -EntryType Information
    } else {
        Write-EventLog -LogName Application -Source "LOGNAME" -Message "Application not found" -EventId 1 -EntryType Information
    }
} catch {
    Write-EventLog -LogName Application -Source "LOGNAME" -Message "Unable to uninstall applcation`n $_" -EventId 2 -EntryType Error
}