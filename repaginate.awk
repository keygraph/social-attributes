# $Id: ~|^` @(#)repaginate.awk 1.4 2005/05/05 11:36:27 \ $
# Description: rearrange pages of a text document produced by nroff with a TOC at the end
# also remove overstriking
# Copyright (C) 2004, 2005 Bruce Lilly <blilly@erols.com>
# License (zlib/libpng license) 
# This software is provided 'as-is', without any express or implied warranty. In
# no event will the authors be held liable for any damages arising from the
# use of this software.
# 
# Permission is granted to anyone to use this software for any purpose, including
# commercial applications, and to alter it and redistribute it freely, subject
# to the following restrictions:
# 
#    1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
#
#    2. Altered source versions must be plainly marked as such, and must not
#    be misrepresented as being the original software.
#
#    3. This notice may not be removed or altered from any source distribution.
BEGIN {
	RS="\f" # one record per page
	n = 0 # number of pages
}

{	# save page, keep track of highest page number
	temp = $0
	text = $0
        gsub(/.* \[Page /, "", temp)
	if (temp ~ /.*\r\n.*/) # detect CRLF line ending
		ORS = "\r\n"
        gsub(/\][\f\r\n]*/, "", temp)
	if (length(temp) > 4) { # handle pages produced with MM macros in default style
		sub(/.*[ \t]*-[ \t]*/, "", temp)
		gsub(/[ \t]*-[ \t\f\r\n]*.*/, "", temp)
		gsub(/[ \t\f\r\n]*/, "", temp)
	}
        if ((length(temp) < 1) || (length(temp) > 4)) # handle unpaginated input
		temp = n + 1
	pnum = temp + 0 # page number
	# remove overstrking
	gsub(/\b_/, "", text) # prefer text to underscoring
	gsub(/.\b/, "", text) # remove overstriking
	page[pnum] = text
        if (pnum > n)
		n = pnum
}

END {	# output pages in order
	rslen = length(ORS)
	for (i=1; i<=n; i++) {
		printf "%s\f", page[i]
		if ((i<n) && substr(page[i+1], 1, rslen) != ORS)
			printf ORS
        }
	printf ORS # (default) newline or CRLF at end
}
