import logging
from flask import Flask

def create_app(config_name="development"):
	app = Flask(__name__)

	if config_name == "development":
		logging.basicConfig(
			level=logging.DEBUG,
			format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
		)
	else:
		logging.basicConfig(level=logging.INFO)

	@app.route("/")
	def health():
		app.logger.debug("Health check solicitado")
		return {"status": "ok"}, 200

	return app
