import re
import sys
from datetime import datetime

# Default header stuff that import algorithm environment and set styling.
headers = """#import "@preview/algo:0.3.6": algo, i, d, comment, code; #import "@preview/tablex:0.0.8": tablex; #import "@preview/tablem:0.1.0": tablem;
#show link: underline
#set page(background: rect(width: 200%, height: 200%, fill: rgb("#1d1c1b")))
#set text(fill: rgb("#AAAAAA"))
#set line(stroke: rgb("#AAAAAA"))
#set image(width: 50%);
#let definition(body) = block( fill:rgb("#3d3c3b"), width: 100%, inset:8pt, radius: 4pt, body)
#let theorem(body) = block( fill:rgb("#3d3c3b"), width: 100%, inset:8pt, radius: 4pt, body)
#let highlight_block(body) = block( fill:rgb("#3d3c3b"), width: 100%, inset:8pt, radius: 4pt, body)
"""

textfile = open(sys.argv[1], 'r')
filetext = textfile.read()
textfile.close()

# ***** Parse header data for document title *****
tit = re.search(r"title: (.*?)\n", filetext)
desc = re.search(r"description: (.*?)\n", filetext)
# TODO: there could be multiple authors
auth = re.search(r"authors: (.*?)\n", filetext)
cats = re.search(r"categories: \[\n(.*?)\]", filetext, re.S)
cat = re.search(r"categories: (.*?)\n", filetext)
creat = re.search(r"created: (.*?)\n", filetext)
updat = re.search(r"updated: (.*?)\n", filetext)
ver = re.search(r"version: (.*?)\n", filetext)
title = ""
description = ""
author = ""
categories = []
created = ""
updated = ""
version = ""

if tit:
    title = tit.group(1)
if desc:
    description = desc.group(1)
if auth:
    author = auth.group(1)
if cats:
    cats = map(lambda x: x.strip(), cats.group(1).splitlines())
    categories = cats
else:
    if cat:
        categories.append(cat.group(1))
if creat:
    date = datetime.strptime(creat.group(1),"%Y-%m-%dT%H:%M:%S%z")
    d = date.date()
    t = date.time()
    created = date.strftime("Luotu %d.%m.%Y %H:%M:%S")
if updat:
    date = datetime.strptime(updat.group(1),"%Y-%m-%dT%H:%M:%S%z")
    d = date.date()
    t = date.time()
    updated = date.strftime("Päivitetty %d.%m.%Y %H:%M:%S")
if ver:
    version = ver.group(1)

# Metadata
filetext = re.sub(r"@document.meta(.*?)@end", "", filetext, re.DOTALL, re.S)

# Typst environments
filetext = re.sub(r"@typst(.*?)@end", "\\g<1>", filetext, re.DOTALL, re.S)
# My custom block for highlighting, though prefer using definition nowadays
filetext = re.sub(r"@tblock(.*?)@end", "#highlight_block[\\g<1>]", filetext, re.DOTALL, re.S)

# Definition
filetext = re.sub(r"\$\$ (.*?)\n(.*?)\$\$", "#definition[#strong[\\g<1>]\n\\g<2>]", filetext, re.DOTALL, re.S)

# Ranged tags 
filetext = re.sub(r"@math(.*?)@end", "$\\g<1>$", filetext, re.DOTALL, re.S)
filetext = re.sub(r"@table(.*?)\n@end", "#tablem[\\g<1>\n]", filetext, re.DOTALL, re.S)
filetext = re.sub(r"@data(.*?)@end", "```\\g<1>```", filetext, re.DOTALL, re.S)
filetext = re.sub(r"@code (.*?)\n(.*?)@end", "```\\g<1>\n\\g<2>```", filetext, re.DOTALL, re.S)
filetext = re.sub(r"@image\n(.*?)\n@end", "#image(\\g<1>)", filetext)

