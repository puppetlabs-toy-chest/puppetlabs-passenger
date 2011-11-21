class passenger::config::debian {
  file {'/etc/apache2/mods-available/passenger.conf':
    name    => '/etc/apache2/mods-available/passenger.conf',
    source  => 'puppet:///modules/passenger/passenger.conf',
    require => [ Package[$apache::params::apache_name], Exec['compile-passenger'] ],
    notify  => Service['httpd']
  }

  file {'/etc/apache2/mods-available/passenger.load':
    name    => '/etc/apache2/mods-available/passenger.load',
    content => template('passenger/passenger.load.erb'),
    require => [ Package[$apache::params::apache_name], Exec['compile-passenger'] ],
    notify  => Service['httpd']
  }

  a2mod {'passenger':
    ensure  => present,
    require => [ File['/etc/apache2/mods-available/passenger.conf'], File['/etc/apache2/mods-available/passenger.load'] ],
    notify  => Service['httpd']
  }

  file {"${apache::params::vdir}/puppetmasterd":
    ensure  => present,
    content => template('passenger/puppetmasterd.vhost'),
    require => [ File['/etc/apache2/mods-available/passenger.conf'], File['/etc/apache2/mods-available/passenger.load'] ],
    notify  => Service['httpd']
  }
  
  file {['/etc/puppet/rack', '/etc/puppet/rack/public']: ensure => directory }

  file {"/etc/puppet/rack/config.ru":
    ensure  => present,
    owner   => 'puppet',
    source  => 'puppet:///modules/passenger/config.ru',
    require => File['/etc/puppet/rack']
  }
}
