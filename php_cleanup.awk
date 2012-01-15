#!/usr/bin/awk -f
# php_cleanup.awk --- This file contains a script that tunes a given
# PHP configuration for security.

# Copyright (C) 2011 António P. P. Almeida <appa@perusio.net>

# Author: António P. P. Almeida <appa@perusio.net>

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# Except as contained in this notice, the name(s) of the above copyright
# holders shall not be used in advertising or otherwise to promote the sale,
# use or other dealings in this Software without prior written authorization.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

## Skip the first error log setting to avoid duplicates.
/^error_log.*\.log$/ {next}

## Ditto for display_errors.
/^;display_errors.*err/ {print; next}

## Don't reveal you're running PHP too easily.
/^;*expose_php/ {print "expose_php = Off"; next}

## Display errors only on development environments.
/^[; ]*display_errors/ {if (is_prod) print "display_errors = Off"; else print "display_errors = On"; next}

## On a production environment use syslog for logging.
/^;error_log[ ]*=.*log/ {if (is_prod) print "error_log = syslog"}

## Use zlib compression for the PHP scripts.
/^;*zlib.output_compression_level/ {print "zlib.output_compression_level = 1"; next}
/^;*zlib.output_compression/  {print "zlib.output_compression = On"; next}

## Resources for POST and memory.
/^memory_limit/ {print "memory_limit = 512M"; next}
/^post_max_size/ {print "post_max_size = 1024M"; next}
/^upload_max_filesize/ {print "upload_max_filesize = 512M"; next}

## CGI fix PATHINFO.
/^;[ ]+cgi.fix_pathinfo[ ]*=/ {print "cgi.fix_pathinfo = 0"; next}

## Fopen wrappers.
/^allow_url_fopen/ {print "allow_url_fopen = Off"; next}
/^allow_url_include/ {print "allow_url_include = Off"; next}

## No cookie handling with JS on the client.
/session.cookie_httponly/ {print "session.cookie_httponly = 1"; next}

## Add entropy to the session token generation mechanism using the
## hardware random number generator. Only available on PHP 5.3 and later.
/^session.entropy_length[ ]+=[ ]+0/ {
    printf("; This requires PHP 5.3 or later.\nsession.entropy_length = 32\n")
    next
}
/^;session.entropy_file[ ]+=.*/ {print "session.entropy_file = /dev/urandom"; next}

{print}
