#!/bin/bash
qpdoc.sh $1 |mwaddlevel.sh | \
sed -e '1 i\\n\
=SME Server Information=\
==db variables==\
==templates==\
==contribs==\
==how-tos==\
==bugs==\
'
