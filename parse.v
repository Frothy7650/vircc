module vircc

// helper: skip spaces + CRLF safely
fn skip_ws(line string, j int) int {
  mut i := j
  for i < line.len {
    if line[i] == ` ` {
      i++
      continue
    }

    if line[i] == `\r` && i + 1 < line.len && line[i + 1] == `\n` {
      i += 2
      continue
    }

    break
  }
  return i
}

pub fn parse(line string, mut irc_conn IrcConn) !IrcMsg {
  mut tags := map[string]?string{}
  mut prefix := Prefix{}
  mut command := ?Command{}
  mut params := []string{}

  mut message := IrcMsg{}

  mut i := 0

  i = skip_ws(line, i)

  // tags
  if i < line.len && line[i] == `@` {
    i++

    start := i
    for i < line.len && line[i] != ` ` && line[i] != `\r` && line[i] != `\n` {
      i++
    }

    if i > line.len {
      return error('unterminated tags')
    }

    for tag in line[start..i].split(';') {
      if tag.contains('=') {
        value := tag.split_nth('=', 2)
        tags[value[0]] = value[1]
      } else {
        tags[tag] = none
      }
    }

    i = skip_ws(line, i)
  }

  // prefix
  if i < line.len && line[i] == `:` {
    i++
    start := i

    for i < line.len && line[i] != ` ` && line[i] != `\r` && line[i] != `\n` {
      i++
    }

    if start >= line.len {
      return error('unterminated prefix')
    }

    prefix_raw := line[start..i]

    // safe parsing (no panic splits)
    if prefix_raw.contains('!') && prefix_raw.contains('@') {
      parts := prefix_raw.split('!')
      if parts.len >= 2 {
        nick := parts[0]
        user_host := parts[1].split('@')

        if user_host.len >= 2 {
          prefix = Prefix{
            raw: prefix_raw
            nickname: nick
            username: user_host[0]
            hostname: user_host[1]
            type: .user
          }
        } else {
          prefix = Prefix{
            raw: prefix_raw
            type: .server
          }
        }
      }
    } else {
      prefix = Prefix{
        raw: prefix_raw
        type: .server
      }
    }

    i = skip_ws(line, i)
  }

  // command
  if command == none {
    start := i

    for i < line.len && line[i] != ` ` && line[i] != `\r` && line[i] != `\n` {
      i++
    }

    command_raw := line[start..i]

    if command_raw.is_int() {
      command = command_raw.int()
    } else {
      command = command_raw
    }

    i = skip_ws(line, i)
  }

  // params
  for i < line.len {
    i = skip_ws(line, i)

    if i >= line.len {
      break
    }

    if line[i] == `:` {
      i++
      if i < line.len {
        params << line[i..]
      }
      break
    }

    start := i
    for i < line.len && line[i] != ` ` && line[i] != `\r` && line[i] != `\n` {
      i++
    }

    params << line[start..i]
  }

  message = IrcMsg{
    raw: line
    tags: tags
    prefix: prefix
    command: command or { panic('parser didn\'t provide a command') }
    command_type: ident_command(command or { panic('parser didn\'t provide a command') })
    params: params
  }

  if irc_conn.cfg.use_internal_formatting {
    builtin_message_formatting(mut message, mut irc_conn)!
  }

  return message
}
