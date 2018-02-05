configuration MoveAzureTempDrive
{
    param(
		[Parameter(Mandatory)] 
        [string]$TempDriveLetter
    )

    Import-DscResource -ModuleName MovePageFile, xComputerManagement

    Node localhost 
    {

       LocalConfigurationManager 
       {
           RebootNodeIfNeeded = $True
       }      
               
        Script DisablePageFile
        {
        
            GetScript  = { @{ Result = "" } }
            TestScript = { 
               $pf=gwmi win32_pagefilesetting
               #There's no page file so okay to enable on the new drive
               if ($pf -eq $null)
               {
                    return $true
               }
               #Page file is still on the D drive
               if ($pf.Name.ToLower().Contains('d:'))
               {
                    return $false
               }

               else
               {
                    return $true
               }
            
            }
            SetScript  = {
                #Change temp drive and Page file Location 
                gwmi win32_pagefilesetting
                $pf=gwmi win32_pagefilesetting
                $pf.Delete()
                Restart-Computer -Force
            }
           
        }
        Script ChangeTempDriveLetter
        {
        
            GetScript  = { @{ Result = "" } }
            TestScript =  { 
               $TempDriveLetter2 = $using:TempDriveLetter + ":"
               $drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'D:' and Label = 'Temporary Storage'"
               #There is no disk with new drive letter
               if ($drive -ne $null)
               {
                    return $false
               }
               else
               {
                    return $true
               }
            
            }
            SetScript  = {
                $TempDriveLetter2 = $using:TempDriveLetter + ":"
                $drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'D:' and Label = 'Temporary Storage'"
                Set-WMIInstance -input $drive -Arguments @{DriveLetter = "$TempDriveLetter2"}|Out-File -FilePath 'c:\packages\MoveAzureTempDrive-log.txt' -Append
            }
            DependsOn = "[Script]DisablePageFile"
           
        }

        MovePageFile MovePageFile
       {
           TempDriveLetter = $TempDriveLetter
           DependsOn = "[Script]ChangeTempDriveLetter"        
       }
      
	}
}


