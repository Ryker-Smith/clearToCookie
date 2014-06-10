package clearToCookie;
use strict;
use CGI::Cookie;
require Exporter;
our @ISA = qw(Exporter);

# Author: faROE
# Date: 2014
# Purpose:  Utility/demonstration/test of cookieing module
#
# Sources:  http://perldoc.perl.org/CGI/Cookie.html#Recovering-Previous-Cookies
#           http://www.gaumina.ie/irish-cookie-law-policies/

use constant permissionCookieName=>'clearToCookie_';
use constant actionSetCookie=>'cookieSet';

our $cookiesOK; # the master cookieing flag

our $standardCookieMsg="This site uses cookies. By continuing to use this site you are agreeing to this policy.";
our $standardReturnTo=<<_returnToHereCode;
  <form action="_ACTIONSCRIPT" style="display: inline">
  <input type="hidden" name="action" value="_ACTIONVALUE">
  <input type="submit" value="dismiss">
  </form>
_returnToHereCode

sub cookieCheck {
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
# set cookie to say yes/no cookieing in future
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
# Warning msg about cookies
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
    <div id="cookieCheck">
    $myCookieMsg
    $myReturnTo
    </div>
____cookieCheck0
  # done
} # sub cookieMsg

sub cookieReturnTo {
  my %env = %ENV;
  return $env{REQUEST_URI};
} #sub cookieReturnTo

our @EXPORT_OK= qw (&cookieCheck &cookieMsg &cookieSet &cookieReturnTo $standardCookieMsg $cookiesOK permissionCookieName actionSetCookie);

our %EXPORT_TAGS = (all => [@EXPORT_OK]);

return 1;