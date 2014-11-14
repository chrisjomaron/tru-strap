#!/usr/bin/python
#
# Simple script to convert dockerenv file to linux profile.
#

import shlex

DOCKER_RUN_FILE = '/.dockerenv'
DOCKER_ENV_FILE = '/etc/profile.d/dockerenv.sh'

print "Processing", DOCKER_RUN_FILE
with open (DOCKER_RUN_FILE , "r") as dockerfile:
    data=dockerfile.read().replace('\n', '')

if data[0] != '[':
  print DOCKER_RUN_FILE, " file does not look valid!"
  exit(-1)

data = data[1:-1]

lexer = shlex.shlex(data)
lexer.quotes = '"'

with open(DOCKER_ENV_FILE, "w") as text_file:
  for token in lexer:
    if token.startswith('"'):
      text_file.write(token.replace('"','') + '\n')

print "Written", DOCKER_ENV_FILE



