# Uncomment the next line to define a global platform for your project
platform :ios, '9.3'

target 'bitradio' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for breadwallet
  pod 'Buglife'

  # colored blur effects
  pod "VisualEffectView"
  
  # View Debugging
  pod 'Reveal-SDK', :configurations => ['Debug']
  
  target 'bitradioTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'bitradioUITests' do
    inherit! :search_paths
    # Pods for testing
  end

    post_install do | installer |
        require 'fileutils'
        FileUtils.cp_r('Pods/Target Support Files/Pods-bitradio/Pods-bitradio-Acknowledgements.plist', 'breadwallet/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    end

end
