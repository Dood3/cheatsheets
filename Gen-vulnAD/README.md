```shell
 ██████╗ ███████╗███╗   ██╗      ██╗   ██╗██╗   ██╗██╗     ███╗   ██╗ █████╗ ██████╗
██╔════╝ ██╔════╝████╗  ██║      ██║   ██║██║   ██║██║     ████╗  ██║██╔══██╗██╔══██╗
██║  ███╗█████╗  ██╔██╗ ██║█████╗██║   ██║██║   ██║██║     ██╔██╗ ██║███████║██║  ██║
██║   ██║██╔══╝  ██║╚██╗██║╚════╝╚██╗ ██╔╝██║   ██║██║     ██║╚██╗██║██╔══██║██║  ██║
╚██████╔╝███████╗██║ ╚████║       ╚████╔╝ ╚██████╔╝███████╗██║ ╚████║██║  ██║██████╔╝
 ╚═════╝ ╚══════╝╚═╝  ╚═══╝        ╚═══╝   ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═════╝
```
# Gen-VulnAD

Generate vulnerable active directories from scratch using a base `ad_config.json` file and a powershell script. inspired by [Wazehell's AD script](https://github.com/WazeHell/vulnerable-AD) and [John Hammond](https://github.com/JohnHammond).  

## Features
* Randomized accounts, groups and passwords
* Support for workstations
* Only need to run the script on an installed DC with Active Directory installed
* Customizable config file
* Rollback

### Usage
- Copy this repository onto your installed AD machine.
- Edit the `ad_config.json` file and set the parameters to suit your domain and needs.  
```powershell
# Copy the folder onto installed AD machine
# Edit the ad_config.json file and set the parameters
# Run make_schema.ps1 to generate your AD schema
./make_schema.ps1
# Run gen_vulnAD.ps1 to create the AD
./gen_vulnAD.ps1 out.json 
```


## Credits :yellow_heart:
* [WazeHell](https://github.com/WazeHell/) For inspiration
* [John Hammond](https://github.com/JohnHammond) For inspiration
* [Dominic Tarr](https://github.com/dominictarr) For the name lists
