class passenger::install (
  $package_name         = $passenger::params::package_name,
  $package_ensure       = $passenger::params::package_ensure,
  $package_provider     = $passenger::params::package_provider,
  $package_dependencies = $passenger::params::package_dependencies
) inherits passenger::params {

  package { 'passenger':
    ensure   => $package_ensure,
    name     => $package_name,
    provider => $package_provider,
  }

  if $package_dependencies {
    package { $package_dependencies:
      ensure => present,
    }
  }

}
