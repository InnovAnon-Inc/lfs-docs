#! /usr/bin/env fawk

NF && $1 !~ /^#/        { FLAG=0 }

$1 == "#dump-commands:" { FLAG=1 }

FLAG                    { sub(/^#/,"") }

                        { print }

