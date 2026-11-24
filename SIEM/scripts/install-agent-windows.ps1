param(
    [Parameter(Mandatory=$true)][string]$ManagerIP
)
Invoke-WebRequest -Uri "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.9.2-1.msi" -OutFile "$env:TEMP\wazuh-agent.msi"
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$env:TEMP\wazuh-agent.msi`" /q WAZUH_MANAGER=`"$ManagerIP`" WAZUH_AGENT_GROUP=`"default`""
NET START WazuhSvc