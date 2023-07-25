from pyrogram import *
import time
import sys

filename = sys.argv[1]
def progress(current, total):
    print(f"Uploaded: ({current/1000000})/({total/1000000}) MB")

bot = Client(
    "my project",
    api_id=12345678,
    api_hash="",
    bot_token=""
)
print("Uploading...")
with bot:
    bot.send_document(
        chat_id=5042525177,
        document=filename,
        progress=progress
    )
    exit()

bot.run()
exit()
