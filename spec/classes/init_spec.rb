require 'spec_helper'
describe 'papertrail' do

  platforms = {
    'debian6' =>
      { :osfamily => 'Debian',
        :release  => '6',
      },
    'el5' =>
      { :osfamily => 'RedHat',
        :release  => '5',
      },
    'el6' =>
      { :osfamily => 'RedHat',
        :release  => '6',
      },
    'el7' =>
      { :osfamily => 'RedHat',
        :release  => '7',
      },
    'solaris10' =>
      { :osfamily => 'Solaris',
        :release  => '5.10',
      },
    'solaris11' =>
      { :osfamily => 'Solaris',
        :release  => '5.11',
      },
    'suse10' =>
      { :osfamily => 'Suse',
        :release  => '10',
      },
    'suse11' =>
      { :osfamily => 'Suse',
        :release  => '11',
      },
    'suse12' =>
      { :osfamily => 'Suse',
        :release  => '12',
      },
    'ubuntu1204' =>
      { :osfamily => 'Debian',
        :release  => '12',
      },
    'ubuntu1404' =>
      { :osfamily => 'Debian',
        :release  => '14',
      },
  }

  describe 'with default values for parameters on' do
    platforms.sort.each do |k,v|
      context "#{k}" do
        if v[:osfamily] == 'Solaris'
          let :facts do
            { :osfamily      => v[:osfamily],
              :kernelrelease => v[:release],
            }
          end
        else
          let :facts do
            { :osfamily          => v[:osfamily],
              :lsbmajdistrelease => v[:release],
            }
          end
        end

        it { should contain_class('papertrail') }
        it { should contain_class('rsyslog') }
        it { should contain_class('wget') }

        it { should contain_common__remove_if_empty('/etc/papertrail-bundle.pem') }

        it {
          should contain_exec('wget_papertrail_cert').with({
            'command' => 'wget https://papertrailapp.com/tools/papertrail-bundle.pem -O /etc/papertrail-bundle.pem',
            'creates' => '/etc/papertrail-bundle.pem',
            'path'    => '/bin:/usr/bin:/sbin:/usr/sbin',
            'notify'  => 'Exec[verify_papertrail_cert_md5]',
            'require' => 'Common::Remove_if_empty[/etc/papertrail-bundle.pem]',
          })
        }

        it {
          should contain_file('papertrail_cert').with({
            'ensure'  => 'file',
            'path'    => '/etc/papertrail-bundle.pem',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'Exec[wget_papertrail_cert]',
          })
        }

        it {
          should contain_file('papertrail_cert_md5').with({
            'ensure'  => 'file',
            'path'    => '/etc/papertrail-bundle.pem.md5',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }

        it { should contain_file('papertrail_cert_md5').with_content("c75ce425e553e416bde4e412439e3d09  /etc/papertrail-bundle.pem\n") }

        it {
          should contain_exec('verify_papertrail_cert_md5').with({
            'command'     => 'md5sum -c /etc/papertrail-bundle.pem.md5',
            'path'        => '/bin:/usr/bin:/sbin:/usr/sbin',
            'refreshonly' => 'true',
            'subscribe'   => 'File[papertrail_cert_md5]',
          })
        }
      end
    end
  end

  params = {
    'cert_md5sum' =>
      { :value => 'c75ce425e553e416bde4e412439e3d09',
        :type  => 'string',
      },
    'cert_path' =>
      { :value => '/etc/papertrail-bundle.pem',
        :type  => 'path',
      },
    'cert_uri' =>
      { :value => 'https://papertrailapp.com/tools/papertrail-bundle.pem',
        :type  => 'string',
      },
    'include_rsyslog' =>
      { :value => true,
        :type  => 'bool',
      },
    'md5_path' =>
      { :value => '/bin:/usr/bin:/sbin:/usr/sbin',
        :type  => 'string',
      },
    'wget_path' =>
      { :value => '/bin:/usr/bin:/sbin:/usr/sbin',
        :type  => 'string',
      },
  }

  describe 'with an invalid value for parameter' do
    params.sort.each do |k,v|
      context "#{k}" do
        let :facts do
          { :osfamily          => 'RedHat',
            :lsbmajdistrelease => '7',
          }
        end

        case v[:type]
        when 'string'
          kvalue = ['invalid','type']
          errormsg = '\["invalid", "type"\] is not a string.  It looks to be a Array'
        when 'path'
          kvalue = 'invalid/path'
          errormsg = '"invalid/path" is not an absolute path.'
        when 'bool'
          kvalue = ['invalid','type']
          errormsg = '\["invalid", "type"\] is not a boolean.  It looks to be a Array'
        else
          raise "error in your spec tests - you have an unknown type value (#{v[:type]}) for parameter #{k}."
        end

        let(:params) { { :"#{k}" => kvalue } }

        it 'should fail' do
          expect {
            should contain_class('papertrail')
          }.to raise_error(Puppet::Error,/#{errormsg}/)
        end
      end
    end
  end

  describe 'with a valid custom value specified for parameter' do
    let :facts do
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '7',
      }
    end

    context 'cert_md5sum' do
      let(:params) { { :cert_md5sum => 'c0ffeec0ffeec0ffeec0ffeec0ffeeha' } }

      it { should contain_file('papertrail_cert_md5').with_content("c0ffeec0ffeec0ffeec0ffeec0ffeeha  /etc/papertrail-bundle.pem\n") }
    end

    context 'cert_path' do
      let(:params) { { :cert_path=> '/path/to/cert' } }

      it { should contain_common__remove_if_empty('/path/to/cert') }

      it {
        should contain_exec('wget_papertrail_cert').with({
          'command' => 'wget https://papertrailapp.com/tools/papertrail-bundle.pem -O /path/to/cert',
          'creates' => '/path/to/cert',
          'require' => 'Common::Remove_if_empty[/path/to/cert]',
        })
      }

      it {
        should contain_file('papertrail_cert').with({
          'path'    => '/path/to/cert',
        })
      }

      it {
        should contain_file('papertrail_cert_md5').with({
          'path'    => '/path/to/cert.md5',
        })
      }

      it { should contain_file('papertrail_cert_md5').with_content("c75ce425e553e416bde4e412439e3d09  /path/to/cert\n") }

      it {
        should contain_exec('verify_papertrail_cert_md5').with({
          'command'     => 'md5sum -c /path/to/cert.md5',
        })
      }
    end

    context 'cert_uri' do
      let(:params) { { :cert_uri=> 'https://example.com/certs/papertrail-bundle.pem' } }

      it {
        should contain_exec('wget_papertrail_cert').with({
          'command' => 'wget https://example.com/certs/papertrail-bundle.pem -O /etc/papertrail-bundle.pem',
        })
      }
    end

    describe 'include_rsyslog' do
      ['true',true,'false',false].each do |value|
        context "set to #{value}" do
          let(:params) { { :include_rsyslog => value } }

          if value.to_s == 'true'
            it { should contain_class('rsyslog') }
          elsif value.to_s == 'false'
            it { should_not contain_class('rsyslog') }
          else
            raise 'logic error in spec tests'
          end
        end
      end
    end

    context 'md5_path' do
      let(:params) { { :md5_path => '/here:/or:/there' } }

      it {
        should contain_exec('verify_papertrail_cert_md5').with({
          'path'        => '/here:/or:/there',
        })
      }
    end

    context 'wget_path' do
      let(:params) { { :wget_path => '/here:/or:/there' } }

      it {
        should contain_exec('wget_papertrail_cert').with({
          'path'    => '/here:/or:/there',
        })
      }
    end
  end
end
