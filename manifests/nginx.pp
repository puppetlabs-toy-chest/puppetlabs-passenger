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
        path    => '/etc/default/nginx',
        line    => 'DAEMON=/usr/local/nginx/sbin/nginx',
        require => Package['nginx'],
        notify  => Service['nginx'],
      }
      $compile_env = 'CC=gcc-4.4'

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

  exec { 'compile-passenger':
    path      => [ $passenger::gem_binary_path, '/usr/bin', '/bin', '/usr/local/bin' ],
    provider  => 'shell',
    command   => "$compile_env passenger-install-nginx-module --auto --auto-download --prefix=/usr/local/nginx",
    logoutput => on_failure,
    creates   => '/usr/local/nginx/sbin/nginx',
    require   => Package['passenger'],
  }
  file { '/etc/nginx':
    ensure  => link,
    target  => '/usr/local/nginx/conf',
    force   => true,
    require => Exec['compile-passenger'],
    notify  => Service['nginx'],
  }
  file { '/usr/local/nginx/conf/http.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Exec['compile-passenger'],
  }
  exec { 'nginx-passenger.conf':
    creates  => '/usr/local/nginx/conf/http.d/00-passenger.conf',
    provider => 'shell',
    command  => 'echo "passenger_root \"$(passenger-config --root)\";" > /usr/local/nginx/conf/http.d/00-passenger.conf',
    require  => File['/usr/local/nginx/conf/http.d'],
    notify   => Service['nginx'],
  }
  file { '/usr/local/nginx/conf/nginx.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/passenger/nginx.conf',
    require => Exec['compile-passenger'],
    notify  => Service['nginx'],
  }
}
