#!/bin/bash

$(which aws) configure set aws_access_key_id "${accesskey}" --profile "${profilename}"
$(which aws) configure set aws_secret_access_key "${secretkey}" --profile "${profilename}"