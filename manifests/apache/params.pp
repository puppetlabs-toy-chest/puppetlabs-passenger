class passenger::apache::params {
  include passenger

  case $osfamily {
    'debian': {
      $mod_passenger_location = "/var/lib/gems/1.8/gems/passenger-${passenger::passenger_version}/ext/apache2/mod_passenger.so"
    }
    'redhat': {
      $mod_passenger_location = "/usr/lib/ruby/gems/1.8/gems/passenger-${passenger::passenger_version}/ext/apache2/mod_passenger.so"
    }
    'darwin':{
      $mod_passenger_location = "/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/passenger-${passenger::passenger_version}/ext/apache2/mod_passenger.so"
    }
    default: {
      fail("Operating system ${::operatingsystem} is not supported with passenger::apache")
    }
  }
}
