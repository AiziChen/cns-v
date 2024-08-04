module main

import net
import regex

pub fn process_tcpsession(mut server net.TcpConn, header string) ! {
	proxy := get_proxy(header) or {
		server.write_string('NO proxy host')!
		return
	}
	host_port := decrypt_host(proxy, 'quanyec')
	mut client := net.dial_tcp(host_port) or {
		server.write_string('Proxy address [${host_port}] ResolveTCP() error')!
		return
	}
	spawn pre_tcp_forward(mut client, mut server)
	pre_tcp_forward(mut server, mut client)
}

fn pre_tcp_forward(mut fromConn net.TcpConn, mut toConn net.TcpConn) {
	tcp_forward(mut fromConn, mut toConn) or {
		fromConn.close() or { return }
		toConn.close() or { return }
	}
}

fn tcp_forward(mut fromConn net.TcpConn, mut toConn net.TcpConn) ! {
	mut buff := []u8{len: 4098}
	mut subi := u8(0)
	for {
		rsize := fromConn.read(mut buff) or {
			fromConn.close()!
			toConn.close()!
			return
		}
		if rsize == 0 {
			fromConn.close()!
			toConn.close()!
			return
		}
		subi = xor_cipher(mut buff, 'quanyec', subi, rsize)
		toConn.write(buff[..rsize]) or {
			fromConn.close()!
			toConn.close()!
		}
	}
}

fn get_proxy(header string) !string {
	mut re := regex.regex_opt(r'Meng:\s*(.+)\s+')!
	contents := re.find_all_str(header)
	if contents.len > 0 {
		content := contents[0]
		return content.substr(5, content.len).trim(' \r\n')
	} else {
		return error('not found proxy in header')
	}
}
