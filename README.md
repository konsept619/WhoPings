# WhoPings
## What's all this about?
**WhoPings** is a simple program alerting you when someone is currently pinging your device. Whole notification system is based on output from *tcpdump* and tool providing GUI notifications. 
## Content of files
There are two main Bash scripts, that work together:
- **whopings.sh** - detects traffic on chosen interface. Traffic is logged in */var/tmp/whopings*, which can be changed at the beggining of the script.
- **notify.sh** - this part is supposed to handle whole notificating process. As there are some problems with running tools like *notify-send* with sudo permissions, it's better to use different separate script.
## Usage
User is supposed to run **whopings.sh** with *sudo* permissions. There are a few options that slightly change program behaviour.
```
Usage: $0 [b|i|h|s] [interface] 
-b    "background"  To be used in cron; output will be redirected to log file 
-i    "interactive" Output will be shown in terminal.
-s    "source"      Source interface on wich you want to listen. 
-h    "help"        Displays help.

This script must be used with sudo privileges!
```
- **background mode**  was designed to be used (which is self explanatory) in background. Script doesn't interfere current terminal session and alows you to perform different tasks.
- **interactive mode** shows you whole tcpdump output in terminal. You see incoming traffic, outcoming traffic isn't shown.
- **source** is supposed to detrmine on which interface you want to listen. Script takes IP assigned to pointed source and excludes it from recording output via *tcpdump*.
 You can't use background and interactive mode simultaneously.
## Notification process 
As soon as new IP address pings your device, there will be shown GUI notification with foreign address. Until the pinging device won't change, pop-up will appear only once. 
Content of a dialog box depends on *notify.sh*. You can use different tools as you wish. 
Main idea of running *notify.sh* from *whopings.sh* looks like this:
```./notify.sh $IP_ADDRESS``` 
You pass the "attacker" IP address to the function and process it.
![Pop-up from Zenity on GNOME](/images/popup.png "Pop-up")

