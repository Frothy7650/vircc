module vircc

import net

// IRC connection struct for all the data
pub struct IrcConn {
mut:
	tcp   net.TcpConn
pub mut:
  state IrcState
  cfg   IrcCfg
}

pub struct IrcCfg {
pub mut:
  use_internal_formatting bool
}

pub struct IrcState {
pub mut:
  nick        string
  channel     string
  command     string
  is_running  bool
}

// Created by parse()
pub struct IrcMsg {
pub:
  raw      string
  tags     map[string]?string
  prefix   Prefix
  command  Command
  params   []string

pub mut:
  // Buffer for builtin_message_formatting()
  message  string
}

struct Prefix {
  raw      string
  nickname string
  username string
  hostname string
  type     PrefixType
}

enum PrefixType {
  user
  server
}

pub type Command = string | int
