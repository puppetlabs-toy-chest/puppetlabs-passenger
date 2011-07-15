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
  case $operatingsystem {
    'ubuntu', 'debian': {
      file { '/etc/apache2/mods-available/passenger.load':
        ensure  => present,
        content => template('passenger/passenger-load.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }

      file { '/etc/apache2/mods-available/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-enabled.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }

      file { '/etc/apache2/mods-enabled/passenger.load':
        ensure  => 'link',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => File['/etc/apache2/mods-available/passenger.load'],
      }

      file { '/etc/apache2/mods-enabled/passenger.conf':
        ensure  => 'link',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => File['/etc/apache2/mods-available/passenger.conf'],
      }
    }
    'centos', 'fedora', 'redhat': {
      file { '/etc/httpd/conf.d/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-conf.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }
    }
    'darwin':{}
  }

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
