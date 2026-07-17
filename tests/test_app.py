import unittest
import os

# Must precede the `app` import: app/__init__.py picks its database and
# connects at module scope.
os.environ['TESTING'] = 'true'

from app import app, content

class AppTestCase(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    def test_home(self):
        response = self.client.get('/')
        assert response.status_code == 200
        html = response.get_data(as_text=True)
        personal = content['personal']
        assert f"<title>{personal['name']}</title>" in html
        assert f"Hi, I'm {personal['name']}" in html
        for interest in personal['interests']:
            assert interest in html
        for social in personal['socials']:
            assert social['url'] in html

    def test_timeline_get_empty(self):
        response = self.client.get('/api/timeline_post')
        assert response.status_code == 200
        assert response.is_json
        json = response.get_json()
        assert 'timeline_posts' in json
        assert len(json['timeline_posts']) == 0

    def test_timeline_post_then_get(self):
        post_response = self.client.post('/api/timeline_post', data={
            'name': 'John Doe',
            'email': 'john@example.com',
            'content': "Hello world, I'm John!",
        })
        assert post_response.status_code == 200
        posted = post_response.get_json()
        assert posted['name'] == 'John Doe'
        assert posted['email'] == 'john@example.com'
        assert posted['content'] == "Hello world, I'm John!"

        get_response = self.client.get('/api/timeline_post')
        assert get_response.status_code == 200
        posts = get_response.get_json()['timeline_posts']
        assert len(posts) == 1
        assert posts[0]['name'] == 'John Doe'
        assert posts[0]['email'] == 'john@example.com'
        assert posts[0]['content'] == "Hello world, I'm John!"

    def test_timeline_page(self):
        response = self.client.get('/timeline')
        assert response.status_code == 200
        html = response.get_data(as_text=True)
        assert 'id="timeline-form"' in html
        assert 'id="timeline-list"' in html
        assert 'name="name"' in html
        assert 'name="email"' in html
        assert 'name="content"' in html

    def test_malformed_timeline_post(self):
        response = self.client.post('/api/timeline_post', data={'email': 'john@example.com', 'content': 'Hello world, I\'m John!'})
        assert response.status_code == 400
        html = response.get_data(as_text=True)
        assert 'Invalid name' in html

        response = self.client.post('/api/timeline_post', data={'name': 'John Doe', 'email': 'john@example.com', 'content': ''})
        assert response.status_code == 400
        html = response.get_data(as_text=True)
        assert 'Invalid content' in html

        response = self.client.post('/api/timeline_post', data={'name': 'John Doe', 'email': 'not-an-email', 'content': 'Hello world, I\'m John!'})
        assert response.status_code == 400
        html = response.get_data(as_text=True)
        assert 'Invalid email' in html


