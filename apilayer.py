from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"

def send_slack_message(message):
    payload = {"text": message}
    response = requests.post(SLACK_WEBHOOK_URL, json=payload)
    return response.status_code == 200

@app.route('/notify', methods=['POST'])
def notify():
    data = request.get_json()
    message = data.get('message', 'No message provided')
    
    if send_slack_message(message):
        return jsonify({"status": "Notification sent"}), 200
    else:
        return jsonify({"status": "Failed to send notification"}), 500

if __name__ == '__main__':
    app.run(port=5000)
