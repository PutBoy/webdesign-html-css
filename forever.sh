#!/bin/bash
while :
    do
      sleep 5s
      echo "y" | ruby generator.rb blog generated >/dev/null
done
