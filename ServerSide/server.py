from http.server import BaseHTTPRequestHandler, HTTPServer
import cgi
import inference
import os
import pathlib
import json

CURRENT_PATH = os.path.abspath(os.getcwd())

hostName = ""
serverPort = 8088

class MyServer(BaseHTTPRequestHandler):
  def do_GET(self):
    self.send_response(200)
    self.send_header("Content-type", "text/html")
    self.end_headers()
    self.wfile.write(bytes("<html><head><title>BrailleRecognition</title></head>", "utf-8"))
    self.wfile.write(bytes("<p>Request: %s</p>" % self.path, "utf-8"))
    self.wfile.write(bytes("<body>", "utf-8"))
    self.wfile.write(bytes("<p>This is an example web server.</p>", "utf-8"))
    self.wfile.write(bytes("</body></html>", "utf-8"))
  def do_POST(self):
    if(self.path == "/translate"):
      r, info = self.translate()
      self.send_response(200)
      self.send_header("Content-type", "application/json")
      self.end_headers()
      if(r):
        self.wfile.write(bytes(json.dumps(info), "utf-8"))
    else:
      self.send_response(404)
      self.end_headers()
  
  def translate(self):
    ctype, pdict = cgi.parse_header(self.headers['Content-Type'])
    pdict['boundary'] = bytes(pdict['boundary'], "utf-8")
    pdict['CONTENT-LENGTH'] = int(self.headers['Content-Length'])
    if ctype == 'multipart/form-data':
        form = cgi.FieldStorage( fp=self.rfile, headers=self.headers, environ={'REQUEST_METHOD':'POST', 'CONTENT_TYPE':self.headers['Content-Type'], })
        try:
            ext = pathlib.Path(form["image"].filename).suffix
            open(CURRENT_PATH+"/temp"+ext, "wb").write(form["image"].file.read())
            res = inference.recognize(CURRENT_PATH+"/temp"+ext)
            return (True, res)
        except IOError:
                return (False, "Can't create file to write, do you have permission to write?")
    return (True, "")

if __name__ == "__main__":
  webServer = HTTPServer((hostName, serverPort), MyServer)
  print("Server started http://%s:%s" % (hostName, serverPort))

  try:
    webServer.serve_forever()
  except KeyboardInterrupt:
    pass

  webServer.server_close()
  print("Server stopped.")