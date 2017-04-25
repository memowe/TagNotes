#!/bin/sh

echo "\nModules:"
find lib -name '*.pm' | sort | xargs wc

echo "\nTemplates:"
find templates -name '*.ep' | sort | xargs wc

echo "\nTests:"
find t -type f -not -path 't/test-*' | sort | xargs wc
