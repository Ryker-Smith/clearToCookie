package clearToCookie;
use strict;
use CGI::Cookie;
require Exporter;
our @ISA = qw(Exporter);

# Author: Fachtna Roe
# Date: 2014
# Purpose:  Utility/demonstration/test of cookieing module
#
# Sources:  http://perldoc.perl.org/CGI/Cookie.html#Recovering-Previous-Cookies
#           http://www.gaumina.ie/irish-cookie-law-policies/
# Version:  20140610-1630
#

use constant permissionCookieName=>'permissionToCookie_';
use constant actionSetCookie=>'cookieSet';

our $cookiesOK; # the master cookie-ing flag

our $standardCookieMsg="This site uses cookies. By continuing to use this site you are agreeing to this policy.";
our $standardReturnTo=<<_returnToHereCode;
  <form action="_ACTIONSCRIPT" style="display: inline">
  <input type="hidden" name="action" value="_ACTIONVALUE">
  <input type="submit" value="dismiss">
  </form>
_returnToHereCode
our $cookieStyle=<<____cookieStyle0;
    <style>
    #cookieCheck{
      background: #ff3728;
      position: absolute;
      z-index: 100;
      top: 0px;
      left: 0px;
      width: 100%;
      height: 25px;
      font-size: 14px/21px;
      padding-top: 4px;
      font-family: Franklin, Sans serif;
      color: white;
      text-align: center;
    }
    </style>
____cookieStyle0

sub cookieLegalBit {
# Purpose:  are we setting cookies? Handle the decision
# Expects:  action parameter
#           domain string
# Returns:  the cookieMsg or nothing
  my $action=shift;
  my $thisDomain=shift;
  if ($action eq actionSetCookie) {
    cookieSet($thisDomain, 1);
  }
  else {
    # test for IE/EU cookie permission
    if (cookieCheck($thisDomain) == 0) {
      return cookieMsg();
    }
  }
  # return nothing if we get this far (could be left out)
  return;
} # sub cookieLegalBit

sub cookieCheck {
# Purpose:  Is there a permission cookie
# Expects:  domain string
# Returns:  1/0 present/not present - ALSO sets $cookiesOK global var
# most basic test, is there a permissions cookie?
  my %cookies = CGI::Cookie->fetch;
  my $domain=shift;
  my $cookieName=permissionCookieName . $domain;
  #print "Content-type: text/html\n\n";
  my ($siteClearToCookie);
  # first test if defined to avoid crash
  if (defined $cookies{$cookieName}) {
    $siteClearToCookie = $cookies{$cookieName}->value;
    if ($siteClearToCookie == 1) {
      # set GLOBAL var to OK
      $cookiesOK=1;
      return 1;
    }
    else {
      $cookiesOK=0;
      return 0;
    }
  }
  else {
    # value not set, notify to ask perm
    return 0;
  }
} # sub cookieCheck

sub cookieSet {
# Purpose:  set cookie to say yes/no cookieing in future
# Expects:  domain string
#           Optional: permission value 1/0, defaults to 0
# Returns:  -
# 
  my $domain=shift;
  my $permissionValue=shift;
  my $expiryTime='+1M'; #default value, must give option to change this
  # any value > 0 will do, but default is no permission
  if ($permissionValue > 0) {
    $permissionValue=1;
  }
  else {
    $permissionValue=0;
  }
  # prepare the cookie
  my $cookie = CGI::Cookie->new(-name => permissionCookieName . $domain,
                                -value => $permissionValue,
                                -expires => $expiryTime); # expire in?
  # send it
  $cookie->bake();
} # sub cookieSet

sub cookieMsg {
# Purpose:  Warning msg about cookies
# Expects:  Optional: custom cookie message
#           Optional: a different URI to return to
# Returns:  Cookie warning msg, with own CSS

    # first see if custom msg present
    my $myCookieMsg=shift;
    if ($myCookieMsg eq "") {
      # no? use standard msg
      $myCookieMsg=$standardCookieMsg;
    }
    # specify custom return location?
    my $myReturnTo=shift;
    if ($myReturnTo eq "") {
      # no? use standard
      $myReturnTo=$standardReturnTo;
      # get calling URL
      my $returnDestination=&cookieReturnTo();
      my $returnAction= actionSetCookie;
      # substitute in values into standard returnto location
      $myReturnTo =~ s/_ACTIONSCRIPT/$returnDestination/g;
      $myReturnTo =~ s/_ACTIONVALUE/$returnAction/g;
    }
    # now print the top banner
    my $text= <<____cookieCheck0;
    $cookieStyle
    <div id="cookieCheck">
    $myCookieMsg
    $myReturnTo
    </div>
____cookieCheck0
    return $text;
  # done
} # sub cookieMsg

sub cookieReturnTo {
# Purpose:  Get the requesting URI to enable return to same location via CGI
# Expects:  -
# Returns:  URI within site
  my %env = %ENV;
  return $env{REQUEST_URI};
} #sub cookieReturnTo

# prepare for export
our @EXPORT_OK= qw (
                    &cookieLegalBit
                    &cookieCheck
                    &cookieMsg 
                    &cookieSet 
                    &cookieReturnTo 
                    $standardCookieMsg 
                    $cookiesOK
                    $cookieStyle
                    permissionCookieName 
                    actionSetCookie
                   );
# export useing tag 'all'
# in calling program: use clearToCookie ":all";
our %EXPORT_TAGS = (all => [@EXPORT_OK]);

return 1; # true