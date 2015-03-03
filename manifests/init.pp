# == Class: papertrail
#
# Module to manage papertrail
#
class papertrail (
  $cert_md5sum     = 'c75ce425e553e416bde4e412439e3d09',
  $cert_path       = '/etc/papertrail-bundle.pem',
  $cert_uri        = 'https://papertrailapp.com/tools/papertrail-bundle.pem',
  $include_rsyslog = true,
  $md5_path        = '/bin:/usr/bin:/sbin:/usr/sbin',
  $wget_path       = '/bin:/usr/bin:/sbin:/usr/sbin',
) {

  validate_string($cert_md5sum)
  validate_string($cert_uri)
  validate_absolute_path($cert_path)
  validate_string($md5_path)
  validate_string($wget_path)

  if is_string($include_rsyslog) == true {
    $include_rsyslog_real = str2bool($include_rsyslog)
  } else {
    $include_rsyslog_real = $include_rsyslog
  }
  validate_bool($include_rsyslog_real)

  if $include_rsyslog_real == true {
    include rsyslog
  }

  include wget

  common::remove_if_empty { $cert_path: }

  exec { 'wget_papertrail_cert':
    command => "wget ${cert_uri} -O ${cert_path}",
    creates => $cert_path,
    path    => $wget_path,
    notify  => Exec['verify_papertrail_cert_md5'],
    require => Common::Remove_if_empty[$cert_path],
  }

  file { 'papertrail_cert':
    ensure  => 'file',
    path    => $cert_path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Exec['wget_papertrail_cert'],
  }

  file { 'papertrail_cert_md5':
    ensure  => 'file',
    path    => "${cert_path}.md5",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${cert_md5sum}  ${cert_path}\n",
  }

  exec { 'verify_papertrail_cert_md5':
    command     => "md5sum -c ${cert_path}.md5",
    path        => $md5_path,
    refreshonly => true,
    subscribe   => File['papertrail_cert_md5'],
  }
}
