Feature: Middlemac produces plist and strings files, uses correct HTML formats,
  and provides useful helpers to generate content.

  As a software developer
  I want to build useable macOS help books.
  
  Background:
	Given a built app at "middlemac_app"
   
  Scenario:
    The correct HTML version must be used on generated files.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "index.html" should contain "<html lang='en'>"
    And the file "testing_world_file.html" should contain "<html lang='en'>"

  Scenario: The Info.plist file must be processed with relevant data.
    When I cd to "New_Project_(pro).help/Contents/"
    And the file "Info.plist" should contain "<string>com.sample.project.pro.help</string>"
    And the file "Info.plist" should contain "<string>New Project</string>"
    And the file "Info.plist" should contain "<string>New Project.helpindex</string>"
    And the file "Info.plist" should contain "<string>New Project Help</string>"
    And the file "Info.plist" should contain "<string>http://www.sample.com</string>"
      
  Scenario: The InfoPlist.strings file must be processed with relevant data.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "InfoPlist.strings" should contain "<string>New Project</string>"
    And the file "InfoPlist.strings" should contain "<string>New Project Help</string>"

  Scenario: The help index file should have been produced.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "New Project.helpindex" should exist
    
  Scenario: The navigation.json file must have relevant data.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "navigation.json" should contain "sample_group_number_two/nested_group_example/page_san.html"
    And the file "navigation.json" should contain '"landing": "topic-Resources-en.lproj",'


  Scenario: The helpers will produce correct output.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "testing_world_file.html" should contain "Resources/SharedGlobalAssets/_partials"
    And the file "testing_world_file.html" should contain "com.sample.project.pro.help"
    And the file "testing_world_file.html" should contain "New Project"
    And the file "testing_world_file.html" should contain "New Project Pro"
    And the file "testing_world_file.html" should contain "3.1.1"
    And the file "testing_world_file.html" should contain "http://www.sample.com"
    And the file "testing_world_file.html" should contain "_new_style_partial"
    And the file "testing_world_file.html" should contain "_partials_dir_partial"
