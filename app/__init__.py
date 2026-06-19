import os
import yaml
from flask import Flask, render_template, request
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)

base_dir = os.path.dirname(os.path.abspath(__file__))
content_path = os.getenv("CONTENT", "content.yaml")
if not os.path.isabs(content_path):
    content_path = os.path.join(base_dir, "..", content_path)

with open(content_path) as f:
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
        lambda t=template, p=page: render_template(t, page=p)
    )
