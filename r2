import requests
import json

API_KEY = "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"  # ваш API-ключ
MODEL = "deepseek/deepseek-r1"

def process_content(content):
    return content.replace('<think>', '').replace('</think>', '')

def chat_stream(prompt):
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "stream": True
    }

    with requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers=headers,
        json=data,
        stream=True
    ) as response:
        if response.status_code != 200:
            return {"error": f"API error: {response.status_code}"}

        full_response = []
        
        for chunk in response.iter_lines():
            if chunk:
                chunk_str = chunk.decode('utf-8').replace('data: ', '')
                try:
                    chunk_json = json.loads(chunk_str)
                    if "choices" in chunk_json:
                        content = chunk_json["choices"][0]["delta"].get("content", "")
                        if content:
                            cleaned = process_content(content)
                            full_response.append(cleaned)
                except:
                    pass

        return ''.join(full_response)

# Получаем входные данные из n8n
input_data = items[0]['json']
prompt = input_data.get('prompt', '')

# Обрабатываем запрос
response = chat_stream(prompt)

# Возвращаем результат в формате, подходящем для n8n
return [{'json': {'response': response}}]
