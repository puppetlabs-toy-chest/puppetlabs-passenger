class passenger::compile (
  $gem_binary_path        = $passenger::params::gem_binary_path,
  $mod_passenger_location = $passenger::params::mod_passenger_location
) inherits passenger::params {

  exec {'compile-passenger':
    path      => [ $gem_binary_path, '/usr/bin', '/bin', '/usr/local/bin' ],
    command   => 'passenger-install-apache2-module -a',
    logoutput => on_failure,
    creates   => $mod_passenger_location,
  }

}
