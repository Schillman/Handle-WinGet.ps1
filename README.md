# Install/Upgrade or Uninstall Apps Using WinGet

# EXAMPLE
  The following example upgrades all apps located in the object "$Apps" and also configures the WinGet settings to my preferd settings. 
   - ***Handle-WinGet -Trigger Upgrade -Apps $Apps -ConfigureSettings***
    
# EXAMPLE
  The following example will ask you for a trigger input. Either Install, Upgrade or Uninstall and then apply command/trigger accordingly.
   - ***Handle-WinGet -Apps $Apps***
