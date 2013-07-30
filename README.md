# Script to cleanup your PHP configuration

## Introduction 

This is a `AWK` script that **cleans** your PHP
configuration. Cleaning here means that the settings are supposed to
be sane for either a **production** or **development**
enviroment. There are slight differences between the configuration for
both settings. Namely the runtime parameter that allows the errors to
be displayed on the site.

Displaying the errors is something that is **useful** in a development
environment it makes sense to have the errors being displayed. In a
production or staging environment it doesn't. It's a **information
disclosure** vulnerability. It reveals a lot of, potentially:

 + the path where the your PHP scripts are installed;
 
 + which PHP extensions you have enabled/disabled;
 
 + which setup you use to run your site.
 
 The path disclosure vulnerability opens up the door for
 [path traversal exploits](https://secure.wikimedia.org/wikipedia/en/wiki/Path_traversal)
 which can compromise not only the specific site but also other sites
 which may be hosted on the same machine.
 
## Which PHP settings are altered and why?

 The following settings are altered:
 
  1. **Error logging** &mdash; for **production/staging** environments
     log all errors on `syslog`; for **development** environments log
     the errors on the web client.
     
     
  2. **PHP exposition**: don't expose that you're running PHP and
     which version you're running.
      
  3. **zlib compression** and **compression level**: if available use
     `zlib` with compression level `1`.
     
  4. **memory limit**: a generous **512 MB**.
  
  5. **POST** and **upload** maximum sizes. Assuming that the there
     are things in the site, like drupal nodes or any other unit of
     content, that have two attachments in average, then limit the
     size of each upload to the maximum memory size, just in case
     there's buffering of this data by PHP.
     
  6. **cgi.fix\_pathinfo** set to **0**. Do not translate the
     `PATHINFO` components automagically. This has been a source of
     repeated p0wnage out there, Drupal doesn't use PATHINFO, but
     WordPress does. Please do not rely on a _lazy bastard_ technique
     to have your site working. Instead use the proper config with
     your web server and/or CGI/FastCGI handling.
     
  7. Do not allow for `fopen` or `include` to open files specified
     through a URI. Only files in the the filesystem that the web
     server and or the FastCGI handling infrastructure can see. Don't
     ever use **external** resources or allow them to be specified
     through a URL.
     
  8. Don't allow for manipulation of
     [cookies](http://www.owasp.org/index.php/HTTPOnly "OWASP on
     HttpOnly") through the DOM, i.e., JavaScript manipulation of
     cookies. All modern browsers support the `HttpOnly` flag. IE6, 7
     and 8 also support it.
     
  9. Setup additional entropy for session token generation using the
     hardware random number generator `/dev/urandom`. This requires
     PHP 5.3 or later.
     
## Installation and Usage
 
To use this script(s) do the following:
 
  1. Just clone the git repo or download a snaphost.
    
  2. Run the shell script `php_cleanup`. It accepts one **mandatory**
     and two **optional** arguments:
     
     a) The **first** argument specifies if we are cleaning up a
        **production** or a **development** environment.
     
     b) The **second** argument specifies the memory limit for PHP. By
        default is 512M.
     
     c) The **last** argument specifies the filename of the PHP
        runtime control file. `php.ini` (or similar) file to cleanup.
        By default it assumes that the PHP runtime configuration 
        is `php.ini` and is in the current directory.
        
        
### Usage Examples
  
  1. Cleanup a production site, running the script on the directory of
     `php.ini`:
      
         php_cleanup -p
      
  2. Cleanup a development site, running the script on the directory
     of `php.ini`:
  
         php_cleanup -d
     
     
  3. Cleanup a production site with [PHP FPM](http://php-fpm.org),
     running the script from an arbitrary directory (assuming the PHP
     filesystem layout of debian):
     
         php_cleanup -p /etc/php5/fpm/php.ini

  4. Cleanup a production site with [PHP FPM](http://php-fpm.org),
     running the script from an arbitrary directory (assuming the PHP
     filesystem layout of debian) and set the memory limit to 2G:
     
         php_cleanup -p -m 2G /etc/php5/fpm/php.ini
