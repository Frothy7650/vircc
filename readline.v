module vircc

pub fn (mut irc_conn IrcConn) readline() !IrcMsg {
	raw_line := irc_conn.tcp.read_line()
	line := raw_line.trim_space()
	if line.len == 0 {
		return error('connection failed')
	}

  return parse(line, mut irc_conn)!
}

fn (mut irc_conn IrcConn) builtin_message_formatting(mut msg IrcMsg) ! {
  trailing := if msg.params.len > 0 {
    msg.params.last()
  } else { 
    ''
  }

  match msg.command {
    string {
      match msg.command as string {
        'NOTICE' {
          if msg.prefix.nickname.len > 0 {
            msg.message = '-${msg.prefix.nickname}- ${trailing}'
            return
          }
          msg.message = '** notice ** ${trailing}'
          return
        }
        'PRIVMSG' {
          if trailing.starts_with('\x01ACTION ') && trailing.ends_with('\x01') {
            action_text := trailing[8..trailing.len - 1]
            msg.message = '* ${msg.prefix.nickname} ${action_text}'
            return
          }
          msg.message = '<${msg.prefix.nickname}> ${trailing}'
          return
        }
        'PING' {
          irc_conn.tcp.write('PONG :${trailing}\r\n'.bytes())!
          msg.message = ''
          return
        }
        'PONG' {
          if trailing.len > 0 {
            msg.message = '${trailing} responded to ping'
            return
          }
        }
        'JOIN' {
          msg.message = '${msg.prefix.nickname} has joined ${if trailing.len > 0 {
            trailing
          } else {
            msg.params[0]
          }}'
        }
        'PART' {
          if trailing.len > 0 {
            msg.message = '${msg.prefix.nickname} has left ${msg.params[0]} (${trailing})'
            return
          }
          msg.message = '${msg.prefix.nickname} has left ${msg.params[0]}'
          return
        }
        'QUIT' {
          if trailing.len > 0 {
            msg.message = '${msg.prefix.nickname} has quit (${trailing})'
            return
          }
          msg.message = '${msg.prefix.nickname} has quit'
          return
        }
        'NICK' {
          newnick := if trailing.len > 0 { msg.params.last() } else { msg.params[0] }
          msg.message = '${msg.prefix.nickname} is now known as ${newnick}'
          return
        }
        // TODO: fix this
        /* 'KICK' {
          parts := line.split(' ')
          if parts.len >= 4 {
            victim := parts[3]
            mut msg := '${msg.prefix.nickname} kicked ${chalk.cyan(victim)} from ${chalk.cyan(msg.params[0])}'
            if trailing.len > 0 {
              msg += ' (${trailing})'
            }
            return msg
          }
        }
        */
        'MODE' {
          msg.message = '${msg.prefix.nickname} changed mode: ${trailing}'
          return
        }
        'TOPIC' {
          msg.message = '${msg.prefix.nickname} set topic for ${msg.params[0]}: ${trailing}'
          return
        }
        else {
          msg.message = '-!- [${msg.command}] ${trailing}'
          return
        }
      }
    }
    int {
      match msg.command as int {
        001, 002, 003, 004, 005 {
          msg.message = trailing
          return
        }
        200, 201, 202, 203, 204, 205, 206, 207, 208, 209 {
          msg.message = '[${msg.command}] ${trailing}'
          return
        }
        251, 252, 253, 254, 255 {
          msg.message = '[${msg.command}] ${trailing}'
          return
        }
        301, 305, 306, 311, 312, 313, 317, 318, 319 {
          msg.message = '[${msg.command}] ${trailing}'
          return
        }
        322, 323, 324, 331, 332, 341, 346, 347, 348, 349 {
          msg.message = '[${msg.command}] ${trailing}'
          return
        }
        353 {
          names := trailing.split_by_space()
          mut ret := ''
          for name in names {
            ret += '[${name}] '
          }
          msg.message = 'Users: ${ret}'
          return
        }
        366 {
          msg.message = 'userlist complete'
          return
        }
        372, 375, 376 {
          msg.message = '${trailing}'
          return
        }
        421, 422, 431, 432, 433, 436, 441, 442, 443, 451, 461, 462,
        463, 464, 465, 467, 471, 473, 475, 481, 482, 501, 502 {
          msg.message = '[${msg.command}] ${trailing}'
          return
        }
        else {
          msg.message = '[${msg.command}] ${trailing}'
          return
        }
      }
    }
  }
}
