## IRC
Simple IRC library.

```
import frothy7650.vircc
import os

fn main()
{
  ip := os.input("Enter the server IP: ")
  nick := os.input("Enter your nickname: ")

  mut conn := vircc.connect(ip, "6667", nick)
  conn.login()!

  // receiving messages
  go fn [mut conn]() {
    for conn.is_running {
      line := conn.readline() or { continue }
      println(line)
    }
  }()

  // sending messages
  for conn.is_running {
    input := os.input("")
    conn.writeline(input) or { eprintln("Write error") continue }
  }
}
```
