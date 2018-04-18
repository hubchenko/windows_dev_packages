class windows_dev_packages (

  ####Variables used for install powershell 5.0, including updating .NET and MWF###
  $windows_install_dir          = $windows_dev_packages::params::windows_install_dir,
  $windows_install_file         = $windows_dev_packages::params::windows_install_file,
  $dotNetFile                   = $windows_dev_packages::params::dotNetFile,
  $wmf3_file                    = $windows_dev_packages::params::wmf3_file,
  $wmf5_file                    = $windows_dev_packages::params::wmf5_file,
  
  
  ####Flags to enable/disable windows package installs###
  $install_chocolatey           = $windows_dev_packages::params::install_chocolatey,
  $install_developer_packages   = $windows_dev_packages::params::install_developer_packages,
  $install_networking_packages  = $windows_dev_packages::params::install_networking_packages,
  $install_VMware_packages      = $windows_dev_packages::params::install_VMware_packages,
  $install_HPdev_packages      	= $windows_dev_packages::params::install_VMware_packages,
  $install_newrelic     		= $windows_dev_packages::params::install_newrelic,
  $install_DBA_packages         = $windows_dev_packages::params::install_DBA_packages,


  ####Features to be installed/configured on windows###
  $enable_windows_features      = $windows_dev_packages::params::enable_windows_features,
  $windows_features             = $windows_dev_packages::params::windows_features,

  ####Configuration options outside of base package install###
  $enforce_domain_access        = $windows_dev_packages::params::enforce_domain_access,
  $domain_approved_access       = $windows_dev_packages::params::domain_approved_access,
  $domain_restricted_access     = $windows_dev_packages::params::domain_restricted_access,
  $msft_creds_user              = $windows_dev_packages::params::msft_creds_user,
  $msft_creds_password          = $windows_dev_packages::params::msft_creds_password,

  ####Configuration options outside of base package install###
  $powershell_exe_policy        = $windows_dev_packages::params::powershell_exe_policy,




                          )

inherits windows_dev_packages::params{

  # Anchor this as per #8040 - this ensures that classes won't float off and
  # mess everything up.  You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'windows_dev_packages::begin': } ->
  class { '::windows_dev_packages::updatepowershell': } ->
  class { '::windows_dev_packages::install': } ->
  class { '::windows_dev_packages::windowsfeatures': } ->
  class { '::windows_dev_packages::configure': } ->
  # class { '::windows_dev_packages::service': } ->
  anchor { 'windows_dev_packages::end': }

}