import os
import yaml
from flask import Flask, render_template, request
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)

base_dir = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(base_dir, "../content.yaml")) as f:
    content = yaml.safe_load(f)

@app.context_processor
def inject_content():
    return content

for page in content['nav']:
    url = page['url']
    template = page['template']
    endpoint = url.strip('/') or 'index'

    app.add_url_rule(
        url,
        endpoint,
        lambda t=template: render_template(t, title=page['name'])
    )
