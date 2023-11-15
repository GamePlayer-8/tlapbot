#!/bin/sh

param_name="$1"
eval "param_value=\$$param_name"

echo "$param_value"
