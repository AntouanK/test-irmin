#!/bin/bash

set -e;

docker build -t antouank/irmin . ;

docker stop irmin && docker rm irmin; 

docker run \
    -d \
    --name irmin \
    --network host \
    antouank/irmin;

#or -p 9876:9876 \
