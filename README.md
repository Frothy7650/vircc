## VIRCC
Simple IRC client library.

> [!WARNING]
> The main repo for this is [here](https://iceshrimp.dev/frothy7650/vircc.git), github is just a mirror

> [!WARNING]
> This has not been tested on Windows or MacOS, if you have any issues, open an issue, but I can't help with Mac

## Features
```
fn connect(ip string, port string, nick string) !IrcConn
fn parse(line string, mut irc_conn IrcConn) !IrcMsg


type Command = string | int
struct IrcConn {
mut:
	tcp net.TcpConn
pub mut:
	state IrcState
	cfg   IrcCfg
}
struct IrcState {
pub mut:
	nick       string
	channel    string
	command    string
	is_running bool
}
struct IrcCfg {
pub mut:
	use_internal_formatting bool
}

fn (mut irc_conn IrcConn) disconnect() !
fn (mut irc_conn IrcConn) login() !
fn (mut irc_conn IrcConn) readline() !IrcMsg
fn (mut irc_conn IrcConn) writeline(input string) !string

struct IrcMsg {
pub:
	raw     string
	tags    map[string]?string
	prefix  Prefix
	command Command
	params  []string
pub mut:
	// Buffer for builtin_message_formatting()
	message string
}
```

Incomplete, does not yet support all commands.
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
  conn.cfg.use_internal_formatting = true
  conn.login()!

  // --- receiving messages ---
  // I don't know if there is a better way
  // to do this, so i recommend running it
  // in the background like this

  go fn [mut conn]() {
    for conn.state.is_running {
      msg := conn.readline() or { continue }.message
      println(msg)
    }
  }()

  // --- sending messages ---
  // To send messages, run conn.writeline()
  // and handle the errors, you don't have
  // to loop it like i did, just run it whenever
  for conn.state.is_running {
    input := os.input("")
    conn.writeline(input) or { eprintln("Write error") continue }
  }
}
```
