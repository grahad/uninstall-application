New-EventLog -LogName Application -Source "MME" -ErrorAction SilentlyContinue

# Check to see if script is running on a server.
$osName = Get-ComputerInfo -Property OsName
if($osName -like "*Server*") {
    Exit
}

try {
    $application = Get-WmiObject Win32_Product -filter "Name='UnwantedProgram'"
    if ($application) {
        $application.Uninstall()
        Write-EventLog -LogName Application -Source "MME" -Message "Application Removed" -EventId 0 -EntryType Information
    } else {
        Write-EventLog -LogName Application -Source "MME" -Message "Application not found" -EventId 1 -EntryType Information
    }
} catch {
    Write-EventLog -LogName Application -Source "MME" -Message "Unable to uninstall applcation`n $_" -EventId 2 -EntryType Error
}