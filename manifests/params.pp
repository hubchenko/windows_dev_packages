# Class: windows_dev_packages::params
#
#
class windows_dev_packages::params {
  $dotNetFile               = "NDP451-KB2858728-x86-x64-AllOS-ENU.exe"
  $install_chocolatey       = true
  $install_developer_packages = true
  $install_networking_packages = true
  $install_VMware_packages  = true
  $install_HPdev_packages   = true
  $install_DBA_packages     = true
  $enforce_domain_access    = true
  $domain_approved_access   = ["AWS\\mygroup_1","AWS\\mygroup_2",]
  $domain_restricted_access = ["AWS\\bad_group1"]
  $msft_creds_user          =        ""
  $msft_creds_password      =        ""
  $powershell_exe_policy    =        "RemoteSigned"
  

# code below works, but only in puppet 4.0. 
###Comment would only apply to machines with 6.1 kernal and above##
#  if ($::powershell_version <= "4.0") and ($::kernelmajversion > '6.1')  {
###code below works, but only in puppet 4.0. 
#  if $::powershell_version <= "4.0" {
  ###puttin in check to to see if box is windows machine first before checking PS version, so module can run
  ### and not cause a runtime error
  if $::kernelmajversion >= '6.1' {
    if versioncmp($::powershell_version, '4.0') <= 0 {
      $windows_install_dir  = directory
      $windows_install_file = file
    }
    else{
      $windows_install_dir = absent
      $windows_install_file = absent
    }
  }

  ####Opertaint Specific Settings###
  case $::operatingsystemmajrelease {
    '2012 R2' : {
      ####Variables used for install powershell 5.0, including updating .NET and MWF###
      $wmf5_file = "Win8.1AndW2K12R2-KB3134758-x64.msu"
      ####Features to be installed/configured on windows###
      $enable_windows_features = true
      $windows_features = ['dsc-service','windowspowershellwebaccess','web-ftp-server','web-ftp-service',
                      'web-ftp-ext','telnet-client','telnet-server', 'ad-domain-services','fs-fileserver',
                      'hyper-v-powershell','hyper-v-tools','gpmc','ipam','ipam-client-feature',
                      'tftp-client','nfs-client','nlb','net-framework-45-aspnet','net-framework-45-core',
                      'net-framework-45-features','net-framework-core','net-framework-features']
    }
    '2012' : {
      ####Variables used for install powershell 5.0, including updating .NET and MWF###
      $wmf5_file = "W2K12-KB3134759-x64.msu"
      ####Features to be installed/configured on windows###
      $enable_windows_features = true
      $windows_features = ['dsc-service','windowspowershellwebaccess','web-ftp-server','web-ftp-service',
                      'web-ftp-ext','telnet-client','telnet-server', 'ad-domain-services','fs-fileserver',
                      'hyper-v-powershell','hyper-v-tools','gpmc','ipam','ipam-client-feature',
                      'tftp-client','nfs-client','nlb','net-framework-45-aspnet','net-framework-45-core',
                      'net-framework-45-features','net-framework-core','net-framework-features']
    }
    '2008 R2' : {
      ####Variables used for install powershell 5.0, including updating .NET and MWF###
      $wmf5_file = "Win7AndW2K8R2-KB3134760-x64.msu"
      $wmf3_file = "Windows6.1-KB2506143-x64.msu"
      ####Features to be installed/configured on windows###
      $enable_windows_features = false
      $windows_features = ['web-ftp-server','web-ftp-service','web-ftp-ext','telnet-client',
                      'telnet-server','fs-fileserver','tftp-client']
    }
    '2008' : {
      ####Variables used for install powershell 5.0, including updating .NET and MWF###
      $enable_windows_features = false
      $wmf3_file = "Windows6.0-KB2506146-x64.msu"
    }
    'default' : {
                fail("The ${module_name} module is not supported on an ${::operatingsystemmajrelease} distribution.")
    }
    }
  }
