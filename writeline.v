module vircc

pub fn (mut irc_conn IrcConn) writeline(input string) !string {
	// Commands start with /
	if input.starts_with('/') {
		parts := input[1..].split(' ') // remove leading /

		match parts[0] {
			'join' {
				if parts.len > 1 {
					irc_conn.state.command = 'JOIN ${parts[1]}'
					irc_conn.tcp.write('JOIN ${parts[1]}\r\n'.bytes())!
					irc_conn.state.channel = parts[1]
				}
			}
			'part' {
				if parts.len == 1 {
					irc_conn.state.command = 'PART ${irc_conn.state.channel} :Goodbye'
					irc_conn.tcp.write('PART ${irc_conn.state.channel} :Goodbye\r\n'.bytes())!
					irc_conn.state.channel = ''
				} else if parts.len <= 3 {
					mut channel := ''
					if parts[1] == '' {
						channel = irc_conn.state.channel
					} else {
						channel = parts[1]
					}
					irc_conn.state.command = 'PART ${channel} :${parts[2..].join(' ')}'
					irc_conn.tcp.write('PART ${channel} :${parts[2..].join(' ')}\r\n'.bytes())!
					irc_conn.state.channel = ''
				}
			}
			'knock' {
				if parts.len >= 3 {
					mut channel := ''
					if parts[1] == '' {
						channel = irc_conn.state.channel
					}
					irc_conn.state.command = 'KNOCK ${channel} :${parts[2..]}'
					irc_conn.tcp.write('KNOCK ${channel} :${parts[2..]}\r\n'.bytes())!
				}
			}
			'invite' {
				if parts.len == 3 {
					irc_conn.state.command = 'INVITE ${parts[1]} ${parts[2]}'
					irc_conn.tcp.write('INVITE ${parts[1]} ${parts[2]}\r\n'.bytes())!
				}
			}
			'list' {
				irc_conn.state.command = 'LIST'
				irc_conn.tcp.write('LIST\r\n'.bytes())!
			}
			'nick' {
				if parts.len > 1 {
					irc_conn.state.command = 'NICK ${parts[1]}'
					irc_conn.tcp.write('NICK ${parts[1]}\r\n'.bytes())!
					irc_conn.state.nick = parts[1]
				}
			}
			'names' {
				if parts.len > 1 {
					irc_conn.state.command = 'NAMES ${parts[1]}'
					irc_conn.tcp.write('NAMES ${parts[1]}\r\n'.bytes())!
				} else {
					irc_conn.state.command = 'NAMES ${irc_conn.state.channel}'
					irc_conn.tcp.write('NAMES ${irc_conn.state.channel}\r\n'.bytes())!
				}
			}
			'notice' {
				if parts.len >= 3 {
					irc_conn.state.command = 'NOTICE ${parts[1]} :${parts[2..].join(' ')}'
					irc_conn.tcp.write('NOTICE ${parts[1]} :${parts[2..].join(' ')}\r\n'.bytes())!
				}
			}
			'whois' {
				if parts.len >= 3 {
					irc_conn.state.command = 'WHOIS ${parts[1]} ${parts[2]}'
					irc_conn.tcp.write('WHOIS ${parts[1]} ${parts[2]}\r\n'.bytes())!
				} else if parts.len == 2 {
					irc_conn.state.command = 'WHOIS ${parts[1]} ${irc_conn.state.channel}'
					irc_conn.tcp.write('WHOIS ${parts[1]} ${irc_conn.state.channel}\r\n'.bytes())!
				}
			}
			'whowas' {
				if parts.len >= 3 {
					irc_conn.state.command = 'WHOWAS ${parts[1]} ${parts[2]}'
					irc_conn.tcp.write('WHOWAS ${parts[1]} ${parts[2]}\r\n'.bytes())!
				} else if parts.len == 2 {
					irc_conn.state.command = 'WHOWAS ${parts[1]} 1'
					irc_conn.tcp.write('WHOWAS ${parts[1]} 1\r\n'.bytes())!
				}
			}
			'motd' {
				irc_conn.state.command = 'MOTD'
				irc_conn.tcp.write('MOTD\r\n'.bytes())!
			}
			'version' {
				irc_conn.state.command = 'VERSION'
				irc_conn.tcp.write('VERSION\r\n'.bytes())!
			}
			'mode' {
				if parts.len >= 3 {
					irc_conn.state.command = 'MODE ${parts[1..].join(' ')}'
					irc_conn.tcp.write('MODE ${parts[1..].join(' ')}\r\n'.bytes())!
				} else if parts.len == 2 {
					irc_conn.state.command = 'MODE ${irc_conn.state.channel}'
					irc_conn.tcp.write('MODE ${irc_conn.state.channel}\r\n'.bytes())!
				}
			}
      'me' {
        if parts.len > 1 {
          action := parts[1..].join(' ')
          irc_conn.state.command = 'PRIVMSG ${irc_conn.state.channel} :\x01ACTION ${action}\x01'
          irc_conn.tcp.write('PRIVMSG ${irc_conn.state.channel} :\x01ACTION ${action}\x01\r\n'.bytes())!
        }
      }
			'quit' {
				irc_conn.state.command = 'QUIT :${parts[1..].join(' ')}'
				irc_conn.tcp.write('QUIT :${parts[1..].join(' ')}\r\n'.bytes())!
				irc_conn.state.is_running = false
				irc_conn.disconnect() or {}
				return ''
			}
			else {
				return 'Unknown command or invalid syntax'
			}
		}
	} else {
		// Print normal messages
		if irc_conn.state.channel != '' {
			irc_conn.state.command = 'PRIVMSG ${irc_conn.state.channel} :${input}'
			irc_conn.tcp.write('PRIVMSG ${irc_conn.state.channel} :${input}\r\n'.bytes())!
		}
	}
  return ''
}
