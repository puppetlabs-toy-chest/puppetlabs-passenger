# Class: passenger
#
# This class installs Passenger (mod_rails) on your system.
# http://www.modrails.com
#
# Parameters:
#   [*passenger_version*]
#     The Version of Passenger to be installed
#
#   [*passenger_ruby*]
#     The path to ruby on your system
#
#   [*gem_path*]
#     The path to rubygems on your system
#
#   [*gem_binary_path*]
#     Path to Rubygems binaries on your system
#
#   [*passenger_root*]
#     The passenger gem root directory
#
#   [*mod_passenger_location*]
#     Path to Passenger's mod_passenger.so file
#
#   [*passenger_provider*]
#     The package provider to use for the system
#
#   [*passenger_package*]
#     The name of the Passenger package
#
#   [*include_build_tools*]
#     Boolean to require gcc and make classes. Default is false.
#
# Usage:
#
#  class { 'passenger':
#    passenger_version      => '3.0.21',
#    passenger_ruby         => '/usr/bin/ruby'
#    gem_path               => '/var/lib/gems/1.8/gems',
#    gem_binary_path        => '/var/lib/gems/1.8/bin',
#    passenger_root         => '/var/lib/gems/1.8/gems/passenger-3.0.21'
#    mod_passenger_location => '/var/lib/gems/1.8/gems/passenger-3.0.21/ext/apache2/mod_passenger.so',
#    passenger_provider     => 'gem',
#    passenger_package      => 'passenger',
#    include_build_tools    => 'true',
#  }
#
#
# Requires:
#   - apache
#   - apache::dev
#
# Optionally requires
#   - gcc
#   - make
#
class passenger (
  $gem_binary_path        = $passenger::params::gem_binary_path,
  $gem_path               = $passenger::params::gem_path,
  $mod_passenger_location = $passenger::params::mod_passenger_location,
  $package_name           = $passenger::params::package_name,
  $package_ensure         = $passenger::params::package_ensure,
  $package_provider       = $passenger::params::package_provider,
  $passenger_package      = $passenger::params::passenger_package,
  $passenger_provider     = $passenger::params::passenger_provider,
  $passenger_root         = $passenger::params::passenger_root,
  $passenger_ruby         = $passenger::params::passenger_ruby,
  $passenger_app_env   = $passenger::params::passenger_app_env,
  $passenger_version      = $passenger::params::passenger_version,
  $compile_passenger      = $passenger::params::compile_passenger,
  $include_build_tools    = false,
) inherits passenger::params {

  include '::apache'
  include '::apache::dev'

  include '::passenger::install'
  include '::passenger::config'

  if $compile_passenger {
    class { '::passenger::compile': }
    Class['passenger::install'] ->
    Class['passenger::compile'] ->
    Class['passenger::config']
  }

  if type($include_build_tools) == 'string' {
    $include_build_tools_real = str2bool($include_build_tools)
  } else {
    $include_build_tools_real = $include_build_tools
  }
  validate_bool($include_build_tools_real)

  if $include_build_tools_real == true {
    require 'gcc'
    require 'make'
  }

  anchor { 'passenger::begin': }
  anchor { 'passenger::end': }

  #projects.puppetlabs.com - bug - #8040: Anchoring pattern
  Anchor['passenger::begin'] ->
  Class['apache::dev'] ->
  Class['passenger::install'] ->
  Class['passenger::config'] ->
  Anchor['passenger::end']


}
