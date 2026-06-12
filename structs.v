module vircc

import net

// IRC connection struct for all the data
pub struct IrcConn {
mut:
	tcp   net.TcpConn
pub mut:
  state IrcState
  cfg   IrcCfg
}

pub struct IrcCfg {
pub mut:
  use_internal_formatting bool
}

pub struct IrcState {
pub mut:
  nick        string
  channel     string
  command     string
  is_running  bool
}

// Created by parse()
pub struct IrcMsg {
pub:
  raw          string
  tags         map[string]?string
  prefix       Prefix
  command      Command
  command_type CommandType
  params       []string

pub mut:
  // Buffer for builtin_message_formatting()
  message  string
}

pub struct Prefix {
pub:
  raw      string
  nickname string
  username string
  hostname string
  type     PrefixType
}

pub enum PrefixType {
  user
  server
}

pub type Command = string | int

// Command type enum for cleaner command handling
pub fn ident_command(cmd Command) CommandType {
	match cmd {
		int {
			// Numeric IRC replies (e.g. 372, 433, etc.)
			return CommandType.numeric
		}
		string {
			// Safe string handling (NO unsafe casts)
			c := cmd

			if c.contains('ADMIN') { return CommandType.admin }
			if c.contains('AWAY') { return CommandType.away }
			if c.contains('CNOTICE') { return CommandType.cnotice }
			if c.contains('CPRIVMSG') { return CommandType.cprivmsg }
			if c.contains('CONNECT') { return CommandType.connect }
			if c.contains('DIE') { return CommandType.die }
			if c.contains('ENCAP') { return CommandType.encap }
			if c.contains('ERROR') { return CommandType.error }
			if c.contains('HELP') { return CommandType.help }
			if c.contains('INFO') { return CommandType.info }
			if c.contains('INVITE') { return CommandType.invite }
			if c.contains('ISON') { return CommandType.ison }
			if c.contains('JOIN') { return CommandType.join }
			if c.contains('KICK') { return CommandType.kick }
			if c.contains('KILL') { return CommandType.kill }
			if c.contains('KNOCK') { return CommandType.knock }
			if c.contains('LIST') { return CommandType.list }
			if c.contains('LUSERS') { return CommandType.lusers }
			if c.contains('MODE') { return CommandType.mode }
			if c.contains('MOTD') || c.contains('372') { return CommandType.motd }
			if c.contains('NAMES') { return CommandType.names }
			if c.contains('NICK') { return CommandType.nick }
			if c.contains('NOTICE') { return CommandType.notice }
			if c.contains('PART') { return CommandType.part }
			if c.contains('PASS') { return CommandType.pass }
			if c.contains('PING') { return CommandType.ping }
			if c.contains('PONG') { return CommandType.pong }
			if c.contains('PRIVMSG') { return CommandType.privmsg }
			if c.contains('QUIT') { return CommandType.quit }
			if c.contains('TOPIC') { return CommandType.topic }
			if c.contains('USER') { return CommandType.user }
			if c.contains('VERSION') { return CommandType.version }
			if c.contains('WHOIS') { return CommandType.whois }
			if c.contains('WHOWAS') { return CommandType.whowas }

			return CommandType.notamessage
		}
	}
}

// see rfc1459 and https://en.wikipedia.org/wiki/list_of_internet_relay_chat_commands
pub enum CommandType {
  numeric
	notamessage
	admin
	away
	cnotice
	cprivmsg
	connect
	die
	encap
	error
	help
	info
	invite
	ison
	join
	kick
	kill
	knock
	links
	list
	lusers
	mode
	motd
	names
	namesx
	nick
	notice
	oper
	part
	pass
	ping
	pong
	privmsg
	quit
	rehash
	restart
	rules
	server
	service
	servlist
	squery
	squit
	setname
	silence
	stats
	summon
	time
	topic
	trace
	uhnames
	user
	userhost
	userip
	users
	version
	wallops
	watch
	who
	whois
	whowas
}
