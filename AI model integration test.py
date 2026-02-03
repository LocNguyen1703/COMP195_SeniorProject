import requests

# The URL where Ollama is running
url = "http://localhost:11434/api/generate"

# The model you pulled
model_name = "llama3"

# Prompt to send
prompt = "Why is the sky blue? Explain in one sentence."

# Payload
payload = {
    "model": model_name,
    "prompt": prompt,
    "stream": False # Set to True for streaming responses
}

# Send request
response = requests.post(url, json=payload)

# Print result
if response.status_code == 200:
    print(response.json()['response'])
else:
    print("Error:", response.text)