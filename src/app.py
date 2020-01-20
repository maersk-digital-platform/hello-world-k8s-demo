from flask import Flask
import os

app = Flask(__name__)


@app.route("/healthz")
def healthz():
    return "ok"


@app.route("/alive")
def alive():
    return "ok"


@app.route("/hello")
# def healthz(): # introduces application crash bug
def hello():
    myhost = os.uname()[1]
    body = ("V1 - Hello World! - %s" % myhost)
    # body = ("V2 - Hello World! - %s" % myhost)
    return body


if __name__ == "__main__":
    from waitress import serve
    serve(app, host="0.0.0.0", port=80)
