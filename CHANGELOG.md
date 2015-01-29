##2015-01-29 - Release 0.4.1
###Summary

This release fixes a typo in the version requirement for 'croddy/make' in the metadata.

##2015-01-27 - Release 0.4.0
###Summary

This includes a few new features and bugfixes, including the ability to optionally include build related modules and making passenger compilation optional.

####Features
- Add new `$compile_passenger` and `$include_build_tools` parameters

####Bugfixes
- Use the `$builddir` variable for determining `mod_passenger_location`
- Fix to use the correct curl package on EL5

##2014-06-03 - Release 0.3.0
###Summary

The major change here is to use an updated 3.0.x release.

####Features
- Use the last version in the 3.0.x releases as the default.

####Fixes
- Fixed timeout when compiling passenger on 'slow' machines

##2013-11-20 - Release 0.2.0
###Summary

This release refactors the module fairly expensively, and adds Passenger 4
support.

####Features
- Parameters in `passenger` class:
 - `package_name`: Name of the passenger package.
 - `package_ensure`: Ensure state of the passenger package.
 - `package_provider`: Provider to use to install passenger.
 - `passenger_root`: Root directory for passenger.

##2013-07-31 - Release 0.1.0
###Summary

Several changes over the last year to improve compatibility against
modern distributions, improvements to make things more robust and
some fixes for Puppet 3.

####Features
- Parameters in `passenger` class:
 - `passenger_ruby`: Allows you to customize what ruby binary is used.

####Bugfixes
- Ubuntu compatibility fixes.
- Debian 6+ compatibility fixes.
- Fixes against newer puppetlabs-apache.
- Properly qualify variables.
- Restart apache if passenger configuration changes.
- Don't try to load unless compilation stage was successful.
