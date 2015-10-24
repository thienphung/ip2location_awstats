Instructions
============

1. Install Geo::IP2Location, Redis libraries from CPAN. Install Redis Server
2. Upload ip2location.pm ip2location_city.pm ip2location_isp.pm to `/usr/local/awstats/wwwroot/cgi-bin/plugins`.
3. Apply a patch patch-ip2location.diff
4. Open `/etc/awstats/awstats.conf` and insert following line:

    LoadPlugin="ip2location /usr/share/IP2Location/IP-COUNTRY-REGION-CITY-ISP.BIN"
	LoadPlugin="ip2location_city /usr/share/IP2Location/IP-COUNTRY-REGION-CITY-ISP.BIN"
	LoadPlugin="ip2location_isp /usr/share/IP2Location/IP-COUNTRY-REGION-CITY-ISP.BIN"
	
    **Note: ** Make sure the path to IP2Location database file is correct.

5. Disable any Maxmind GeoIP plugin as AWStats hook can only access by one plugin per time.

6. View the information by accessing "Countries" or "Hosts" from the left menu.

7. It's recommended to use IP2Location DB3 which included country, region, and city information.
   Download free version from http://lite.ip2location.com or commercial version from http://www.ip2location.com.