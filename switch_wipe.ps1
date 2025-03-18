# Define the COM port and baud rate
$comPort = "COM3"
$baudRate = 9600

# Open the serial port
$serialPort = new-Object System.IO.Ports.SerialPort $comPort, $baudRate, "None", 8, "One"
$serialPort.Open()

# Function to send commands to the switch and log output
function Send-Command {
    param (
        [string]$command
    )
    Write-Host "Sending command: $command"
    $serialPort.WriteLine($command)
    Start-Sleep -Seconds 1
    $response = $serialPort.ReadExisting()
    Write-Host "Response: $response"
    Add-Content -Path "C:\Logs\SwitchConfigLog.txt" -Value "Command: $command`nResponse: $response`n"
}

# Create log file
$logFile = "C:\Logs\SwitchConfigLog.txt"
if (-Not (Test-Path $logFile)) {
    New-Item -ItemType File -Path $logFile
}

# Log start of the process
Add-Content -Path $logFile -Value "Starting configuration wipe and reboot process at $(Get-Date)`n"

# Enter privileged mode
Send-Command "enable"
Send-Command "your_enable_password"

# Log the serial number of the device
Send-Command "show version | include Processor board ID"
$serialNumber = $serialPort.ReadExisting()
Add-Content -Path $logFile -Value "Serial Number: $serialNumber`n"

# Wipe the configuration
Send-Command "write erase"
Send-Command "confirm"

# Reload the switch
Send-Command "reload"
Send-Command "confirm"

# Log end of the process
Add-Content -Path $logFile -Value "Process completed at $(Get-Date)`n"

# Close the serial port
$serialPort.Close()

Write-Host "Configuration wiped and switch rebooted successfully."