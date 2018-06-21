#!/bin/bash

su - elasticsearch -s /bin/bash -c "/usr/share/elasticsearch/bin/elasticsearch -Enetwork.host=0.0.0.0"