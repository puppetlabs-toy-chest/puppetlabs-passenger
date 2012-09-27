class passenger::apache (
  $mod_passenger_location = $passenger::params::mod_passenger_location,
) inherits passenger::apache::params {

  include apache
  require apache::mod::dev
  include passenger

  case $osfamily {
    'debian': {
      package { [$passenger::params::libruby, 'libcurl4-openssl-dev']:
        ensure => present,
        before => Exec['compile-passenger'],
      }

      file { '/etc/apache2/mods-available/passenger.load':
        ensure  => present,
        content => template('passenger/passenger-load.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
        notify  => Service['httpd'],
      }

      file { '/etc/apache2/mods-available/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-enabled.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
        notify  => Service['httpd'],
      }

      file { '/etc/apache2/mods-enabled/passenger.load':
        ensure  => 'link',
        target  => '/etc/apache2/mods-available/passenger.load',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => [ File['/etc/apache2/mods-available/passenger.load'], Exec['compile-passenger'], ],
        notify  => Service['httpd'],
      }

      file { '/etc/apache2/mods-enabled/passenger.conf':
        ensure  => 'link',
        target  => '/etc/apache2/mods-available/passenger.conf',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => File['/etc/apache2/mods-available/passenger.conf'],
        notify  => Service['httpd'],
      }
    }
    'redhat': {
      package { 'libcurl-devel':
        ensure => present,
        before => Exec['compile-passenger'],
      }

      file { '/etc/httpd/conf.d/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-conf.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }
    }
    default:{
      fail("Operating system ${::operatingsystem} is not supported with the Passenger module")
    }
  }

  exec {'compile-passenger':
    path      => [ $passenger::gem_binary_path, '/usr/bin', '/bin', '/usr/local/bin' ],
    command   => 'passenger-install-apache2-module -a',
    logoutput => on_failure,
    creates   => $mod_passenger_location,
    require   => Package['passenger'],
  }
}
