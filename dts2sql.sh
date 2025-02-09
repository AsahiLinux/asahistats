#!/bin/sh

grep 'apple,j.*platform' -A1 *.dts | tr -d '\n' | sed -re 's/--/\n/g' | sed -re 's/^.* = "apple,(j[^"]*).*= "([^"]*)".*/'"INSERT INTO devices VALUES ('\1ap', '\2');/g";echo
