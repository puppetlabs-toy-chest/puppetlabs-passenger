# Class: passenger
#
# This class installs passenger
#
# Parameters:
#
# Actions:
#   - Install passenger gem
#   - Compile passenger module
#
# Requires:
#   - ruby::dev
#   - gcc
#   - apache::dev
#
# Sample Usage:
#
class passenger {
  include passenger::params
  require ruby::dev
  require gcc
  require apache::dev
  $version=$passenger::params::version

  package {'passenger':
    name   => 'passenger',
    ensure => $version,
    provider => 'gem',
  }

  exec {'compile-passenger':
    path => [ $passenger::params::gem_binary_path, '/usr/bin', '/bin'],
    command => 'passenger-install-apache2-module -a',
    logoutput => true,
    creates => $passenger::params::mod_passenger_location,
    require => Package['passenger'],
  }
}
