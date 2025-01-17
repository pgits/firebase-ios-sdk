Pod::Spec.new do |s|
  s.name             = 'FirebaseInstanceID'
  s.version          = '4.2.7'
  s.summary          = 'Firebase InstanceID for iOS'

  s.description      = <<-DESC
Instance ID provides a unique ID per instance of your iOS apps. In addition to providing
unique IDs for authentication,Instance ID can generate security tokens for use with other
services.
                       DESC

  s.homepage         = 'https://firebase.google.com'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.authors          = 'Google, Inc.'

  s.source           = {
    :git => 'https://github.com/firebase/firebase-ios-sdk.git',
    :tag => 'InstanceID-' + s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/Firebase'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '10.0'

  s.cocoapods_version = '>= 1.4.0'
  s.static_framework = true
  s.prefix_header_file = false

  base_dir = "Firebase/InstanceID/"
  s.source_files = base_dir + '**/*.[mh]'
  s.requires_arc = base_dir + '*.m'
  s.public_header_files = base_dir + 'Public/*.h', base_dir + 'Private/*.h'
  s.private_header_files = base_dir + 'Private/*.h'
  s.pod_target_xcconfig = {
    'GCC_C_LANGUAGE_STANDARD' => 'c99',
    'GCC_PREPROCESSOR_DEFINITIONS' =>
      'FIRInstanceID_LIB_VERSION=' + String(s.version)
  }
  s.framework = 'Security'
  s.dependency 'FirebaseCore', '~> 6.4' # Should go to 6.5 in M61 for new private header access
  s.dependency 'GoogleUtilities/UserDefaults', '~> 6.0'
  s.dependency 'GoogleUtilities/Environment', '~> 6.0'

  s.test_spec 'unit' do |unit_tests|
    unit_tests.source_files = 'Example/InstanceID/Tests/*.[mh]'
    unit_tests.requires_app_host = true
    unit_tests.dependency 'OCMock'
    unit_tests.pod_target_xcconfig = {
      # Unit tests do library imports using repo-root relative paths.
      'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"',
      # Prevent linker warning for test category override of
      # store:didDeleteFCMScopedTokensForCheckin:
      'OTHER_LDFLAGS' => '-Xlinker -no_objc_category_merging',
      'CLANG_ENABLE_OBJC_WEAK' => 'YES'
   }
  end
end
