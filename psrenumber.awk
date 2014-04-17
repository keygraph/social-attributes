# $Id: ~|^` @(#)psrenumber.awk 1.3 2005/05/05 11:36:27 \ $
# Description: awk script to renumber and rearrange pages in a PostScript document containing a TOC at its end produced by troff
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
	npages = 0
	firstmissing = 0
	numbermissing = 0
	cache = ""
	deferred = 0
}

/^%%Pages:/ {
	npages = $2 + 0
	if (!npages)
		deferred = 1
}

/^%%Page:/ {
	n1 = $2 + 0
	n2 = $3 + 0
	if (n1 > n2) {
		if (!firstmissing)
			firstmissing = n2
		if (n1 - n2 > numbermissing)
			numbermissing = n1 - n2
		deferred = 1
	}
	if (n2 > npages - numbermissing) {
		n1 = firstmissing + n2 - npages
		deferred = 0
        }
	if (deferred)
		cache = cache $1 " " n1 " " n1 ORS
	else
		print "%%Page:", n1, n1
	next
}

/^%%Trailer/ {
	print cache
	deferred = 0
	cache = ""
}

{
	if (!deferred)
		print $0
	else
		cache = cache $0 ORS
}
