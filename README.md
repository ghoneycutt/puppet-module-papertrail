# puppet-module-papertrail
===

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-papertrail.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-papertrail)

Manage papertrail, specifically the installation of the certificate needed for logging with TLS.

===

# Compatibility
---------------
This module is built for use with Puppet v3 (with and without the future
parser) and Puppet v4 with Ruby versions 1.8.7, 1.9.3, 2.0.0 and 2.1.0 on the
following platforms.

* Debian 6
* EL 5
* EL 6
* EL 7
* Suse 10
* Suse 11
* Suse 12
* Solaris 10
* Solaris 11
* Ubuntu 12.04
* Ubuntu 14.04

===

# Parameters
------------

cert_md5sum
-----------
MD5 hash of the certificate from papertrail.

- *Default*: 'c75ce425e553e416bde4e412439e3d09'

cert_path
---------
Path to the certificate.

- *Default*: '/etc/puppet/papertrail-bundle.pem'

cert_uri
--------
URI to where cerificate may be obtained with the use of wget.

- *Default*: 'https://papertrailapp.com/tools/papertrail-bundle.pem'

include_rsyslog
---------------
Boolean to determine if the class 'rsyslog' will be included.

- *Default*: true

md5_path
--------
Path statement for where to find `md5sum`.

- *Default*: '/bin:/usr/bin:/sbin:/usr/sbin'

wget_path
--------
Path statement for where to find `wget`.

- *Default*: '/bin:/usr/bin:/sbin:/usr/sbin'
