#!/bin/sh

docker ps --format "table {{.Names}}\t{{.Ports}}"
