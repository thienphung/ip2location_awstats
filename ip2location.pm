#!/usr/bin/perl
#-----------------------------------------------------------------------------
# IP2Location AWStats plugin
# This plugin allow you to get AWStats country report with country name.
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP2Location
#-----------------------------------------------------------------------------

# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES

#REDIS CACHE
use Redis;

push @INC, "${DIR}/plugins";
if (!eval ('require "Geo/IP2Location.pm";')) { return $@?"Error: $@":"Error: Need Perl module Geo::IP2Location"; }
# ----->
#use strict;
no strict "refs";


#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.5";
my $PluginHooksFunctions="GetCountryCodeByAddr ShowInfoHost";

#REDIS CACHE
#my $cache = Cache::Redis->new(
#	server    => '127.0.0.1:6379',
#	namespace => 'ip2location:',
#);
my $cache = Redis->new( server => '127.0.0.1:6379', encoding => undef );

# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
#use vars qw/
#%Ip2locationTmpDomainLookup
#$ip2location
#/;
use vars qw/
$ip2location
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_ip2location {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin ip2location: InitParams=$InitParams",1);
	my ($datafile,$override)=split(/\s+/,$InitParams,2);

	#%Ip2locationTmpDomainLookup=();
	$ip2location = Geo::IP2Location->open($datafile);
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByAddr_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByAddr is called to translate a host name into a country name.
#-----------------------------------------------------------------------------
sub GetCountryCodeByAddr_ip2location {
    my $param="$_[0]";
	# <-----
	if (! $param) { return ''; }
	#my $res= TmpLookup_ip2location($param);
	my $res	= $cache->get("country_$param");
	if (! $res) {
		$res=lc($ip2location->get_country_short($param)) || 'unknown';
		$cache->set("country_$param", $res);
		#$Ip2locationTmpDomainLookup{$param}=$res;
		if ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByAddr for $param: [$res]",5); }
	}
	elsif ($Debug) {debug("  Plugin $PluginName: GetCountryCodeByAddr for $param: Already resolved to [$res]",5);}
	# ----->
	return $res;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoHost_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to the Hosts report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell for $param</TD>";
# Parameters: Host name or ip
#-----------------------------------------------------------------------------
sub ShowInfoHost_ip2location {
    my $param="$_[0]";
	# <-----
	if ($param eq '__title__') {
    	my $NewLinkParams=${QueryString};
    	$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&)output(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
    	my $NewLinkTarget='';
    	if ($DetailedReportsOnNewWindows) { $NewLinkTarget=" target=\"awstatsbis\""; }
    	if (($FrameName eq 'mainleft' || $FrameName eq 'mainright') && $DetailedReportsOnNewWindows < 2) {
    		$NewLinkParams.="&framename=mainright";
    		$NewLinkTarget=" target=\"mainright\"";
    	}
    	$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
    	if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }

		print "<th width=\"80\"><a href=\"#countries\">Country</a></th>";
		#print "<th width=\"150\">ISP</th>";
		#print "<th width=\"150\">City</th>";
	}
	elsif ($param) {
		my $country_long = $ip2location->get_country_long($param);
		#my $city = $obj->get_city($param);
		#my $isp  = $obj->get_isp($param);

		print "<td><span style=\"color: #$color_other\">$country_long</span></td>";
		#print "<td><span style=\"color: #$color_other\">$city</span></td>";
		#print "<td><span style=\"color: #$color_other\">$isp</span></td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	return 1;
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: TmpLookup
# Searches the temporary hash for the parameter value and returns the corresponding
# GEOIP entry
#-----------------------------------------------------------------------------
#sub TmpLookup_ip2location(){
#	$param = shift;
#    return $Ip2locationTmpDomainLookup{$param}||'';
#}

1;