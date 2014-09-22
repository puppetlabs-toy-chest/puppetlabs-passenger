require 'spec_helper'

describe 'passenger' do
  let(:facts) do
    { :concat_basedir => '/dne' }
  end
  let(:params) do
    {
      :passenger_version      => '3.0.19',
      :passenger_ruby         => '/opt/bin/ruby',
      :gem_path               => '/opt/lib/ruby/gems/1.9.1/gems',
      :gem_binary_path        => '/opt/lib/ruby/bin',
    }
  end

  describe 'on RedHat' do
    let(:facts) do
      {
        :osfamily => 'redhat',
        :operatingsystemrelease => '6.4',
        :operatingsystemmajrelease => '6',
        :architecture   => 'x86_64',
        :concat_basedir => '/dne'
      }
    end

    it 'adds libcurl-devel for compilation' do
      should contain_package('libcurl-devel')
    end

    it 'adds httpd config' do
      should contain_file('/etc/httpd/conf.d/passenger.conf').with_content(/PassengerRuby \/opt\/bin\/ruby/)
    end
    context 'on x86_64' do
      let (:facts) do
        {
          :osfamily => 'redhat',
          :operatingsystemrelease => '6.4',
          :operatingsystemmajrelease => '6',
          :architecture   => 'x86_64',
          :concat_basedir => '/dne'
        }
      end
      it 'uses proper paths' do
        should contain_file('/etc/httpd/conf.d/passenger.conf').with_content(/LoadModule passenger_module \/usr\/lib64\/ruby\/gems\/1.8\/gems\/passenger-3.0.19\/buildout\/apache2\/mod_passenger.so/)
        should contain_file('/etc/httpd/conf.d/passenger.conf').with_content(/PassengerRoot \/usr\/lib64\/ruby\/gems\/1.8\/gems\/passenger-3.0.19/)
      end
    end
    context 'on i386' do
      let (:facts) do
        {
          :osfamily => 'redhat',
          :operatingsystemrelease => '6.4',
          :operatingsystemmajrelease => '6',
          :architecture   => 'i386',
          :concat_basedir => '/dne'
        }
      end
      it 'uses proper paths' do
        should contain_file('/etc/httpd/conf.d/passenger.conf').with_content(/LoadModule passenger_module \/usr\/lib\/ruby\/gems\/1.8\/gems\/passenger-3.0.19\/buildout\/apache2\/mod_passenger.so/)
        should contain_file('/etc/httpd/conf.d/passenger.conf').with_content(/PassengerRoot \/usr\/lib\/ruby\/gems\/1.8\/gems\/passenger-3.0.19/)
      end
    end
  end

  describe 'on Debian' do
    let(:facts) do
      {
        :osfamily => 'debian',
        :operatingsystemrelease => '7',
        :architecture   => 'x86_64',
        :concat_basedir => '/dne'
      }
    end

    it 'adds mods-available files' do
      should contain_file('/etc/apache2/mods-available/passenger.conf')
      should contain_file('/etc/apache2/mods-available/passenger.load')
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
      {
        :osfamily => osfamily,
        :operatingsystemrelease => 'thing',
        :architecture => 'x86_64',
        :concat_basedir => '/dne'
      }
    end

    context "on #{osfamily} with customized params" do
      it 'compiles the apache module' do
        should contain_exec('compile-passenger').with(
          :path => ['/opt/lib/ruby/bin', '/usr/bin', '/bin', '/usr/local/bin'],
          :creates => '/var/lib/gems/1.8/gems/passenger-3.0.19/ext/apache2/mod_passenger.so'
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
