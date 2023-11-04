#!/bin/bash

if [ -f config.yaml ]; then
  # Show a warning and ask the user if they want to continue
  read -p "The config file already exists. Do you still want to continue? (Y/n) " -r
  case $REPLY in
        [Yy]* )
            cp config-example.yaml config.yaml
            echo "Copied config-example.yaml to config.yaml."
            ;;
        [Nn]* )
            exit
            ;;
        * )
            echo "Please answer yes or no."
            ;;
  esac
else
  # If the config file does not exist, copy the example config file
  cp config-example.yaml config.yaml
  echo "Config file does not exist. Copied config-example.yaml to config.yaml."
fi