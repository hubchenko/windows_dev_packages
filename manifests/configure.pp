class windows_dev_packages::configure inherits windows_dev_packages {

  ####Variables used for install###

  if $::kernel == "windows" {
    if $windows_dev_packages::enforce_domain_access  {

      dsc_group {'Administrators':
        dsc_ensure           => 'Present',
        dsc_groupname        => 'Administrators',
        dsc_memberstoinclude => $windows_dev_packages::domain_approved_access,
        dsc_memberstoexclude => $windows_dev_packages::domain_restricted_access,
        dsc_credential       => {
                                  "user"      => $windows_dev_packages::msft_creds_user,
                                  "password"  => $windows_dev_packages::msft_creds_password,
                                  },
      }

    }

    if $windows_dev_packages::install_newrelic {

      registry_key {'HKLM\SOFTWARE\New Relic\Server Monitor\ProxyAddress':
            ensure => present,
        }


      registry_value {'HKLM\SOFTWARE\New Relic\Server Monitor\ProxyAddress':
        ensure  => present,
        type    => string,
        data    => $proxyhttp,
        notify  => Class['newrelic::server::windows'],
        require => Registry_key['HKLM\SOFTWARE\New Relic\Server Monitor\ProxyAddress'], 
      }

    }

  dsc_registry {'powershell_policy':
    dsc_ensure => 'Present',
    dsc_key => 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell',
    dsc_valuename => 'ExecutionPolicy',
    dsc_valuedata => $windows_dev_packages::powershell_exe_policy,
    dsc_valuetype => 'String',
      }


file {'newrelicPSmoduleDir':
        ensure  => directory,
        path  => "C:\\Program Files\\WindowsPowerShell\\Modules\\NewRelicApi",
        force => true
      }
file {'newrelicPSmodulefile':
        ensure  => directory,
        path  => "C:\\Program Files\\WindowsPowerShell\\Modules\\NewRelicApi\\NewRelicApi.psm1",
        source  => "puppet:///modules/windows_dev_packages/Powershell/NewRelicApi.psm1",
        source_permissions  => ignore,
        require => File['newrelicPSmoduleDir']
      }



  file {'BossPowershellScripts':
        ensure  => directory,
        path  => 'C:\BossPowershellScripts',
        force => true
      }


  file {'Get-Blade Summary':
        ensure  => directory,
        path  => "C:\\BossPowershellScripts\\Get-BladeSystemInventory.ps1",
        source  => "puppet:///modules/windows_dev_packages/Powershell/Get-BladeSystemInventory.ps1",
        source_permissions  => ignore,
        require => [File['newrelicPSmoduleDir'],File['BossPowershellScripts']]
      }

  file {'New Relic APi Sample':
        ensure  => directory,
        path  => "C:\\BossPowershellScripts\\NewRelicAPisample.ps1",
        source  => "puppet:///modules/windows_dev_packages/Powershell/NewRelicAPisample.ps1",
        source_permissions  => ignore,
        require => File['BossPowershellScripts']
      }


  file {'ags_directory':
    ensure => directory,
    path  => "C:\\ProgramData\\ASG-RemoteDesktop",
      }

  file {'ags_directory_version':
    ensure => directory,
    path  => "C:\\ProgramData\\ASG-RemoteDesktop\\10.0",
    require  => File['ags_directory'],
      }

  file {'ags_env_xml':
    ensure => file,
    path  => "C:\\ProgramData\\ASG-RemoteDesktop\\10.0\\environments.xml",
    content  => template("windows_dev_packages/environments.xml.erb"),
     require  => File['ags_directory_version'],
      }

	
  }
}