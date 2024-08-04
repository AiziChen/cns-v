module main

import net

fn main() {
	mut listener := net.listen_tcp(net.AddrFamily.ip, '0.0.0.0:1080')!
	for {
		mut conn := listener.accept() or {
			println('accept new connection occurred error: ${err}')
			continue
		}
		spawn handle_connection(mut conn)
	}
}

fn handle_connection(mut conn net.TcpConn) ! {
	mut buff := []u8{len: 4096}
	for {
		rsize := conn.read(mut buff)!
		if rsize == 0 {
			break
		}
		header := buff[..rsize].bytestr()
		if is_http_header(header) {
			println('handle http request...')
			conn.write_string(response_header(header))!
			if !header.contains('httpUDP') {
				// handle TCP connections
				process_tcpsession(mut conn, header)!
				conn.close()!
			} else {
				// handle UDP connections
			}
		}
	}
	conn.close()!
}
