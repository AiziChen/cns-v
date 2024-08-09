module main

import encoding.base64

const headers = [
	'CONNECT',
	'GET',
	'POST',
	'HEAD',
	'PUT',
	'COPY',
	'DELETE',
	'MOVE',
	'OPTIONS',
	'LINK',
	'UNLINK',
	'TRACE',
	'WRAPPER',
]

pub fn is_http_header(header string) bool {
	return headers.any(fn [header] (h string) bool {
		return header.starts_with(h)
	})
}

pub fn response_header(header string) string {
	lower_header := header.to_lower()
	if lower_header.contains('websocket') {
		return 'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: CuteBi Network Tunnel, (%>w<%)\r\n\r\n'
	} else if lower_header.starts_with('connect') {
		return 'HTTP/1.1 200 Connection established\r\nServer: CuteBi Network Tunnel, (%>w<%)\r\nConnection: keep-alive\r\n\r\n'
	} else {
		return 'HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\nServer: CuteBi Network Tunnel, (%>w<%)\r\nConnection: keep-alive\r\n\r\n'
	}
}

pub fn xor_cipher(mut data []u8, secret string, subi u8, data_len int) u8 {
	if data_len == 0 {
		return subi
	} else {
		secret_len := secret.len
		mut pi := subi
		for data_sub in 0 .. data_len {
			pi = u8((data_sub + subi) % secret_len)
			data[data_sub] ^= secret[pi] | pi
		}
		return pi + 1
	}
}

pub fn decrypt_host(host string, secret string) string {
	mut decrypted_host := base64.decode(host)
	xor_cipher(mut decrypted_host, secret, 0, decrypted_host.len)
	return decrypted_host[0..decrypted_host.len - 1].bytestr()
}
