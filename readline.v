module vircc

pub fn (mut irc_conn IrcConn) readline() !IrcMsg {
	raw_line := irc_conn.tcp.read_line()
	line := raw_line.trim_space()
	if line.len == 0 {
		return IrcMsg{}
	}

  mut nick := ''
  mut tags := map[string]string{}
	mut prefix := ''
	mut command := Command{}
  mut params := []string{}

  mut message := IrcMsg{}

	if m := irc_conn.r.match_str(line, 0, 0) {
    tags_str := m.get(1) or { '' }
    prefix = m.get(2) or { '' }
    command_str := m.get(3) or { '' }
    params_str := m.get(4) or { '' }
    trailing := m.get(5) or { '' }

    // Parse tags
    if tags_str != '' {
      for tag in tags_str.split(';') {
        parts := tag.split_nth('=', 2)

        if parts.len == 2 {
          tags[parts[0]] = parts[1]
        } else {
          tags[parts[0]] = ''
        }
      }
    }

    // Parse command
    if command_str.len == 3 && command_str.bytes().all(it.is_digit()) {
      command = command_str.int()
    } else {
      command = command_str
    }

    // Parse params
    if params_str != '' {
      params = params_str.split(' ')
    }

    // trailing is just final param
    if trailing != '' {
      params << trailing
    }

    // Extract nick from prefix
    if prefix.contains('!') {
      nick = prefix.split('!')[0]
    } else {
      nick = prefix
    }

    message = IrcMsg{
      nick: nick
      tags: tags
      prefix: prefix
      command: command
      params: params
      message: ''
    }

    if irc_conn.use_internal_formatting {
      irc_conn.builtin_message_formatting(mut message)!
    }

    $if debug {
      println(message)
    }

    return message
	} else {
		return error('failed to parse IRC message')
	}
}

pub fn (mut irc_conn IrcConn) builtin_message_formatting(mut msg IrcMsg) ! {
  trailing := if msg.params.len > 0 {
    msg.params.last()
  } else { 
    ''
  }

  match msg.command {
    string {
      match msg.command as string {
        'NOTICE' {
          if msg.nick.len > 0 {
            msg.message = '-${msg.nick}- ${trailing}'
            return
          }
          msg.message = '** notice ** ${trailing}'
          return
        }
        'PRIVMSG' {
          if trailing.starts_with('\x01ACTION ') && trailing.ends_with('\x01') {
            action_text := trailing[8..trailing.len - 1]
            msg.message = '* ${msg.nick} ${action_text}'
            return
          }
          msg.message = '<${msg.nick}> ${trailing}'
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
          msg.message = '${msg.nick} has joined ${if trailing.len > 0 {
            trailing
          } else {
            msg.params[0]
          }}'
        }
        'PART' {
          if trailing.len > 0 {
            msg.message = '${msg.nick} has left ${msg.params[0]} (${trailing})'
            return
          }
          msg.message = '${msg.nick} has left ${msg.params[0]}'
          return
        }
        'QUIT' {
          if trailing.len > 0 {
            msg.message = '${msg.nick} has quit (${trailing})'
            return
          }
          msg.message = '${msg.nick} has quit'
          return
        }
        'NICK' {
          newnick := if trailing.len > 0 { msg.params.last() } else { msg.params[0] }
          msg.message = '${msg.nick} is now known as ${newnick}'
          return
        }
        // TODO: fix this
        /* 'KICK' {
          parts := line.split(' ')
          if parts.len >= 4 {
            victim := parts[3]
            mut msg := '${msg.nick} kicked ${chalk.cyan(victim)} from ${chalk.cyan(msg.params[0])}'
            if trailing.len > 0 {
              msg += ' (${trailing})'
            }
            return msg
          }
        }
        */
        'MODE' {
          msg.message = '${msg.nick} changed mode: ${trailing}'
          return
        }
        'TOPIC' {
          msg.message = '${msg.nick} set topic for ${msg.params[0]}: ${trailing}'
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
