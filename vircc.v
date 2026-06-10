module vircc

import regex.pcre
import net

pub fn connect(ip string, port string, nick string) !IrcConn {
	mut conn := net.dial_tcp('${ip}:${port}')!
	$if debug {
		println('${IrcConn{ tcp: conn, nick: nick }}')
	}
	$if debug {
		println('${ip}:${port}')
	}
	return IrcConn{
		tcp:        conn
		nick:       nick
		channel:    ''
		is_running: true
    r: pcre.new_regex(r'^(?:@(?<tags>[^\r\n ]+)\s)?(?:\:(?<prefix>[^\r\n ]+)\s)?(?<command>[A-Za-z]+|\d{3})(?:\s(?<params>(?:[^\r\n :][^\r\n ]*(?:\s[^\r\n :][^\r\n ]*)*)))?(?:\s\:(?<trailing>[^\r\n]*))?\r?\n?$', 0) or { return error('regex compile failed') }
	}
}

// Helper functions
pub fn (mut irc_conn IrcConn) login() ! {
	// Write the nickname to the server
	irc_conn.tcp.write('NICK ${irc_conn.nick}\r\n'.bytes())!
	$if debug {
		println('NICK ${irc_conn.nick}')
	}

	// Write the username to the server
	irc_conn.tcp.write('USER ${irc_conn.nick} 0 * :${irc_conn.nick} IRC Client\r\n'.bytes())!
	$if debug {
		println('USER ${irc_conn.nick} 0 * :${irc_conn.nick}')
	}
}

pub fn (mut irc_conn IrcConn) disconnect() ! {
	$if debug {
		println('Goobai')
	}
	irc_conn.tcp.close()!
}

// Structs
pub struct IrcConn {
pub mut:
	tcp                     net.TcpConn
	nick                    string
	channel                 string
	command                 string
	is_running              bool
	use_internal_formatting bool
  r                       pcre.Regex
}

pub struct IrcMsg {
pub mut:
  nick     string
  tags     map[string]string
  prefix   string
  command  Command
  params   []string

  // Buffer for builtin_message_formatting()
  message  string
}

pub type Command = string | int
