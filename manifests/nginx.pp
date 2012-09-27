class passenger::nginx (
  $mod_passenger_location = $passenger::nginx::params::mod_passenger_location,
) inherits passenger::nginx::params {

  include nginx
  include passenger

  case $osfamily {
    'debian': {
      package { [$passenger::params::libruby, 'libcurl4-openssl-dev']:
        ensure => present,
        before => Exec['compile-passenger'],
      }
      package { 'gcc-4.4':
        ensure => present,
        before => Exec['compile-passenger'],
      }
      package { 'g++-4.4':
        ensure  => present,
        before => Exec['compile-passenger'],
      }
      package { 'libstdc++6-4.4-dev':
        ensure  => present,
        before => Exec['compile-passenger'],
      }
      file_line { 'init.d daemon':
        path   => '/etc/default/nginx',
        line   => 'DAEMON=/usr/local/nginx/sbin/nginx',
        match  => '^DAEMON=',
        before => Service['nginx'],
      }
      $compile_env = 'CC=gcc-4.4'

      #file { '/etc/apache2/mods-available/passenger.load':
      #ensure  => present,
      #content => template('passenger/passenger-load.erb'),
      #owner   => '0',
      #group   => '0',
      #mode    => '0644',
      #notify  => Service['httpd'],
      #}

      #file { '/etc/apache2/mods-available/passenger.conf':
      #ensure  => present,
      #content => template('passenger/passenger-enabled.erb'),
      #owner   => '0',
      #group   => '0',
      #mode    => '0644',
      #notify  => Service['httpd'],
      #}

      #file { '/etc/apache2/mods-enabled/passenger.load':
      #ensure  => 'link',
      #target  => '/etc/apache2/mods-available/passenger.load',
      #owner   => '0',
      #group   => '0',
      #mode    => '0777',
      #require => [ File['/etc/apache2/mods-available/passenger.load'], Exec['compile-passenger'], ],
      #notify  => Service['httpd'],
      #}

      #file { '/etc/apache2/mods-enabled/passenger.conf':
        #ensure  => 'link',
        #target  => '/etc/apache2/mods-available/passenger.conf',
        #owner   => '0',
        #group   => '0',
        #mode    => '0777',
        #require => File['/etc/apache2/mods-available/passenger.conf'],
        #notify  => Service['httpd'],
      #}
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

      $compile_env = ''
    }
    default:{
      fail("Operating system ${::operatingsystem} is not supported with the Passenger module")
    }
  }

  exec {'compile-passenger':
    path      => [ $passenger::gem_binary_path, '/usr/bin', '/bin', '/usr/local/bin' ],
    provider  => 'shell',
    command   => "$compile_env passenger-install-nginx-module --auto --auto-download --prefix=/usr/local/nginx",
    logoutput => on_failure,
    creates   => '/usr/local/nginx/sbin/nginx',
    require   => Package['passenger'],
  }
}
