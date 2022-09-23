#!/bin/bash

OUTPUT=$(xauth list $DISPLAY)
sudo xauth add $OUTPUT
