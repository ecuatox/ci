import os
import json
import hmac
import hashlib
import subprocess

def local_setting(key):
	try:
		with open('local_settings.txt', 'r') as f:
			line = f.readline()
			while line:
				if line.startswith('%s: ' % key):
					return line.split(': ')[1].strip()
				line = f.readline()
			return ''
	except FileNotFoundError:
		return ''

def application(request, response):
	if 'HTTP_X_HUB_SIGNATURE' in request:
		payload = request['wsgi.input'].read()
		data = json.loads(payload.decode()) if payload else {}

		debug = eval(local_setting('debug').capitalize())
		if debug:
			with open('github_debug.txt', 'w') as f:
				f.write(json.dumps(data))

		github_secret = local_setting('secret').encode()

		signature = hmac.new(github_secret, payload, hashlib.sha1).hexdigest()
		github_signature = request['HTTP_X_HUB_SIGNATURE'].split('=')[1]

		authorized = hmac.compare_digest(signature, github_signature)

		if authorized:
			branch = data['ref'].split('/')[2]
			message = data['commits'][0]['message'] if data['commits'] else ''

			if branch == 'master':
				update_command = 'sudo ./ci.sh %s %s' % (github_signature, message.replace(' ', '_'))
				subprocess.Popen(update_command.split())

			response('200 OK', [('Content-Type', 'application/json')])
			return [json.dumps({'ok': True}).encode()]

	response('403 Forbidden', [('Content-Type', 'application/json')])
	return [json.dumps({'ok': False}).encode()]

