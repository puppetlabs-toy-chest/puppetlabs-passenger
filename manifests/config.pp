#
class passenger::config (
  $mod_passenger_location = $passenger::params::mod_passenger_location,
  $passenger_root         = $passenger::params::passenger_root,
  $passenger_ruby         = $passenger::params::passenger_ruby,
  $passenger_version      = $passenger::params::passenger_version,
) inherits passenger::params {

  case $::osfamily {
    'debian': {
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
        require => [ File['/etc/apache2/mods-available/passenger.load'], Class['passenger::compile'], ],
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

      file { '/etc/httpd/conf.d/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-conf.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
        notify  => Service['httpd'],
      }
    }
    default:{
      fail("Operating system ${::operatingsystem} is not supported with the Passenger module")
    }
  }

}
