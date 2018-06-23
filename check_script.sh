#!/bin/bash

if pkill -0 haproxy;then
 exit 0
else
 exit 1

fi
