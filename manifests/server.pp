# == Class: newrelic::server
#
# This class installs and configures NewRelic server monitoring.
#
# === Parameters
#
# [*newrelic_service_enable*]
#   Specify the service startup state. Defaults to true. Possible value is false.
#
# [*newrelic_service_ensure*]
#   Specify the service running state. Defaults to 'running'. Possible value is 'stopped'.
#
# [*newrelic_package_ensure*]
#   Specify the package update state. Defaults to 'present'. Possible value is 'latest'.
#
# [*newrelic_license_key*]
#   Specify your Newrelic License Key.
#
# === Variables
#
# === Examples
#
#  newrelic::server {
#    'serverXYZ':
#      newrelic_license_key    => 'your license key here',
#      newrelic_package_ensure => 'latest',
#      newrelic_service_ensure => 'running',
#  }
#
# === Authors
#
# Felipe Salum <fsalum@gmail.com>
#
# === Copyright
#
# Copyright 2012 Felipe Salum, unless otherwise noted.
#
define newrelic::server (
  $newrelic_license_key    = '',
  $newrelic_package_ensure = 'present',
  $newrelic_service_enable = true,
  $newrelic_service_ensure = 'running',
) {

  include newrelic

  $newrelic_package_name = $newrelic::params::newrelic_package_name
  $newrelic_service_name = $newrelic::params::newrelic_service_name

  file { "/opt/newrelic-sysmond_${newrelic_package_ensure}_amd64.deb":
    ensure => present,
    source   => "puppet:///global/newrelic-sysmond_${newrelic_package_ensure}_amd64.deb",
    mode    => 755,
    owner   => "root",
    group   => "root",
  }

  package { $newrelic_package_name:
    ensure   => installed,
    notify   => Service[$newrelic_service_name],
    provider => dpkg,
    source   => "/opt/newrelic-sysmond_${newrelic_package_ensure}_amd64.deb",
    require  => [ Class['newrelic::params'], File["/opt/newrelic-sysmond_${newrelic_package_ensure}_amd64.deb"] ],
  }

  service { $newrelic_service_name:
    ensure     => $newrelic_service_ensure,
    enable     => $newrelic_service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Exec[$newrelic_license_key],
  }

  exec { $newrelic_license_key:
    path        => '/bin:/usr/bin',
    command     => "/usr/sbin/nrsysmond-config --set license_key=${newrelic_license_key}",
    user        => 'root',
    group       => 'root',
    unless      => "cat /etc/newrelic/nrsysmond.cfg | grep ${newrelic_license_key}",
    require     => Package[$newrelic_package_name],
    notify      => Service[$newrelic_service_name],
  }

}
