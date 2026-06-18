import os
import yaml
from flask import Flask, render_template, request
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html', title="MLH Fellow", url=os.getenv("URL"))

base_dir = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(base_dir, "../content.yaml")) as f:
    content = yaml.safe_load(f)

@app.context_processor
def inject_content():
    return content
