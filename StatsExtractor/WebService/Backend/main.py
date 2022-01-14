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
