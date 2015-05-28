class passenger::options {
  $passenger_version  =  $passenger::passenger_version
  $passenger_ruby     =  $passenger::passenger_ruby
  $passenger_package  =  $passenger::passenger_package
  $package_name       =  $passenger::package_name
  $package_provider   =  $passenger::package_provider

  if versioncmp ($passenger_version, '4.0.0') > 0 {
    $builddir     = 'buildout'
  } else {
    $builddir     = 'ext'
  }

  case $::osfamily {
    'debian': {
      $gem_path               = '/var/lib/gems/1.8/gems'
      $gem_binary_path        = '/var/lib/gems/1.8/bin'
      $passenger_root         = "$gem_path/passenger-${passenger_version}"
      $mod_passenger_location = "$passenger_root/${builddir}/apache2/mod_passenger.so"

      # Ubuntu does not have libopenssl-ruby - it's packaged in libruby
      if $::lsbdistid == 'Debian' and $::lsbmajdistrelease <= 5 {
        $package_dependencies   = [ 'libopenssl-ruby', 'libcurl4-openssl-dev' ]
      } else {
        $package_dependencies   = [ 'libruby', 'libcurl4-openssl-dev' ]
      }
    }
    'redhat': {
      case $::lsbmajdistrelease {
        '5'     : { $curl_package = 'curl-devel' }
        default : { $curl_package = 'libcurl-devel' }
      }
      case $::operatingsystemmajrelease {
        '6' : {
          $real_gem_path               = "/usr/lib/ruby/gems/1.8/gems"
          $real_passenger_root         = "${real_gem_path}/passenger-${passenger_version}"
          $real_mod_passenger_location = "${real_passenger_root}/${builddir}/apache2/mod_passenger.so"
        }
        '7' : {
          $real_gem_path               = "/usr/local/share/gems/gems"
          $real_passenger_root         = "${real_gem_path}/passenger-${passenger_version}"
          $real_mod_passenger_location = "$real_passenger_root/${builddir}/apache2/mod_passenger.so"
        }
      }
      $package_dependencies   = [ $curl_package, 'openssl-devel', 'zlib-devel', 'gcc-c++', 'ruby-devel' ]
      $gem_path               = $real_gem_path
      $gem_binary_path        = '/usr/lib/ruby/gems/1.8/gems/bin'
      $passenger_root         = $real_passenger_root
      $mod_passenger_location = $real_mod_passenger_location
    }
    'darwin':{
      $gem_path               = '/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin'
      $passenger_root         = "$gem_path/passenger-${passenger_version}"
      $mod_passenger_location = "$passenger_root/${builddir}/apache2/mod_passenger.so"
    }
    default: {
      fail("Operating system ${::operatingsystem} is not supported with the Passenger module")
    }
  }
}
