"""Extract base64 PNG from CDP captureScreenshot JSON and save."""
import base64
import json
import sys

with open(sys.argv[1], 'r', encoding='utf-8') as f:
    payload = json.load(f)
# response may be wrapped
data = payload
if 'result' in data:
    data = data['result']
if 'result' in data:
    data = data['result']
b64 = data['data']
raw = base64.b64decode(b64)
with open(sys.argv[2], 'wb') as f:
    f.write(raw)
print('WROTE', sys.argv[2], len(raw), 'bytes')
