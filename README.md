# Install/Upgrade or Uninstall Apps Using WinGet

# Run Script - Most utilized as one usually only run this once.
  First, edit handle-winget.ps1 and its variable $Apps to your liking and save it. AppName needs to be an exact match.
  Apps available can be found at the WinGet repo: https://github.com/microsoft/winget-pkgs/tree/master/manifests or using WinGet Search <AppName>
  .\handle-winget.ps1
  
  The above will ask for what trigger you'd like to use (Install, Upgrade or Uninstall) and apply that accordingly to the Apps you've specified within the code.
  -----------------------------------------------------------
  
  You can also load the Function itself by only running the the following part from the script file. --> Function Handle-WinGet { ... }

# EXAMPLE
  The following example upgrades all apps located in the object "$Apps" and configures the WinGet settings to my preferred settings. 
   - ***Handle-WinGet -Trigger Upgrade -Apps $Apps -ConfigureSettings***
    
# EXAMPLE
  The following example will ask you for trigger input, either Install, Upgrade or Uninstall.  This will apply the command/trigger accordingly.
   - ***Handle-WinGet -Apps $Apps***
---------------------------------------------------
# NOTE
***I, take no responsibility for anything that could negatively impact you or the affected hardware/software. Recommended is to read the code before using it.***
