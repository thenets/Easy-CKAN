#!/bin/bash

# Dependencies
# ===========================================================
echo "Installing Mocha for front-end tests..."
npm install -g phantomjs@~1.9.1 mocha-phantomjs@3.5.0


# Test Front-end
# ===========================================================


# Import env
EASYCKAN_DEV_MODE=true
SCRIPT_HOME="/etc/easyckan/bin"
source $SCRIPT_HOME/_dependencies

# Start CKAN containers dependences
echo "# Create network and start dependences..."
ckan-dependencies

# Start server
echo ""
echo "# Start EasyCKAN server..."
docker run --net=easyckan --name "ckan-main" --rm -d \
        -v /usr/lib/ckan:/usr/lib/ckan \
        -v /etc/ckan:/etc/ckan \
        -v /var/lib/ckan:/var/lib/ckan \
        -p 5000:5000 \
        easyckan/ckan-dev:$V_CKAN_BASE_VERSION
        
sleep 5 # Make sure the server has fully started

# Run test
mocha-phantomjs http://localhost:5000/base/test/index.html

# Did an error occur?
MOCHA_ERROR=$?

# Did an error occur?
[ "0" -ne "$MOCHA_ERROR" ] && echo MOCHA tests have failed


# Remove all containers
# ===========================================================
docker rm -f $(docker ps -qa)

# Error output to Travis
# ===========================================================
exit `expr $MOCHA_ERROR`