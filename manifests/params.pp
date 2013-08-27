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
  $passenger_version  = '3.0.9' # '4.0.10'
  $passenger_ruby     = '/usr/bin/ruby'
  $passenger_provider = 'gem'
  
  if versioncmp ($passenger_version, '4.0.0') > 0 {
    $builddir     = 'buildout'
  } else {
    $builddir     = 'ext'
  }

  case $::osfamily {
    'debian': {
      $passenger_package      = 'passenger'
      $gem_path               = '/var/lib/gems/1.8/gems'
      $gem_binary_path        = '/var/lib/gems/1.8/bin'
      $passenger_root         = "/var/lib/gems/1.8/gems/passenger-${passenger_version}"
      $mod_passenger_location = "${passenger_root}/${builddir}/apache2/mod_passenger.so"

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
      $passenger_root         = "/usr/lib/ruby/gems/1.8/gems/passenger-${passenger_version}"
      $mod_passenger_location = "${passenger_root}/${builddir}/apache2/mod_passenger.so"
    }
    'darwin':{
      $passenger_package      = 'passenger'
      $gem_path               = '/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin'
      $gem_binary_path        = '/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin'
      $passenger_root         = "/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/passenger-${passenger_version}"
      $mod_passenger_location = "${passenger_root}/${builddir}/apache2/mod_passenger.so"
    }
    default: {
      fail("Operating system ${::operatingsystem} is not supported with the Passenger module")
    }
  }
}
