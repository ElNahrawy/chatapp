#!/bin/bash

./bin/rails db:migrate
./bin/rails searchkick:reindex CLASS=Message
./bin/rails server --binding 0.0.0.0 -e development