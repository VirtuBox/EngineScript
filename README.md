## **EngineScript - Automated WordPress LEMP Server**

EngineScript automates the process of building a high-performance LEMP server. We've specifically built EngineScript with WordPress users in mind, so the install process will take you from a bare server all the way to the WordPress install menu with Nginx FastCGI cache enabled in about 15 minutes time.

*As this is a pre-release version, things might be totally broken day-to-day as we test different methods of building the server.*

##### Requirements
- Ubuntu 16.04 Xenial or 18.04 Bionic
- 1GB RAM
- Cloudflare (free or paid account)
- 15 minutes of your time

If you'd like to test EngineScript for yourself, just enter the command below into your favorite SSH client. This should be done on a fresh server with no current Nginx, PHP, or MySQL clients currently installed.

**Install EngineScript**
```shell
sudo curl -O https://raw.githubusercontent.com/VisiStruct/EngineScript/master/Initial-Setup.sh && sudo chmod 0700 Initial-Setup.sh && sudo bash Initial-Setup.sh
```

----------
