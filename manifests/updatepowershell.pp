class windows_dev_packages::updatepowershell inherits windows_dev_packages {

  ####Variables used for install###

  if $::kernel == "windows" {
    
    file {'WindowsDev':
          ensure  => $windows_dev_packages::windows_install_dir,
          path  => 'C:\WindowsDev',
          force => true,

        }

    file {'451DotNet':
      ensure  => $windows_dev_packages::windows_install_file,
      path  => "C:\\WindowsDev\\$windows_dev_packages::dotNetFile",
      source  => "puppet:///modules/windows_dev_packages/$windows_dev_packages::dotNetFile",
      source_permissions  => ignore,
      require => File['WindowsDev'],
      }
    exec { '451DotNet':
      command   => "C:\\WindowsDev\\$windows_dev_packages::dotNetFile  /quiet /norestart | out-null",
      require   => File['451DotNet'],
      provider  => powershell,
      notify    => Reboot['after_451DotNet_install'],
      onlyif    => "if (Test-Path  C:\\WindowsDev\\$windows_dev_packages::dotNetFile) {Exit 0} else {exit 1}",

      }

    if $::operatingsystemmajrelease == '2008 R2' {
        file {'wmf3':
          ensure  => $windows_dev_packages::windows_install_file,
          path  => "C:\\WindowsDev\\$windows_dev_packages::wmf3_file",
          source  => "puppet:///modules/windows_dev_packages/$windows_dev_packages::wmf3_file",
          source_permissions  => ignore,
          require => [File['WindowsDev'], Exec['451DotNet']],
          }
        exec { 'wmf3':
          command   => "C:\\Windows\\System32\\wusa.exe C:\\WindowsDev\\$windows_dev_packages::wmf3_file /quiet /norestart | out-null",
          require   => File['wmf3'],
          before    => File['wmf5'],
          provider  => powershell,
          onlyif    => "if (Test-Path  C:\\WindowsDev\\$windows_dev_packages::wmf3_file) {Exit 0} else {exit 1}",
          notify    => Reboot['after_451DotNet_install'],
          }

    }

    file {'wmf5':
      ensure  => $windows_dev_packages::windows_install_file,
      path  => "C:\\WindowsDev\\$windows_dev_packages::wmf5_file",
      source  => "puppet:///modules/windows_dev_packages/$windows_dev_packages::wmf5_file",
      source_permissions  => ignore,
      require => [File['WindowsDev'], Exec['451DotNet']],
      }
    exec { 'wmf5':
      command   => "C:\\Windows\\System32\\wusa.exe C:\\WindowsDev\\$windows_dev_packages::wmf5_file /quiet /norestart | out-null",
      require   => File['wmf5'], 
      provider  => powershell,
      onlyif    => "if (Test-Path  C:\\WindowsDev\\$windows_dev_packages::wmf3_file) {Exit 0} else {exit 1}",
      notify    => Reboot['after_451DotNet_install'],
      }

    reboot { 'after_451DotNet_install':
      }
    }
  }
