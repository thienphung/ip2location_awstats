#!/usr/bin/perl
#-----------------------------------------------------------------------------
# IP2Location_City AWStats plugin
# This plugin allow you to get AWStats city report.
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP2Location
#-----------------------------------------------------------------------------

# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
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
my $PluginNeedAWStatsVersion="6.5";
my $PluginHooksFunctions="AddHTMLMenuLink AddHTMLGraph ShowInfoHost SectionInitHashArray SectionProcessIp SectionProcessHostname SectionReadHistory SectionWriteHistory";
my $PluginName="ip2location_city";
my $PluginImplements = "mou";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$ip2location
%_city_p
%_city_h
%_city_k
%_city_l
$MAXNBOFSECTIONGIR
/;

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_ip2location_city {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
	$MAXNBOFSECTIONGIR=10;

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin ip2location: InitParams=$InitParams",1);
	my ($datafile,$override)=split(/\s+/,$InitParams,2);

	if(!$ip2location){
		$ip2location = Geo::IP2Location->open($datafile);
	}
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLMenuLink_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLMenuLink_ip2location_city {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: AddHTMLMenuLink"); }
    if ($categ eq 'who') {
        $menu->{"plugin_$PluginName"}=2.2;               # Pos
        $menulink->{"plugin_$PluginName"}=2;             # Type of link
        $menutext->{"plugin_$PluginName"}=$Message[172]; # Text
    }
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLGraph_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLGraph_ip2location_city {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
    my $ShowCities='H';
	$MinHit{'Cities'}=1;
	my $total_p; my $total_h; my $total_k;
	my $rest_p; my $rest_h; my $rest_k;

	if ($Debug) { debug(" Plugin $PluginName: AddHTMLGraph $categ $menu $menulink $menutext"); }
	my $title="IP2LOCATION Cities";
	&tab_head($title,19,0,'cities');
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th>".$Message[148]."</th>";
	print "<th>".$Message[171]."</th>";
	print "<th>".$Message[172].": ".((scalar keys %_city_h)-($_city_h{'unknown'}?1:0))."</th>";
	if ($ShowCities =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[56]</th>"; }
	if ($ShowCities =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[15]</th>"; }
	if ($ShowCities =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[57]</th>"; }
	if ($ShowCities =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[15]</th>"; }
	if ($ShowCities =~ /B/i) { print "<th bgcolor=\"#$color_k\" width=\"80\">$Message[75]</th>"; }
	if ($ShowCities =~ /L/i) { print "<th width=\"120\">$Message[9]</th>"; }
	print "</tr>\n";
	$total_p=$total_h=$total_k=0;
	my $count=0;
	&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Cities'},\%_city_h,\%_city_h);
    	foreach my $key (@keylist) {
            if ($key eq 'unknown') { next; }
   		    my ($countrycode,$city,$regionlib)=split('_',$key,3);
			$regionlib=~s/%20/ /g;
			$regionlib=~s/(\w+)/\u$1/g;
            $city=~s/%20/ /g;
			$city=~s/(\w+)/\u$1/g;
   			my $p_p; my $p_h;
			if ($TotalPages) { $p_p=int(($_city_p{$key}||0)/$TotalPages*1000)/10; }
   			if ($TotalHits)  { $p_h=int($_city_h{$key}/$TotalHits*1000)/10; }
   		    print "<tr>";
   		    print "<td class=\"aws\">".$DomainsHashIDLib{$countrycode}."</td>";
   		    print "<td class=\"aws\">".($regionlib?$regionlib:'&nbsp;')."</td>";			
   		    print "<td class=\"aws\">".EncodeToPageCode($city)."</td>";
    		if ($ShowCities =~ /P/i) { print "<td>".($_city_p{$key}?Format_Number($_city_p{$key}):"&nbsp;")."</td>"; }
    		if ($ShowCities =~ /P/i) { print "<td>".($_city_p{$key}?"$p_p %":'&nbsp;')."</td>"; }
    		if ($ShowCities =~ /H/i) { print "<td>".($_city_h{$key}?Format_Number($_city_h{$key}):"&nbsp;")."</td>"; }
    		if ($ShowCities =~ /H/i) { print "<td>".($_city_h{$key}?"$p_h %":'&nbsp;')."</td>"; }
    		if ($ShowCities =~ /B/i) { print "<td>".Format_Bytes($_city_k{$key})."</td>"; }
    		if ($ShowCities =~ /L/i) { print "<td>".($_city_p{$key}?Format_Date($_city_l{$key},1):'-')."</td>"; }
    		print "</tr>\n";
    		$total_p += $_city_p{$key}||0;
    		$total_h += $_city_h{$key};
    		$total_k += $_city_k{$key}||0;
    		$count++;
    	}
#    }
	if ($Debug) { debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2); }
	$rest_p=0;
	$rest_h=$TotalHits-$total_h;
	$rest_k=0;
	if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other cities
		my $p_p; my $p_h;
		if ($TotalPages) { $p_p=int($rest_p/$TotalPages*1000)/10; }
		if ($TotalHits)  { $p_h=int($rest_h/$TotalHits*1000)/10; }
		print "<tr>";
		print "<td class=\"aws\" colspan=\"3\"><span style=\"color: #$color_other\">$Message[2]/$Message[0]</span></td>";
		if ($ShowCities =~ /P/i) { print "<td>".($rest_p?$rest_p:"&nbsp;")."</td>"; }
   		if ($ShowCities =~ /P/i) { print "<td>".($rest_p?"$p_p %":'&nbsp;')."</td>"; }
		if ($ShowCities =~ /H/i) { print "<td>".($rest_h?$rest_h:"&nbsp;")."</td>"; }
   		if ($ShowCities =~ /H/i) { print "<td>".($rest_h?"$p_h %":'&nbsp;')."</td>"; }
		if ($ShowCities =~ /B/i) { print "<td>".Format_Bytes($rest_k)."</td>"; }
		if ($ShowCities =~ /L/i) { print "<td>&nbsp;</td>"; }
		print "</tr>\n";
	}
	&tab_end();

	# ----->
	return 0;
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
sub ShowInfoHost_ip2location_city {
    my $param="$_[0]";
	# <-----
	if ($param eq '__title__')
	{
    	my $NewLinkParams=${QueryString};
    	$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&|&amp;)output(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
    	my $NewLinkTarget='';
    	if ($DetailedReportsOnNewWindows) { $NewLinkTarget=" target=\"awstatsbis\""; }
    	if (($FrameName eq 'mainleft' || $FrameName eq 'mainright') && $DetailedReportsOnNewWindows < 2) {
    		$NewLinkParams.="&framename=mainright";
    		$NewLinkTarget=" target=\"mainright\"";
    	}
    	$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
    	$NewLinkParams =~ s/^&amp;//; $NewLinkParams =~ s/&amp;$//;
    	if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }

#		print "<th width=\"80\">";
#        print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?XMLEncode("$AWScript?${NewLinkParams}output=plugin_geoip_city_maxmind&amp;suboutput=country"):"$PROG$StaticLinks.plugin_geoip_city_maxmind.country.$StaticExt")."\"$NewLinkTarget>GeoIP<br/>Country</a>";
#        print "</th>";
		print "<th width=\"150\">";
        print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?XMLEncode("$AWScript?${NewLinkParams}output=plugin_$PluginName"):"$StaticLinks.plugin_$PluginName.$StaticExt")."\"$NewLinkTarget>City</a>";
        print "</th>";
	}elsif ($param){
		# try loading our override file if we haven't yet
        my $ip=0;
		my $key;
		my $country;
		my $city;
		$country 	= $ip2location->get_country_long($param);
		$city 		= $ip2location->get_city($param);
		print "<td>";
		if ($city) { print EncodeToPageCode($city); }
		else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		print "</td>";
	}else{
		print "<td>&nbsp;</td>";
	}
	return 1;
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionInitHashArray_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionInitHashArray_ip2location_city {
#    my $param="$_[0]";
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Init_HashArray"); }
	%_city_p = %_city_h = %_city_k = %_city_l =();
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessIP_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessIp_ip2location_city {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my $record_city 			= $ip2location->get_city($param);
	my $record_region 			= $ip2location->get_region($param);
	my $record_country_code 	= $ip2location->get_country_short($param);
	if ($Debug) { debug("  Plugin $PluginName: GetCityByIp for $param: [$record_city $record_region $record_country_code]",5); }
	if ($record_city || $record_region || $record_country_code) {
		my $city=$record_city;
	#   	if ($PageBool) { $_city_p{$city}++; }
		if ($city) {
			my $countrycity=$record_country_code.'_'.$record_city;
			$countrycity=~s/ /%20/g;
			if ($record_region) { $countrycity.='_'.$record_region; }
			$_city_h{lc($countrycity)}++;
		} else {
			$_city_h{'unknown'}++;
		}
	#   	if ($timerecord > $_city_l{$city}) { $_city_l{$city}=$timerecord; }
	} else {
		$_city_h{'unknown'}++;
	}
	# ----->
	return;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionReadHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionReadHistory_ip2location_city {
    my $issectiontoload=shift;
    my $xmlold=shift;
    my $xmleb=shift;
	my $countlines=shift;
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Begin of PLUGIN_ip2location_city section"); }
	my @field=();
	my $count=0;my $countloaded=0;
	do {
		if ($field[0]) {
			$count++;
			if ($issectiontoload) {
				$countloaded++;
				if ($field[2]) { $_city_h{$field[0]}+=$field[2]; }
			}
		}
		$_=<HISTORY>;
		chomp $_; s/\r//;
		@field=split(/\s+/,($xmlold?XMLDecodeFromHisto($_):$_));
		$countlines++;
	}
	until ($field[0] eq "END_PLUGIN_$PluginName" || $field[0] eq "${xmleb}END_PLUGIN_$PluginName" || ! $_);
	if ($field[0] ne "END_PLUGIN_$PluginName" && $field[0] ne "${xmleb}END_PLUGIN_$PluginName") { error("History file is corrupted (End of section PLUGIN not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).","","",1); }
	if ($Debug) { debug(" Plugin $PluginName: End of PLUGIN_$PluginName section ($count entries, $countloaded loaded)"); }
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionWriteHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionWriteHistory_ip2location_city {
    my ($xml,$xmlbb,$xmlbs,$xmlbe,$xmlrb,$xmlrs,$xmlre,$xmleb,$xmlee)=(shift,shift,shift,shift,shift,shift,shift,shift,shift);
    if ($Debug) { debug(" Plugin $PluginName: SectionWriteHistory_$PluginName start - ".(scalar keys %_city_h)); }
	# <-----
	print HISTORYTMP "\n";
	if ($xml) { print HISTORYTMP "<section id='plugin_$PluginName'><sortfor>$MAXNBOFSECTIONGIR</sortfor><comment>\n"; }
	print HISTORYTMP "# Plugin key - Pages - Hits - Bandwidth - Last access\n";
	#print HISTORYTMP "# The $MaxNbOfExtra[$extranum] first number of hits are first\n";
	$ValueInFile{"plugin_$PluginName"}=tell HISTORYTMP;
	print HISTORYTMP "${xmlbb}BEGIN_PLUGIN_$PluginName${xmlbs}".(scalar keys %_city_h)."${xmlbe}\n";
	&BuildKeyList($MAXNBOFSECTIONGIR,1,\%_city_h,\%_city_h);
	my %keysinkeylist=();
	foreach (@keylist) {
		$keysinkeylist{$_}=1;
		#my $page=$_city_p{$_}||0;
		#my $bytes=$_city_k{$_}||0;
		#my $lastaccess=$_city_l{$_}||'';
		print HISTORYTMP "${xmlrb}".XMLEncodeForHisto($_)."${xmlrs}0${xmlrs}", $_city_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	foreach (keys %_city_h) {
		if ($keysinkeylist{$_}) { next; }
		#my $page=$_city_p{$_}||0;
		#my $bytes=$_city_k{$_}||0;
		#my $lastaccess=$_city_l{$_}||'';
		print HISTORYTMP "${xmlrb}".XMLEncodeForHisto($_)."${xmlrs}0${xmlrs}", $_city_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	print HISTORYTMP "${xmleb}END_PLUGIN_$PluginName${xmlee}\n";
	# ----->
	return 0;
}

1;	# Do not remove this line
