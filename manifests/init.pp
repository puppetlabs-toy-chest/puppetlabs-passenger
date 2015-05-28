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
#   [*passenger_provider*]
#     The package provider to use for the system
#
#   [*include_build_tools*]
#     Boolean to require gcc and make classes. Default is false.
#
# Usage:
#
#  class { 'passenger':
#    passenger_version      => '3.0.21',
#    passenger_ruby         => '/usr/bin/ruby'
#    packge_provider        => 'gem',
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
  $passenger_version      = $passenger::params::passenger_version,
  $passenger_ruby         = $passenger::params::passenger_ruby,
  $package_provider       = $passenger::params::package_provider,
  $compile_passenger      = $passenger::params::compile_passenger,
  $passenger_package      = $passenger::params::passenger_package,
  $include_build_tools    = false
) inherits passenger::params {

  include '::apache'
  include '::apache::dev'

  include '::passenger::options'
  include '::passenger::install'
  include '::passenger::config'

  if $compile_passenger {
    class { '::passenger::compile': }
    Class['passenger::options'] ->
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
  Class['passenger::compile'] ->
  Class['passenger::config'] ->
  Anchor['passenger::end']
}
