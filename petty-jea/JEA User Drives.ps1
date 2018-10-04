# Connect to the JEA endpoint
$MyJea = New-PSSession -ComputerName 'srv01' -ConfigurationName 'Demo\User2'

# Copy a file in the local folder to the remote machine.
# Note: you cannot specify the file name or subfolder on the remote machine. You must type "User:"
Copy-Item -Path .\MyFile.txt -Destination User: -ToSession $MyJea

# Copy the file back from the remote machine to your local machine
Copy-Item -Path User:\MyFile.txt -Destination . -FromSession $MyJea