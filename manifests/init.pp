# Class: passenger
#
# This class installs Passenger (mod_rails) on your system.
# http://www.modrails.com
#
# Parameters:
#   [*passenger_version*]       - The Version of Passenger to be installed
#   [*gem_path*]                - Rubygems path on your system
#   [*gem_binary_path*]         - Path to Rubygems binaries on your system
#   [*mod_passenger_location*]  - Path to Passenger's mod_passenger.so file
#   [*passenger_provider*]      - The package provider to install Passenger
#   [*passenger_package*]       - The name of the Passenger package
#
# Actions:
#   - Install passenger gem
#   - Compile passenger module
#
# Requires:
#   - gcc
#   - apache::dev
#
# Sample Usage:
#
class passenger (
  $passenger_version      = $passenger::params::passenger_version,
  $gem_path               = $passenger::params::gem_path,
  $gem_binary_path        = $passenger::params::gem_binary_path,
  $mod_passenger_location = $passenger::params::mod_passenger_location,
  $passenger_provider     = $passenger::params::passenger_provider,
  $passenger_package      = $passenger::params::passenger_package
) inherits passenger::params {

  class { 'gcc': }
  class { 'apache': }
  class { 'apache::dev': }

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
    name     => $passenger_package,
    ensure   => $passenger_version,
    provider => $passenger_provider,
  }

  exec {'compile-passenger':
    path      => [ $gem_binary_path, '/usr/bin', '/bin'],
    command   => 'passenger-install-apache2-module -a',
    logoutput => on_failure,
    creates   => $mod_passenger_location,
    require   => Package['passenger'],
  }

  Class ['gcc']
  -> Class['apache::dev']
  -> Package <| title == 'rubygems' |>
  -> Package['passenger']
  -> Exec['compile-passenger']
}
