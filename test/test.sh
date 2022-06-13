#!/bin/bash
# Check if docker is installed
if ! command -v docker run &> /dev/null
then
    echo "No docker detected. If you are running debian based system, you can install docker with"
    echo "sudo apt install docker.io
    exit
fi

echo "Docker detected"

# Run ejabberd docker as a daemon
echo "Starting ejabberd docker container"
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
echo "Running xmpp mirror bot"
python3 ../xmppmirror & XMPPMIRRORPID=$!

# Run xmpp test bot
echo "Running test bot"
python3 testbot & TESTBOTPID=$!

# Wait for bots to connect
sleep 10

# Wait certain amount of time for every test message in the file
for i in $(cat testmsgs.txt); do sleep 5; done

# Kill bots
if ps -p $XMPPMIRRORPID > /dev/null
then
    echo "Killing xmpp mirror bot"
    kill $XMPPMIRRORPID
fi

if ps -p $TESTBOTPID > /dev/null
then
    echo "Killing test bot"
    kill $TESTBOTPID
fi

# Stop and remove containter
echo "Stopping and removing docker container"
docker stop xmppbot-test
docker rm xmppbot-test

