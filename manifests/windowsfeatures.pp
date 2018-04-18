class windows_dev_packages::windowsfeatures inherits windows_dev_packages {

  ####Variables used for install###

  if $::kernel == "windows" {
    if $windows_dev_packages::enable_windows_features {

      windowsfeature {$windows_features:
        ensure             => present,
        installsubfeatures => true,
        installmanagementtools => true,
        notify             => Reboot['after_feature_run'],
                }

      reboot { 'after_feature_run':
      apply  => finished,
              }
            }
          }
        }