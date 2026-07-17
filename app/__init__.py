import datetime
import os
import re
import yaml
from flask import Flask, render_template, request
from dotenv import load_dotenv
from peewee import *
from playhouse.shortcuts import model_to_dict

load_dotenv()
app = Flask(__name__)

if os.getenv("TESTING") == "true":
    mydb = SqliteDatabase("file:memory?mode=memory&cache=shared", uri=True)
else:
    mydb = MySQLDatabase(os.getenv("MYSQL_DATABASE"),
                         user=os.getenv("MYSQL_USER"),
                         password=os.getenv("MYSQL_PASSWORD"),
                         host=os.getenv("MYSQL_HOST"),
                         port=3306)

class TimelinePost(Model):
    name = CharField()
    email = CharField()
    content = TextField()
    created_at = DateTimeField(default=datetime.datetime.now)

    class Meta:
        database = mydb

mydb.connect()
mydb.create_tables([TimelinePost])

base_dir = os.path.dirname(os.path.abspath(__file__))
content_path = os.getenv("CONTENT", "content.yaml")
if not os.path.isabs(content_path):
    content_path = os.path.join(base_dir, "..", content_path)

with open(content_path) as f:
    content = yaml.safe_load(f)

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

@app.route('/api/timeline_post', methods=['POST'])
def post_time_line_post():
    name = request.form.get('name', '').strip()
    email = request.form.get('email', '').strip()
    post_content = request.form.get('content', '').strip()

    if not name:
        return 'Invalid name', 400
    if not post_content:
        return 'Invalid content', 400
    if not EMAIL_RE.match(email):
        return 'Invalid email', 400

    timeline_post = TimelinePost.create(name=name, email=email, content=post_content)

    return model_to_dict(timeline_post)

@app.route('/api/timeline_post', methods=['GET'])
def get_time_line_post():
    post_id = request.form.get('id')
    query = TimelinePost.select().order_by(TimelinePost.created_at.desc())
    if post_id is not None:
        query = query.where(TimelinePost.id == post_id)
    return {
        'timeline_posts' : [model_to_dict(p) for p in query]
    }

@app.route('/api/timeline_post', methods=['DELETE'])
def delete_time_line_post():
    post_id = request.form.get('id')
    max_id = TimelinePost.select(fn.MAX(TimelinePost.id)).scalar() or 0
    if int(post_id) > max_id:
        return {'id' : post_id}, 404
    
    try:
        post = TimelinePost.get_by_id(post_id)
    except DoesNotExist: # Already deleted
        return {'id' : post_id}, 410
     
    TimelinePost.delete_by_id(post_id)
    return model_to_dict(post), 200

@app.route('/timeline')
def timeline():
    posts = [
        model_to_dict(p)
        for p in TimelinePost.select().order_by(TimelinePost.created_at.desc())
    ]
    return render_template('timeline.html', title='Timeline', timeline_posts=posts)
    
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
