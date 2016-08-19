from flask import Flask, jsonify
from flask import send_from_directory
from flask import url_for
import os.path

app = Flask(__name__)

patch_fm = [
	{
		'patch_enabled': True,
	},
    {
		'content': u'location',
		'md5': u'2f4dcsa1234', 
		'version': 1.01
    }
]

patch = [
	{
		'patch_enabled': True,
		'version': 2.0
    }
]

@app.route('/')
def hello_world():
    return 'Hello World!'

@app.route('/v2/fm/get_ios_patch', methods=['GET'])
def get_patch_version():
    return jsonify({'patch': patch})

@app.route('/4.6.1/<path:version>', methods=['GET'])
def get_patch_zip(version):
	return send_from_directory('./4.6.1',version,as_attachment=True)

if __name__ == '__main__':
    app.run(debug=True)