#!/usr/bin/env python3
import sys
from string import Template

def insert(template, dest, content_partial, sidebar_partial, css_file):
    with open(content_partial, 'r') as f:
        content = f.read()
    with open(sidebar_partial, 'r') as f:
        sidebar = f.read()
    d = {
            'content': content,
            'sidebar': sidebar,
            'css_file': css_file,
        }
    with open(template, "r") as f:
        src = Template(f.read())
        final = src.substitute(d)
    with open(dest, 'w') as f:
        f.write(final)

if __name__ == '__main__':
    insert(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
