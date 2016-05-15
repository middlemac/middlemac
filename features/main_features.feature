Feature: Middlemac produces plist and strings files, uses correct HTML formats,
  and provides useful helpers to generate content.

  As a software developer
  I want to build useable Mac OS X help books.
  
  Background:
    Given a built app at "middlemac_app"
    
  Scenario:
    The correct HTML version must be used on the top level index page versus
    other pages in the project.
    When I cd to "New Project (pro).help/Contents/Resources/Base.lproj/"
    And the file "index.html" should contain "DTD XHTML 1.0 Strict"
    And the file "testing_world_file.html" should contain "DTD HTML 4.01"

  Scenario: The Info.plist file must be processed with relevant data.
    When I cd to "New Project (pro).help/Contents/"
    And the file "Info.plist" should contain "<string>com.sample.project.pro.help</string>"
    And the file "Info.plist" should contain "<string>New Project</string>"
    And the file "Info.plist" should contain "<string>New Project.helpindex</string>"
    And the file "Info.plist" should contain "<string>New Project Help</string>"
    And the file "Info.plist" should contain "<string>http://www.sample.com</string>"
      
  Scenario: The InfoPlist.strings file must be processed with relevant data.
    When I cd to "New Project (pro).help/Contents/Resources/Base.lproj/"
    And the file "InfoPlist.strings" should contain "<string>New Project</string>"
    And the file "InfoPlist.strings" should contain "<string>New Project Help</string>"

  Scenario: The help index file should have been produced.
    When I cd to "New Project (pro).help/Contents/Resources/Base.lproj/"
    And the file "New Project.helpindex" should exist

  Scenario: The helpers will produce correct output.
    When I cd to "New Project (pro).help/Contents/Resources/Base.lproj/"
    And the file "testing_world_file.html" should contain "breadcrumbs:nav_breadcrumbs"
    And the file "testing_world_file.html" should contain "partials_dir:Resources/Base.lproj/assets/partials"
    And the file "testing_world_file.html" should contain "cfBundleIdentifier:com.sample.project.pro.help"
    And the file "testing_world_file.html" should contain "cfBundleName:New Project"
    And the file "testing_world_file.html" should contain "product_name:New Project Pro"
    And the file "testing_world_file.html" should contain "product_version:2.0.0.wip"
    And the file "testing_world_file.html" should contain "product_uri:http://www.sample.com"
    And the file "testing_world_file.html" should contain "_new_style_partial"
    And the file "testing_world_file.html" should contain "_partials_dir_partial"
