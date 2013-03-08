require 'spec_helper'

describe 'passenger' do
  def param_value(type, title, param)
    catalogue.resource(type, title).send(:parameters)[param.to_sym]
  end

  let(:params) do
    {
      :passenger_version => '3.0.19',
      :passenger_ruby => '/opt/bin/ruby',
      :gem_path => '/opt/lib/ruby/gems/1.9.1/gems',
      :gem_binary_path => '/opt/lib/ruby/bin',
      :mod_passenger_location => '/opt/lib/ruby/gems/1.9.1/gems/passenger-3.0.19/ext/apache2/mod_passenger.so',
      :passenger_config => {
        'PassengerHighPerformance'  => 'off',
        'PassengerMinInstances'     => '2',
        'PassengerMaxPoolSize'      => '40',
        'PassengerPoolIdleTime'     => '600',
        'PassengerStatThrottleRate' => '300'
      }
    }
  end

  let(:expected_config_lines) do
    [
      'LoadModule passenger_module /opt/lib/ruby/gems/1.9.1/gems/passenger-3.0.19/ext/apache2/mod_passenger.so',
      'PassengerRuby /opt/bin/ruby',
      'PassengerRoot /opt/lib/ruby/gems/1.9.1/gems/passenger-3.0.19',
      'PassengerHighPerformance off',
      'PassengerMinInstances 2',
      'PassengerMaxPoolSize 40',
      'PassengerHighPerformance off',
      'PassengerPoolIdleTime 600',
      'PassengerStatThrottleRate 300',
    ]
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
      config = param_value('file', '/etc/httpd/conf.d/passenger.conf', 'content')

      expected_config_lines.each do |line|
        config.should include line
      end
    end
  end

  describe 'on Debian' do
    let(:facts) do
      { :osfamily => 'debian' }
    end

    it 'adds mods-available files' do
      config = param_value('file', '/etc/apache2/mods-available/passenger.conf', 'content')
      config << param_value('file', '/etc/apache2/mods-available/passenger.load', 'content')

      expected_config_lines.each do |line|
        config.should include line
      end
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
          :creates => '/opt/lib/ruby/gems/1.9.1/gems/passenger-3.0.19/ext/apache2/mod_passenger.so',
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
