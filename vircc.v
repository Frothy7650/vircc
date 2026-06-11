module vircc

import time
import net

pub fn connect(ip string, port string, nick string) !IrcConn {
	mut conn := net.dial_tcp('${ip}:${port}')!

	$if debug {
		println('${IrcConn{ tcp: conn, nick: nick }}')
	}
	$if debug {
		println('${ip}:${port}')
	}

  conn.set_read_timeout(30 * time.second)
  conn.set_write_timeout(10 * time.second)

	return IrcConn{
		tcp:        conn
    state: IrcState{
      nick: nick
      is_running: true
    }
	}
}

// Helper functions
pub fn (mut irc_conn IrcConn) login() ! {
	// Write the nickname to the server
	irc_conn.tcp.write('NICK ${irc_conn.state.nick}\r\n'.bytes())!

	// Write the username to the server
	irc_conn.tcp.write('USER ${irc_conn.state.nick} 0 * :${irc_conn.state.nick} IRC Client\r\n'.bytes())!
}

pub fn (mut irc_conn IrcConn) disconnect() ! {
	irc_conn.tcp.close()!
}
