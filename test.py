import os
import openai
openai.organization = "org-a8FR39HtlLqV8bNb0TxpF008"
OPENAI_API_KEY = "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"
# openai.api_key = os.getenv(OPENAI_API_KEY)
openai.api_key = OPENAI_API_KEY
print(openai.Model.list())