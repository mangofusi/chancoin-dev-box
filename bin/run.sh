#!/bin/sh
docker run -ti --name chandev -P -p 49020:19000 --cap-add=SYS_PTRACE chancoin-dev-box

