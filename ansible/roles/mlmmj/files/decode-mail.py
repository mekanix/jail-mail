#!/usr/bin/env python

import quopri
import sys
import email

class Message:
    def __init__(self, message):
        subject = message.get('Subject', '')
        self.id = message.get('Message-ID', '')
        self.from_address = message.get('From', '')
        self.to_address = message.get('To', '')
        self.subject = subject
        self.date = message.get('Date', '')
        self.topic = message.get('Thread-Topic', subject)
        self.index = message.get('Thread-Index', '')
        self.type = message.get('Content-Type', 'text')
        self.encoding = message.get('Content-Transfer-Encoding', '8bit')

def printPayload(payload, boundary):
    if type(payload) == str:
        print(payload, end="")
    elif payload.is_multipart():
        b = payload.get_boundary() or boundary
        print(f'--{b}')
        for item in payload.items():
            print(f'{item[0]}: {item[1]}')
        print()
        for p in payload.get_payload():
            printPayload(p, b or boundary)
    elif payload.get_content_maintype() == 'text':
        print(f'--{boundary}')
        for item in payload.items():
            print(f'{item[0]}: {item[1]}')
        print()
        p = payload.get_payload()
        print(quopri.decodestring(p).decode())

# Get email from pipe
data = ''
while True:
    try:
        data += input() + '\n'
    except EOFError:
        break

# Convert string to message
email_message = email.message_from_string(data)
message = Message(email_message)

# Print headers
print(f'From: {message.from_address}')
print(f'To: {message.to_address}')
print(f'Date: {message.date}')
print(f'Subject: {message.subject}')
print(f'Thread-Topic: {message.topic}')
print(f'Thread-Index: {message.index}')
print(f'Content-Type: {message.type}')
print(f'Content-Transfer-Encoding: {message.encoding}')
print(f'Message-ID: {message.id}')
print()

# Print non-attachment payloads
for p in email_message.get_payload():
    printPayload(p, email_message.get_boundary())
