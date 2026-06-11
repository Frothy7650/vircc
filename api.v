module vircc

pub fn (mut irc_conn IrcConn) join(channel string) ! {
	irc_conn.state.command = 'JOIN ${channel}'
	irc_conn.tcp.write('JOIN ${channel}\r\n'.bytes())!
	irc_conn.state.channel = channel
}

pub fn (mut irc_conn IrcConn) part(channel string, message ?string) ! {
	mut target := channel

	if target == '' {
		target = irc_conn.state.channel
	}

	part_message := message or { 'Goodbye' }

	irc_conn.state.command = 'PART ${target} :${part_message}'
	irc_conn.tcp.write('PART ${target} :${part_message}\r\n'.bytes())!

	if target == irc_conn.state.channel {
		irc_conn.state.channel = ''
	}
}

pub fn (mut irc_conn IrcConn) knock(channel string, message string) ! {
	irc_conn.state.command = 'KNOCK ${channel} :${message}'
	irc_conn.tcp.write('KNOCK ${channel} :${message}\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) invite(nick string, channel string) ! {
	irc_conn.state.command = 'INVITE ${nick} ${channel}'
	irc_conn.tcp.write('INVITE ${nick} ${channel}\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) list() ! {
	irc_conn.state.command = 'LIST'
	irc_conn.tcp.write('LIST\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) nick(nick string) ! {
	irc_conn.state.command = 'NICK ${nick}'
	irc_conn.tcp.write('NICK ${nick}\r\n'.bytes())!
	irc_conn.state.nick = nick
}

pub fn (mut irc_conn IrcConn) names(channel ?string) ! {
	target := channel or { irc_conn.state.channel }

	irc_conn.state.command = 'NAMES ${target}'
	irc_conn.tcp.write('NAMES ${target}\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) notice(target string, message string) ! {
	irc_conn.state.command = 'NOTICE ${target} :${message}'
	irc_conn.tcp.write('NOTICE ${target} :${message}\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) whois(nick string, target ?string) ! {
	whois_target := target or { irc_conn.state.channel }

	irc_conn.state.command = 'WHOIS ${nick} ${whois_target}'
	irc_conn.tcp.write('WHOIS ${nick} ${whois_target}\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) whowas(nick string, count ?int) ! {
	history_count := count or { 1 }

	irc_conn.state.command = 'WHOWAS ${nick} ${history_count}'
	irc_conn.tcp.write('WHOWAS ${nick} ${history_count}\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) motd() ! {
	irc_conn.state.command = 'MOTD'
	irc_conn.tcp.write('MOTD\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) version() ! {
	irc_conn.state.command = 'VERSION'
	irc_conn.tcp.write('VERSION\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) mode(args ...string) ! {
	if args.len == 0 {
		irc_conn.state.command = 'MODE ${irc_conn.state.channel}'
		irc_conn.tcp.write('MODE ${irc_conn.state.channel}\r\n'.bytes())!
		return
	}

	command := args.join(' ')

	irc_conn.state.command = 'MODE ${command}'
	irc_conn.tcp.write('MODE ${command}\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) quit(message ?string) ! {
	quit_message := message or { '' }

	irc_conn.state.command = 'QUIT :${quit_message}'
	irc_conn.tcp.write('QUIT :${quit_message}\r\n'.bytes())!

	irc_conn.state.is_running = false
	irc_conn.disconnect()!
}

pub fn (mut irc_conn IrcConn) privmsg(target string, message string) ! {
	irc_conn.state.command = 'PRIVMSG ${target} :${message}'
	irc_conn.tcp.write('PRIVMSG ${target} :${message}\r\n'.bytes())!
}
