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
  $default_package_ensure     = '3.0.21'
  $default_passenger_version  = '3.0.21'
  $passenger_ruby     = '/usr/bin/ruby'
  $package_provider   = 'gem'
  $passenger_provider = 'gem'
  
  
  if versioncmp ($passenger_version, '4.0.0') > 0 {
    $builddir     = 'buildout'
  } else {
    $builddir     = 'ext'
  }

  case $::osfamily {
    'debian': {
      $install_config         = true
      $package_ensure         = $default_package_ensure
      $passenger_version      = $default_passenger_version

      $package_name           = 'passenger'
      $passenger_package      = 'passenger'
      $gem_path               = '/var/lib/gems/1.8/gems'
      $gem_binary_path        = '/var/lib/gems/1.8/bin'
      $passenger_root         = "/var/lib/gems/1.8/gems/passenger-${passenger_version}"
      $mod_passenger_location = "/var/lib/gems/1.8/gems/passenger-${passenger_version}/ext/apache2/mod_passenger.so"

      # Ubuntu does not have libopenssl-ruby - it's packaged in libruby
      if $::lsbdistid == 'Debian' and $::lsbmajdistrelease <= 5 {
        $package_dependencies   = [ 'libopenssl-ruby', 'libcurl4-openssl-dev' ]
      } else {
        $package_dependencies   = [ 'libruby', 'libcurl4-openssl-dev' ]
      }
      $passenger_conf_template = 'passenger/passenger-enabled.erb'
      $passenger_load_template = 'passenger/passenger-load.erb'
    }
    'redhat': {
      $install_config          = true
      $package_name            = 'passenger'
      $passenger_package       = 'passenger'
      $package_dependencies    = [ 'libcurl-devel', 'openssl-devel', 'zlib-devel' ]
      $passenger_conf_template = 'passenger/passenger-conf.erb'
      $passenger_load_template = undef
      
      # not sure what fedora operatingsystemmajrelease is so only pulling RHEL 7.x /Centos 7.x
      if $::operatingsystemmajrelease >= 7 and $::operatingsystemmajrelease < 8 {
        # need newer version of passenger than 3.0.21
        $package_ensure         = '4.0.57'
        $passenger_version      = '4.0.57'
        $gem_path               = '/usr/local/share/gems'
        $gem_binary_path        = '/usr/bin'
        $passenger_root         = "/usr/local/share/gems/gems/passenger-${passenger_version}"
        $mod_passenger_location = "/usr/local/share/gems/gems/passenger-${passenger_version}/${builddir}/apache2/mod_passenger.so"
      } else {
        $package_ensure         = $default_package_ensure
        $passenger_version      = $default_passenger_version      
        $gem_path               = '/usr/lib/ruby/gems/1.8/gems'
        $gem_binary_path        = '/usr/lib/ruby/gems/1.8/gems/bin'
        $passenger_root         = "/usr/lib/ruby/gems/1.8/gems/passenger-${passenger_version}"
        $mod_passenger_location = "/usr/lib/ruby/gems/1.8/gems/passenger-${passenger_version}/${builddir}/apache2/mod_passenger.so"
      }
    }
    'darwin':{
      # config module doesn't currently have branch for darwin so don't install config
      $install_config         = false
      $passenger_conf_template = 'passenger/passenger-conf.erb'
      $passenger_load_template = undef
      $package_ensure         = $default_package_ensure
      $passenger_version      = $default_passenger_version
      $package_name           = 'passenger'
      $passenger_package      = 'passenger'
      $gem_path               = '/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin'
      $gem_binary_path        = '/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin'
      $passenger_root         = "/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/passenger-${passenger_version}"
      $mod_passenger_location = "/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/passenger-${passenger_version}/ext/apache2/mod_passenger.so"
    }
    default: {
      fail("Operating system ${::operatingsystem} is not supported with the Passenger module")
    }
  }
}
