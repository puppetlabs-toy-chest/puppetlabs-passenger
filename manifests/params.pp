# Class: passenger::params
#
# This class manages parameters for the Passenger module
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class passenger::params {
  $passenger_version  = '3.0.9'
  $passenger_ruby     = '/usr/bin/ruby'
  $passenger_provider = 'gem'

  case $::osfamily {
    'debian': {
      $passenger_package      = 'passenger'
      $gem_path               = '/var/lib/gems/1.8/gems'
      $gem_binary_path        = '/var/lib/gems/1.8/bin'
      $mod_passenger_location = "/var/lib/gems/1.8/gems/passenger-$passenger_version/ext/apache2/mod_passenger.so"

      # Ubuntu does not have libopenssl-ruby - it's packaged in libruby
      if $::lsbdistid == 'Debian' and $::lsbmajdistrelease <= 5 {
        $libruby              = 'libopenssl-ruby'
      } else {
        $libruby              = 'libruby'
      }
    }
    'redhat': {
      $passenger_package      = 'passenger'
      $gem_path               = '/usr/lib/ruby/gems/1.8/gems'
      $gem_binary_path        = '/usr/lib/ruby/gems/1.8/gems/bin'
      $mod_passenger_location = "/usr/lib/ruby/gems/1.8/gems/passenger-$passenger_version/ext/apache2/mod_passenger.so"
    }
    'darwin':{
      $passenger_package      = 'passenger'
      $gem_path               = '/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin'
      $gem_binary_path        = '/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin'
      $mod_passenger_location = "/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/passenger-$passenger_version/ext/apache2/mod_passenger.so"
    }
    default: {
      fail("Operating system ${::operatingsystem} is not supported with the Passenger module")
    }
  }
}
