module vircc

pub fn (mut irc_conn IrcConn) readline() !IrcMsg {
	raw_line := irc_conn.tcp.read_line()
	line := raw_line.trim_space()
	if line.len == 0 {
		return error('connection failed')
	}

  return parse(line, mut irc_conn)!
}

fn builtin_message_formatting(mut msg IrcMsg, mut irc_conn IrcConn) ! {
	trailing := if msg.params.len > 0 {
		msg.params.last()
	} else {
		''
	}

	match msg.command_type {
		.notice {
			if msg.prefix.nickname.len > 0 {
				msg.message = '-${msg.prefix.nickname}- ${trailing}'
				return
			}

			msg.message = '** notice ** ${trailing}'
			return
		}

		.privmsg {
			if trailing.starts_with('\x01ACTION ') && trailing.ends_with('\x01') {
				action_text := trailing[8..trailing.len - 1]
				msg.message = '* ${msg.prefix.nickname} ${action_text}'
				return
			}

			msg.message = '<${msg.prefix.nickname}> ${trailing}'
			return
		}

		.ping {
			irc_conn.tcp.write('PONG :${trailing}\r\n'.bytes())!
			msg.message = ''
			return
		}

		.pong {
			if trailing.len > 0 {
				msg.message = '${trailing} responded to ping'
				return
			}
		}

		.join {
			msg.message = '${msg.prefix.nickname} has joined ${
				if trailing.len > 0 {
					trailing
				} else {
					msg.params[0]
				}
			}'
			return
		}

		.part {
			if trailing.len > 0 {
				msg.message = '${msg.prefix.nickname} has left ${msg.params[0]} (${trailing})'
				return
			}

			msg.message = '${msg.prefix.nickname} has left ${msg.params[0]}'
			return
		}

		.quit {
			if trailing.len > 0 {
				msg.message = '${msg.prefix.nickname} has quit (${trailing})'
				return
			}

			msg.message = '${msg.prefix.nickname} has quit'
			return
		}

		.nick {
			newnick := if trailing.len > 0 {
				msg.params.last()
			} else {
				msg.params[0]
			}

			msg.message = '${msg.prefix.nickname} is now known as ${newnick}'
			return
		}

		.kick {
			victim := msg.params[1]

			mut out := '${msg.prefix.nickname} kicked ${victim} from ${msg.params[0]}'

			if trailing.len > 0 {
				out += ' (reason: ${trailing})'
			}

			msg.message = out
			return
		}

		.mode {
			msg.message = '${msg.prefix.nickname} changed mode: ${trailing}'
			return
		}

		.topic {
			msg.message = '${msg.prefix.nickname} set topic for ${msg.params[0]}: ${trailing}'
			return
		}

		.motd {
			msg.message = trailing
			return
		}

		.names {
			names := trailing.split_by_space()

			mut ret := ''

			for name in names {
				ret += '[${name}] '
			}

			msg.message = 'Users: ${ret}'
			return
		}

		else {
			// Numeric replies/errors
			match msg.command {
				int {
					msg.message = '[${msg.command}] ${trailing}'
					return
				}

				else {
					msg.message = '-!- [${msg.command}] ${trailing}'
					return
				}
			}
		}
	}
}
