#!/bin/bash
# Run ejabberd docker as a daemon
docker run --name xmppbot-test -d -p 25222:5222 ejabberd/ecs

# Wait few seconds for ejabberd to boot
sleep 5

# Create acounts for admin and xmppbot
docker exec -it xmppbot-test bin/ejabberdctl register admin localhost admintestpassword

docker exec -it xmppbot-test bin/ejabberdctl register xmppbot localhost bottestpassword

# Create MUC rooms for testing
docker exec -it xmppbot-test bin/ejabberdctl create_room testroom1 conference.localhost localhost
docker exec -it xmppbot-test bin/ejabberdctl create_room testroom2 conference.localhost localhost

# Run xmpp mirror bot
python3 ../xmppmirror &

# Run xmpp test bot
python3 testbot

# Stop and remove containter
docker stop xmppbot-test
docker rm xmppbot-test

