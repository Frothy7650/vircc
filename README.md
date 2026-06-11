## VIRCC
Simple IRC client library.

## Features
```
fn connect(ip string, port string, nick string) !IrcConn

type Command = string | int
struct IrcConn {
pub mut:
	tcp                     net.TcpConn
	nick                    string
	channel                 string
	command                 string
	is_running              bool
	use_internal_formatting bool
	r                       pcre.Regex
}

fn (mut irc_conn IrcConn) builtin_message_formatting(mut msg IrcMsg) !
fn (mut irc_conn IrcConn) readline() !IrcMsg
fn (mut irc_conn IrcConn) writeline(input string) !string

struct IrcMsg {
pub mut:
	nick    string
	tags    map[string]string
	prefix  string
	command Command
	params  []string

	// Buffer for builtin_message_formatting()
	message string
}
```

Very incomplete, does not yet support all commands.
If you want any features, open an issue.

## Usage
Here is a minimal example of how do use vircc
```
import frothy7650.vircc
import os

fn main()
{
  ip := os.input("IP: ")
  nick := os.input("Nick: ")

  mut conn := vircc.connect(ip, "6667", nick)!
  conn.use_internal_formatting = true
  conn.login()!

  // --- receiving messages ---
  // I don't know if there is a better way
  // to do this, so i recommend running it
  // in the background like this

  go fn [mut conn]() {
    for conn.is_running {
      msg := conn.readline() or { continue }.message
      println(msg)
    }
  }()

  // --- sending messages ---
  // To send messages, run conn.writeline()
  // and handle the errors, you don't have
  // to loop it like i did, just run it whenever
  for conn.is_running {
    input := os.input("")
    conn.writeline(input) or { eprintln("Write error") continue }
  }
}
```
