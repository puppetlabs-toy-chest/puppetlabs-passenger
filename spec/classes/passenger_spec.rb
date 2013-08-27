require 'spec_helper'

describe 'passenger' do
  let(:param_defaults) do
      {
        :passenger_ruby    => '/opt/bin/ruby',
        :gem_path          => '/opt/lib/ruby/gems/1.9.1/gems',
        :gem_binary_path   => '/opt/lib/ruby/bin',
      }
  end
  describe 'with passenger version' do
    {
      '3' => {
        :passenger_version      => '3.0.19',
        :passenger_root         => '/opt/lib/ruby/gems/1.9.1/gems/passenger-3.0.19',
        :mod_passenger_location => '/opt/lib/ruby/gems/1.9.1/gems/passenger-3.0.19/ext/apache2/mod_passenger.so'
      },
      '4' => {
        :passenger_version      => '4.0.10',
        :passenger_root         => '/opt/lib/ruby/gems/1.9.1/gems/passenger-4.0.10',
        :mod_passenger_location => '/opt/lib/ruby/gems/1.9.1/gems/passenger-4.0.10/buildout/apache2/mod_passenger.so'
      },
    }.each do |passengerversion, passengerparams|
      describe "when Passenger is version #{passengerversion}" do
        let :params do
          param_defaults.merge(passengerparams)
        end
        describe 'on RedHat' do
          let(:facts) do
            { :osfamily => 'redhat' }
          end

          it 'adds libcurl-devel for compilation' do
            should contain_package('libcurl-devel').with(
              :before => 'Exec[compile-passenger]'
            )
          end

          it 'adds httpd config' do
            config = catalogue.resource('File[/etc/httpd/conf.d/passenger.conf]')[:content]

            config.should include "LoadModule passenger_module #{params[:mod_passenger_location]}"
            config.should include "PassengerRuby #{params[:passenger_ruby]}"
            config.should include "PassengerRoot #{params[:passenger_root]}"
            if passengerversion == '3'
              config.should include "RailsAutoDetect On"
            else
              config.should include "PassengerEnabled on"
            end
          end
        end

        describe 'on Debian' do
          let(:facts) do
            { :osfamily => 'debian' }
          end

          it 'adds mods-available files' do
            should contain_file('/etc/apache2/mods-available/passenger.conf')
            config = catalogue.resource('File[/etc/apache2/mods-available/passenger.conf]')[:content]
            config.should include "PassengerRuby #{params[:passenger_ruby]}"
            config.should include "PassengerRoot #{params[:passenger_root]}"
            if passengerversion == '3'
              config.should include "RailsAutoDetect On"
            else
              config.should include "PassengerEnabled on"
            end
            should contain_file('/etc/apache2/mods-available/passenger.load')
            load = catalogue.resource('File[/etc/apache2/mods-available/passenger.load]')[:content]
            load.should include "LoadModule passenger_module #{params[:mod_passenger_location]}"
          end

          it 'adds symlinks mods-enabled to load modules' do
            should contain_file('/etc/apache2/mods-enabled/passenger.conf').with(
              :ensure => 'link',
              :target => '/etc/apache2/mods-available/passenger.conf'
            )

            should contain_file('/etc/apache2/mods-enabled/passenger.load').with(
              :ensure => 'link',
              :target => '/etc/apache2/mods-available/passenger.load'
            )
          end
        end

        ['redhat', 'debian'].each do |osfamily|
          let(:facts) do
            { :osfamily => osfamily }
          end

          context "on #{osfamily} with customized params" do
            it 'compiles the apache module' do
              should contain_exec('compile-passenger').with(
                :path => ['/opt/lib/ruby/bin', '/usr/bin', '/bin', '/usr/local/bin'],
                :creates => params[:mod_passenger_location],
                :require => 'Package[passenger]'
              )
            end

            it 'adds passenger package' do
              should contain_package('passenger').with(
                :name => 'passenger',
                :provider => 'gem'
              )
            end

            it 'includes apache' do
              should contain_class('apache')
            end
          end
        end
      end
    end
  end
end
