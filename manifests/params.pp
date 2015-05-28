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
  $passenger_version  = '3.0.21'
  $passenger_ruby     = '/usr/bin/ruby'
  $package_provider   = 'gem'
  $compile_passenger  = true
  $passenger_package  = 'passenger'
}
