package clearToCookie;
use strict;
use CGI::Cookie;
require Exporter;
our @ISA = qw(Exporter);

sub cookieCheck {
  my %cookies = CGI::Cookie->fetch;
  my $domain=shift;
  my $cookieName='clearToCookie_' . $domain;
  print "Content-type: text/html\n\n";
  my ($siteClearToCookie);
  if (defined $cookies{$cookieName}) {
    $siteClearToCookie = $cookies{$cookieName}->value;
  }
  else {
    return 0;
  }
}

sub cookieMsg {
    my $text= <<____cookieCheck0;
    <style>
    #cookieCheck{
      background: #ff3728;
      position: absolute;
      z-index: 100;
      top: 0px;
      left: 0px;
      width: 100%;
      height: 50px;
      font-size: 14px;
      font-family: Franklin, Sans serif;
      color: white;
      text-align: center;
    }
    </style>
    <div id="cookieCheck">
    This site uses cookies. By continuing to use this site you are agreeing to this.
    </div>
____cookieCheck0
}

our @EXPORT_OK= qw (&cookieCheck);

our %EXPORT_TAGS = (all => [@EXPORT_OK]);

return 1;