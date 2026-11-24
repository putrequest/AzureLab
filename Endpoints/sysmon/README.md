# Simple Sysmon Configuration

A simple PowerShell-based solution for installing and configuring **Sysmon (System Monitor)** on Windows devices using a custom XML configuration.

The project uses selected configuration rules from [sysmon-modular](https://github.com/olafhartong/sysmon-modular) by Olaf Hartong to create a customized Sysmon configuration focused on security monitoring and threat detection.

### Configuration Files

| File | Description |
|---|---|
| `config_auto.ps1` | Downloads, installs, and configures Sysmon. |
| `include.txt` | Lists XML rules that should be included in the configuration. |
| `exclude.txt` | Lists XML rules that should be excluded from the configuration. |
| `sysmonconfig-custom.xml` | Final XML configuration used by Sysmon. |
