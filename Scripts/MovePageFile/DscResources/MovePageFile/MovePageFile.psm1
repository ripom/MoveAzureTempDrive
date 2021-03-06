function Get-TargetResource 
{    
    [OutputType([System.Collections.Hashtable])] 
  param 
   (   
	[Parameter(Mandatory)] 
        [string]$TempDriveLetter

   ) 
   
        $returnValue = @{ 
           TempDriveLetter = $TempDriveLetter           
   }     
    $returnValue 
} 

function Set-TargetResource 
{   
   param 
    ( 
      [Parameter(Mandatory)] 
        [string]$TempDriveLetter   
    ) 
    #Change PageFile location

    $TempDriveLetter2 = $TempDriveLetter + ":"
    Set-WMIInstance -Class Win32_PageFileSetting -Arguments @{ Name = "$TempDriveLetter2\pagefile.sys"; MaximumSize = 0; }
    $global:DSCMachineStatus = 1                 
    
}


function Test-TargetResource 
{ 
    [OutputType([System.Boolean])]    
    param 
     ( 
      	[Parameter(Mandatory)] 
        [string]$TempDriveLetter
    ) 
    [System.Boolean]$result=$false

    $pf=gwmi win32_pagefilesetting

    if ($pf -ne $null)
    {
        $result=$true
    }

    return $result
} 


Export-ModuleMember -Function *-TargetResource 