# Headers, manually add newlines since ^ and $ with multiline flag does not work
filetext = re.sub(r"\n\*{6} (.*)", "\n====== \\g<1>", filetext)
filetext = re.sub(r"\n\*{5} (.*)", "\n===== \\g<1>", filetext)
filetext = re.sub(r"\n\*{4} (.*)", "\n==== \\g<1>", filetext)
filetext = re.sub(r"\n\*{3} (.*)", "\n=== \\g<1>", filetext)
filetext = re.sub(r"\n\*{2} (.*)", "\n== \\g<1>", filetext)
filetext = re.sub(r"\n\* (.*)", "\n= \\g<1>", filetext)

# File link
filetext = re.sub(r"^\$\[(.*?)\]{(.*?)}", "[\\g<1>]", filetext, re.DOTALL, re.S)
filetext = re.sub(r"{:[\.|\$](.*?):(.*?)}\[(.*?)\]", "#link(\".\\g<1>\")[_\\g<3>_]", filetext, re.DOTALL, re.S)
# Header link
filetext = re.sub(r"^\${\*+ (.*?) }\[(.*?)\]", "_\\g<2>_ (\\g<1>)", filetext, re.DOTALL, re.S)
filetext = re.sub(r"^\$\[(.*?)\]{\*+ (.*?)}", "_\\g<1>_ (\\g<2>)", filetext, re.DOTALL, re.S)
filetext = re.sub(r"{\*+ (.*?)}", "_\\g<1>_", filetext, re.DOTALL, re.S)
# Internet link
filetext = re.sub(r"^\${(.*?)}\[(.*?)\]", "#link(\"\\g<1>\")[_\\g<2>_]", filetext, re.DOTALL, re.S)

# Reference to file
# filetext = re.sub(r"{# (.*?)\}", "#link(<\\g<1>>)[\\g<1>]", filetext, re.DOTALL, re.S)
filetext = re.sub(r"{# ref-(.*?)\}", "@\\g<1>", filetext, re.DOTALL, re.S)
filetext = re.sub(r"{# (.*?)\}", "#link(\"\\g<1>\")", filetext, re.DOTALL, re.S)

# Ordered list
filetext = re.sub(r"\n( *?)~{6}", "\n\\g<1>     +", filetext, re.M)
filetext = re.sub(r"\n( *?)~{5}", "\n\\g<1>    +", filetext, re.M)
filetext = re.sub(r"\n( *?)~{4}", "\n\\g<1>   +", filetext, re.M)
filetext = re.sub(r"\n( *?)~{3}", "\n\\g<1>  +", filetext, re.M)
filetext = re.sub(r"\n( *?)~{2}", "\n\\g<1> +", filetext, re.M)
filetext = re.sub(r"\n( *?)~", "\n\\g<1>+", filetext, re.M)
# Unordered list
filetext = re.sub(r"\n( *)-{6}", "\n\\g<1>     -", filetext, re.M)
filetext = re.sub(r"\n( *)-{5}", "\n\\g<1>    -", filetext, re.M)
filetext = re.sub(r"\n( *)-{4}", "\n\\g<1>   -", filetext, re.M)
filetext = re.sub(r"\n( *)-{3}", "\n\\g<1>  -", filetext, re.M)
filetext = re.sub(r"\n( *)-{2}", "\n\\g<1> -", filetext, re.M)
# filetext = re.sub(r"\n( *)-", "\n\\g<1>-", filetext, re.M)

# Text formatting
# filetext = re.sub(r"/(.*?)/", "_\\g<1>_", filetext, re.DOTALL, re.S)

meta = f'{author} \\\n{created} \\\n{updated} \\\n'
meta = meta + f'#align(center, [#block(text(weight: 700, 1.75em, "{title}"))])\n'
meta = meta + f'#pad(top: 0.5em, align(center, strong("{description}")))\n'
filetext = headers + meta + filetext

with open(sys.argv[2], 'w') as f:
    f.write(filetext)
    f.truncate()
