class windows_dev_packages::install inherits windows_dev_packages {

  ####Variables used for install###

  if $::kernel == "windows" {
    if $windows_dev_packages::install_chocolatey {

      class {'chocolatey':
        chocolatey_download_url         => 'https://chocolatey.org/api/v2/package/chocolatey/',
        use_7zip                        => true,
        choco_install_timeout_seconds   => 2700
          }


      package {'git':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }

      package {'curl':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }
      package {'putty':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }
      package {'javaruntime':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }
      package {'sublimetext3':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }
      package {'procmon':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }

      package {'notepadplusplus':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/S', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
      }

      package {'firefox':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/S', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
      }

      package {'googlechrome':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/quiet', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
      }

      package {'7zip':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/S', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
      }
    }

    if $windows_dev_packages::install_developer_packages {
 
      package {'php':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }
      package {'docker':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }

      package {'ruby':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }

      package {'python2':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/passive', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }
      package {'vagrant':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/passive', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }
      package {'nodejs':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/passive', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
        }
    }

    if $windows_dev_packages::install_networking_packages {

      package {'wireshark':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/S', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
      }
      package {'winpcap':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/S', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
      }
      package {'nmap':
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => ['-override', '--allow-empty-checksums', '-installArgs', '"', '/S', '"'],
        notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
      }
    }

    if $windows_dev_packages::install_VMware_packages {
		file {'VMwareInstall':
		      ensure  => directory,
		      path  => 'C:\VMwareInstall',
		      force => true
		    }

	    file {'rvtools':
	      ensure  => file,
	      path  => "C:\\VMwareInstall\\RVTools.msi",
	      source  => "puppet:///modules/windows_dev_packages/VMware/RVTools.msi",
	      source_permissions  => ignore,
	      require => File['VMwareInstall']
	      	}

	    file {'VMwarePowerCli':
	      ensure  => file,
	      path  => "C:\\VMwareInstall\\VMware-PowerCLI-6.3.0-3737840.exe",
	      source  => "puppet:///modules/windows_dev_packages/VMware/VMware-PowerCLI-6.3.0-3737840.exe",
	      source_permissions  => ignore,
	      require => File['VMwareInstall']
	      	}

		file {'VMware Remote Web Plugin':
	      ensure  => file,
	      path  => "C:\\VMwareInstall\\VMwareRemoteConsoleWebPlugIn.msi",
	      source  => "puppet:///modules/windows_dev_packages/VMware/VMwareRemoteConsoleWebPlugIn.msi",
	      source_permissions  => ignore,
	      require => File['VMwareInstall']
	      	}

		file {'VMware Client Integration Client Plugin':
	      ensure  => file,
	      path  => "C:\\VMwareInstall\\VMware-ClientIntegrationPlugin-5.6.0.exe",
	      source  => "puppet:///modules/windows_dev_packages/VMware/VMware-ClientIntegrationPlugin-5.6.0.exe",
	      source_permissions  => ignore,
	      require => File['VMwareInstall']
	      	}

		file {'VMware VMRC':
	      ensure  => file,
	      path  => "C:\\VMwareInstall\\VMware-VMRC-8.1.0-4133417.msi",
	      source  => "puppet:///modules/windows_dev_packages/VMware/VMware-VMRC-8.1.0-4133417.msi",
	      source_permissions  => ignore,
	      require => File['VMwareInstall']
	      	}

	    package {'RVTools':
          ensure          => installed,
          install_options => ['/quiet', '/passive'],
          source    	  => "C:\\VMwareInstall\\RVTools.msi",

         require 		  => File['rvtools']
        }

	    package {'VMware vSphere PowerCLI':
          ensure          => installed,
          install_options => ['/S', '/v/qn'],
          source    	  => "C:\\VMwareInstall\\VMware-PowerCLI-6.3.0-3737840.exe",
          require 		  => [File['VMwarePowerCli'], Package['VMware Remote Console Plug-in 5.1']]
        }

       	package {'VMware Remote Console Plug-in 5.1':
          ensure          => installed,
          install_options => ['/passive', '/qn'],
          #install_options => ['/S','/v" /qn "'],
          source    	  => "C:\\VMwareInstall\\VMwareRemoteConsoleWebPlugIn.msi",
         require 		  => File['VMware Remote Web Plugin']
        }

       	package {'VMware Client Integration Plug-in 5.6.0':
          ensure          => installed,
          install_options => ['/S', '/v/qn'],
          source    	  => "C:\\VMwareInstall\\VMware-ClientIntegrationPlugin-5.6.0.exe",
         require 		  => File['VMware Client Integration Client Plugin']
        }
       	package {'VMware Remote Console':
          ensure          => installed,
          install_options => ['/passive', '/norestart', 'EULAS_AGREED=1'],
          source    	  => "C:\\VMwareInstall\\VMware-VMRC-8.1.0-4133417.msi",
          require 		  => File['VMware VMRC']
        }


    }

    if $windows_dev_packages::install_HPdev_packages {
      file {'HPdev':
        ensure  => directory,
        path  => 'C:\HPInstall',
        force => true
        }

      file {'HP OneView Powershell Module install':
        ensure  => file,
        path  => "C:\\HPInstall\\HPE.OneView.3.00.PowerShell.Library.exe",
        source  => "puppet:///modules/windows_dev_packages/HP/HPE.OneView.3.00.PowerShell.Library.exe",
        source_permissions  => ignore,
        require => File['HPdev']
          }

      file {'Virtual Connect Update Manager':
        ensure  => file,
        path  => "C:\\HPInstall\\vcsu-1.12.0-x86.msi",
        source  => "puppet:///modules/windows_dev_packages/HP/vcsu-1.12.0-x86.msi",
        source_permissions  => ignore,
        require => File['HPdev']
          }


      exec { 'Virtual Connect Update Manager':
        command   => "C:\\HPInstall\\vcsu-1.12.0-x86.msi  /passive",
        require   => File['Virtual Connect Update Manager'],
        provider  => powershell,
        creates   => "C:\\Program Files (x86)\\Hewlett Packard Enterprise\\Virtual Connect Support Utility",

        }

      exec { 'HP OneView Powershell Module install':
        command   => "C:\\HPInstall\\HPE.OneView.3.00.PowerShell.Library.exe  /VERYSILENT",
        require   => File['HP OneView Powershell Module install'],
        provider  => powershell,
      	 creates	=> "C:\\Program Files\\WindowsPowerShell\\Modules\\HPOneView.300",

        }


    }

    if $windows_dev_packages::install_DBA_packages {

      # package {'sql2012.nativeclient':
      #   ensure          => installed,
      #   provider        => 'chocolatey',
      #   install_options => ['/passive', '/forcerestart', 'IACCEPTSQLNCLILICENSETERMS=YES'],
      #   #notify          => Reboot['after_choco_run'],
      #   require         => Class['chocolatey']
      # }

      package {'sql-server-management-studio':
        ensure          => installed,
        provider        => 'chocolatey',
        #install_options => ['/passive', '/forcerestart', 'IACCEPTSQLNCLILICENSETERMS=YES'],
        #notify          => Reboot['after_choco_run'],
        require         => Class['chocolatey']
      }

    }

	reboot { 'after_choco_run':
      apply  => finished,
	    }

       }
	}


