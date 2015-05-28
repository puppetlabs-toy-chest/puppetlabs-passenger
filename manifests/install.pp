class passenger::install {

  package { 'passenger':
    ensure   => $passenger::passenger_version,
    provider => $passenger::package_provider,
  }

  if $passenger::options::package_dependencies {
    package { $passenger::options::package_dependencies:
      ensure => present,
    }
  }

}
