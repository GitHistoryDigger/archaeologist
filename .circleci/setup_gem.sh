#!/bin/sh

mkdir ~/.gem
echo -e "---\r\n:rubygems_api_key: ${GEM_KEY}" > ~/.gem/credentials
chmod 0600 ~/.gem/credentials