"""
   Copyright (C) 2022  Argyros Argyridis arargyridis at gmail dot com
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import json,sys
from StatsRequests import StatsRequests
sys.stdout = sys.stderr


def process(environ):
	if environ["REQUEST_METHOD"] == "POST":
		try:
			response={}
			requestData = None
			requestBodySize = environ.get('CONTENT_LENGTH', 0)
			if len(requestBodySize) > 0:
				requestBodySize = int(requestBodySize)
				requestBody = environ['wsgi.input'].read(requestBodySize)
				requestData = json.loads(requestBody)
			req = StatsRequests(requestData=requestData)
			res = req.process()
			response["data"] = res[1]
			print(response)
			print(json.dumps(response))
			return (res[0], json.dumps(response).encode("utf-8"))


		except ValueError:
			return ("400: Bad request", """{"error": "Unable to process"}""".encode("utf-8"))
	elif environ["REQUEST_METHOD"] == "OPTIONS":
			return ("200: OK", """{"status": "OK"}""".encode("utf-8"))
	else:
		return ("400: Bad request", """{"Error": "Only POST/OPTIONS requests are implemented"}""".encode("utf-8"))
		





def main(environ, startResponse):
	status, response = process(environ)
	headers =  [
		('Content-type', 'application/json'),
		('Content-Length', str(len(response)) ),
		('charset', 'utf-8')]
	startResponse(status, headers)
	return response

application = main
