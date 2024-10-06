import re
import sys

headers = """#import "@preview/algo:0.3.3": algo, i, d, comment, code
#import "@preview/tablex:0.0.8": tablex
#import "@preview/tablem:0.1.0": tablem
// styling
#show link: underline
#set page(background: rect(width: 200%, height: 200%, fill: rgb("#1d1c1b")))
#set text(fill: rgb("#AAAAAA"))
#set line(stroke: rgb("#AAAAAA"))
#set image(width: 50%)
"""

textfile = open(sys.argv[1], 'r')
filetext = textfile.read()
textfile.close()

# Metadata
filetext = re.sub(r"@document.meta(.*?)@end", headers, filetext, re.DOTALL, re.S)
filetext = re.sub(r"@typst(.*?)@end", "\\g<1>", filetext, re.DOTALL, re.S)

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
filetext = re.sub(r"{:[\.|\$](.*?):(.*?)}\[(.*?)\]", "#link(\".\\g<1>\")[_\\g<3>_]", filetext, re.DOTALL, re.S)
# Internet link
filetext = re.sub(r"{(.*?)}\[(.*?)\]", "#link(\"\\g<1>\")[_\\g<2>_]", filetext, re.DOTALL, re.S)
# Header link
filetext = re.sub(r"{\*+ (.*?)}\[(.*?)\]", "_\\g<2>_ (\\g<1>)", filetext, re.DOTALL, re.S)
filetext = re.sub(r"{\*+ (.*?)}", "_\\g<1>_", filetext, re.DOTALL, re.S)

# Reference to file
# filetext = re.sub(r"{# (.*?)\}", "#link(<\\g<1>>)[\\g<1>]", filetext, re.DOTALL, re.S)
filetext = re.sub(r"{# ref-(.*?)\}", "@\\g<1>", filetext, re.DOTALL, re.S)
filetext = re.sub(r"{# (.*?)\}", "#link(\"\\g<1>\")", filetext, re.DOTALL, re.S)

# Ordered list
filetext = re.sub(r"\n( *)~{6}", "\n\\g<1>     +", filetext, re.M)
filetext = re.sub(r"\n( *)~{5}", "\n\\g<1>    +", filetext, re.M)
filetext = re.sub(r"\n( *)~{4}", "\n\\g<1>   +", filetext, re.M)
filetext = re.sub(r"\n( *)~{3}", "\n\\g<1>  +", filetext, re.M)
filetext = re.sub(r"\n( *)~{2}", "\n\\g<1> +", filetext, re.M)
filetext = re.sub(r"\n( *)~", "\n\\g<1>+", filetext, re.M)
# Unordered list
filetext = re.sub(r"\n( *)-{6}", "\n\\g<1>     -", filetext, re.M)
filetext = re.sub(r"\n( *)-{5}", "\n\\g<1>    -", filetext, re.M)
filetext = re.sub(r"\n( *)-{4}", "\n\\g<1>   -", filetext, re.M)
filetext = re.sub(r"\n( *)-{3}", "\n\\g<1>  -", filetext, re.M)
filetext = re.sub(r"\n( *)-{2}", "\n\\g<1> -", filetext, re.M)
filetext = re.sub(r"\n( *)-", "\n\\g<1>-", filetext, re.M)

# Text formatting
# filetext = re.sub(r"/(.*?)/", "_\\g<1>_", filetext, re.DOTALL, re.S)

with open(sys.argv[2], 'w') as f:
    f.write(filetext)
    f.truncate()
