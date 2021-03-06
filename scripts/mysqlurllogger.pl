#
# Logs URLs this script is just a hack. hack it to suit you
# if you want to.
#
# table format;
#
#+-----------+---------------+------+-----+---------+-------+
#| Field     | Type          | Null | Key | Default | Extra |
#+-----------+---------------+------+-----+---------+-------+
#| insertime | timestamp(14) | YES  |     | NULL    |       |
#| nick      | char(10)      | YES  |     | NULL    |       |
#| target    | char(255)     | YES  |     | NULL    |       |
#| line      | char(255)     | YES  |     | NULL    |       |
#+-----------+---------------+------+-----+---------+-------+

use strict;
use DBI;
use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);

$VERSION = "1.1";
%IRSSI = (
        authors     => "Riku Voipio, lite",
        contact     => "riku.voipio\@iki.fi",
        name        => "myssqlurllogger",
        description => "logs url's to mysql database",
        license     => "GPLv2",
        url         => "http://nchip.ukkosenjyly.mine.nu/irssiscripts/",
    );

my $dsn; # 'DBI:mysql:ircurl:localhost';
my $db_user_name;
my $db_password;

sub cmd_logurl {
	my ($server, $data, $nick, $mask, $target) = @_;
        my $d = $data;
        if (($d =~ /(.{1,2}tp\:\/\/.+)/) or ($d =~ /(www\..+)/)) {
		db_insert($nick, $target, $1);
        }
	return 1;
}

sub cmd_own {
	my ($server, $data, $target) = @_;
	return cmd_logurl($server, $data, $server->{nick}, "", $target);
}
sub cmd_topic {
	my ($server, $target, $data, $nick, $mask) = @_;
	return cmd_logurl($server, $data, $nick, $mask, $target);
}

sub db_insert {
	my ($nick, $target, $line)=@_;
	my $dbh = DBI->connect($dsn, $db_user_name, $db_password);
	my $sql="insert into urlevent (insertime, nick, target,line) values (NOW()".",". $dbh->quote($nick) ."," . $dbh->quote($target) ."," . $dbh->quote($line) .")";
	my $sth = $dbh->do($sql);
	$dbh->disconnect();
	}

sub sig_setup_changed {
	$dsn=Irssi::settings_get_str($IRSSI{name}.'_dsn');
	$db_user_name=Irssi::settings_get_str($IRSSI{name}.'_user');
	$db_password=Irssi::settings_get_str($IRSSI{name}.'_password');
}

Irssi::settings_add_str($IRSSI{name}, $IRSSI{name}.'_dsn', 'DBI:mysql:ircurl:localhost');
Irssi::settings_add_str($IRSSI{name}, $IRSSI{name}.'_user', 'tunnus');
Irssi::settings_add_str($IRSSI{name}, $IRSSI{name}.'_password', 'salakala');

Irssi::signal_add_last('message public', 'cmd_logurl');
Irssi::signal_add_last('message own_public', 'cmd_own');
Irssi::signal_add_last('message topic', 'cmd_topic');
Irssi::signal_add("setup changed", "sig_setup_changed");

sig_setup_changed();

Irssi::print("URL logger by lite/nchip loaded.");

# vim:set ts=8 sw=8:
