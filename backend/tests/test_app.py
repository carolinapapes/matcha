from app import create_app

def test_health():
	app = create_app("development")
	client = app.test_client()
	response = client.get("/")
	assert response.status_code == 200
	assert response.json == {"status": "ok"}
