#    Copyright (C) 2016-2019  Dawid 'rud0lf' Lekawski
#      contact: xxrud0lf@gmail.com
#
#       --- INFORMATION ---
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#       --- END OF INFORMATION ---
#
#     Emote script - replace :emote_name: in your sent messages into predefined 
#   emotes (mostly but not limited to unicode). Result is visible both for you
#   and channel/query target users.
#
#     Feel free to modify or add your own ones!
#
#      (that's a lot of "emote" word, isn't it?)
#
#   commands:
#
#   - /emotes   - shows list of emotes in status window
#
#   notes:
#
#   - script doesn't work with /msg target text; must be typed in a channel
#     or query window (from version 1.10 it works with /me command too)
#
#   - Ctrl+O (ascii 15) at the beggining of your text turns off emote replacing 
#     for this text
#
#   - remeber to escape "\" characters in emotes (just type it twice -> "\\"),
#       take a look at 'shrug' emote for reference
#
#
#
#   -- CHANGES: --
#
#   - script now works with /me command (action)
#
#   - moved text output messages into nice and clean theme_register
#
#
#   -- CHANGES: -- ( v 1.20, 10-03-2019 )
#
#   - fixed messages containing utf-8 characters
#   - added tab-completion to emotes
#   - added "rud_emotes_space_after_completion" settings flag

use strict;
use warnings;
use utf8;

use Encode qw(decode_utf8 encode_utf8);
use Irssi qw(signal_add signal_continue command_bind theme_register
	printformat settings_add_bool);

our $VERSION = "1.20";
our %IRSSI = (
	authors		=> "Dawid 'rud0lf' Lekawski",
	contact		=> 'rud0lf/IRCnet; rud0lf/freenode; xxrud0lf@gmail.com',
	name		=> 'emotes script',
	description	=> 'Replaces :emote_name: text in your sent messages into pre-defined emotes (unicode mostly).',
	license		=> 'GPLv3',
	changed		=> '10-03-2019'
);

my $pattern = '';
my %emotes = (
	'huh', '°-°',
	'lenny', '( ͡° ͜ʖ ͡°)',
	'shrug', '¯\\_(ツ)_/¯',
	'smile', '☺',
	'sad', '☹',
	'heart', '♥',
	'note', '♪',
	'victory', '✌',
	'coffee', '☕',
	'kiss', '💋',
	'inlove', '♥‿♥',
	'annoyed', '(¬_¬)',
	'bear', 'ʕ•ᴥ•ʔ',
	'animal', '(•ω•)',
	'happyanimal', '(ᵔᴥᵔ)',
	'strong', 'ᕙ(⇀‸↼‶)ᕗ',
	'happyeyeroll', '◔ ⌣ ◔',
	'tableflip', '(╯°□°）╯︵ ┻━┻',
	'tableback', '┬──┬ ノ( ゜-゜ノ)',
	'tm', '™',
	'birdflip', '╭∩╮(-_-)╭∩╮',
	'lolshrug', '¯\\(°_o)/¯',
	'shades', '(⌐■_■)',
	'smoke', '🚬',
	'poop', '💩',
	'drops', '💦',
	'yuno', 'щ（ﾟДﾟщ)',
	'dead', '✖_✖',
	'wtf', '☉_☉',
	'disapprove', '๏̯͡๏',
	'wave', '(•◡•)/',
    'shock', '⊙▃⊙',
    'wink', '◕‿↼',
	'gift', '(´・ω・)っ由',
    'success', '(•̀ᴗ•́)و',
	'whatever', '◔_◔',
	'run', 'ᕕ(⚆ ʖ̯⚆)ᕗ',
	'rock', '(ツ)\m/'
);

sub init {
	theme_register([
		'rud_emotes_list', 'List of emotes:',
		'rud_emotes_emote', '* $[!15]0 : $1',
		'rud_emotes_total', 'Total of $0 emotes.'
]);  
  
	$pattern = join('|', keys %emotes);
	if ($pattern eq '') {
		$pattern = '!?';
	}
}

sub process_emotes {
	my ($line) = @_;
	
	# don't process line starting with Ctrl+O (ascii 15)
	if ($line =~ /^\x0f/) {
		return $line;
	}

    $line = decode_utf8($line);
	$line =~ s/:($pattern):/$emotes{$1}/g;
    $line = encode_utf8($line);

	return $line;
}

sub sig_send_text {
	my ($line, $server, $witem) = @_;

	return unless ($witem);
	return unless ($witem->{type} eq "CHANNEL" or $witem->{type} eq "QUERY");

	my $newline = process_emotes($line);
	signal_continue($newline, $server, $witem);
}

sub sig_command_me {
	my ($line, $server, $witem) = @_;

	return unless ($witem);
	return unless ($witem->{type} eq "CHANNEL" or $witem->{type} eq "QUERY");

	my $newline = process_emotes($line);
	signal_continue($newline, $server, $witem);	
}

sub cmd_emotes {
	my ($data, $server, $witem) = @_;

	printformat(MSGLEVEL_CLIENTCRAP, 'rud_emotes_list');
	foreach my $key (sort(keys %emotes)) {
		printformat(MSGLEVEL_CLIENTCRAP, 'rud_emotes_emote', $key, $emotes{$key});
	}	
	printformat(MSGLEVEL_CLIENTCRAP, 'rud_emotes_total', scalar(keys %emotes));
}

sub sig_complete_word {
    my ($list, $win, $word, $prefix, $want_space) = @_;
    return unless ($word =~ /:(\w+)/);
    my $p = $1;
    my $sp = Irssi::settings_get_bool('rud_emotes_space_after_completion');
    foreach (keys %emotes) {
        if ($_ =~ /$p\w+/) {
            push @$list, ":$_:";
            $$want_space = $sp;
        } 
    }
}

init();

signal_add("send text", "sig_send_text");
signal_add("command me", "sig_command_me");
signal_add("complete word", "sig_complete_word");
command_bind("emotes", "cmd_emotes");
settings_add_bool('rud_emotes', 'rud_emotes_space_after_completion', 1);
