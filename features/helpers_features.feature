Feature: Provide helpers and resource items to make multiple targets easy to manage.

  As a software developer
  I want to use helpers and resource items
  In order to enable automatic navigation of items.
  
  Background:
    Given a built app at "middlemac_app"
    
  Scenario:
    The css_image_sizes helper should return CSS for every image in the project
    and @2x images should have proper widths and heights, too.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "goodbye_world_file.html" should contain "img[src$='SharedGlobalAssets/convention/icon_256x256.png'] { max-width: 256px; max-height: 256px; }"
    And the file "goodbye_world_file.html" should contain "img[src$='SharedGlobalAssets/convention/icon_256x256@2x.png'] { max-width: 256px; max-height: 256px; }"
    And the file "goodbye_world_file.html" should contain "img[src$='SharedGlobalAssets/convention/icon_32x32.png'] { max-width: 32px; max-height: 32px; }"
    And the file "goodbye_world_file.html" should contain "img[src$='SharedGlobalAssets/convention/icon_32x32@2x.png'] { max-width: 32px; max-height: 32px; }"


  Scenario:
    The md_images helper should return Markdown references for every image in
    the project.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "goodbye_world_file.html" should contain "[icon_256x256@2x]: /Resources/SharedGlobalAssets/convention/icon_256x256@2x.png"
    And the file "goodbye_world_file.html" should contain "[icon_32x32]: /Resources/SharedGlobalAssets/convention/icon_32x32.png"
    And the file "goodbye_world_file.html" should contain "[icon_32x32@2x]: /Resources/SharedGlobalAssets/convention/icon_32x32@2x.png"


  Scenario:
    The md_links helper should return Markdown references for every HTML file
    in the project, and should include a title generated from the front matter.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "goodbye_world_file.html" should contain '[goodbye_world_file]: #/topic-en.lproj-goodbye_world_file "Goodbye World"'
    And the file "goodbye_world_file.html" should contain '[hello_world_file]: #/topic-en.lproj-hello_world_file "Hello World"'
    And the file "goodbye_world_file.html" should contain '[testing_world_file]: #/topic-en.lproj-testing_world_file "Testing World"'
    
    
  Scenario:
    The extended image tag should include srcset automatically if @2x images are
    present, and not include a srcset if not.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "goodbye_world_file.html" should contain 'img src="/Resources/SharedGlobalAssets/convention/icon_32x32.png" srcset="/Resources/SharedGlobalAssets/convention/icon_32x32.png 1x, /Resources/SharedGlobalAssets/convention/icon_32x32@2x.png 2x" alt="Icon 32x32"'
    And the file "goodbye_world_file.html" should contain 'img src="/Resources/SharedGlobalAssets/convention/icon_256x256.png" srcset="/Resources/SharedGlobalAssets/convention/icon_256x256.png 1x, /Resources/SharedGlobalAssets/convention/icon_256x256@2x.png 2x" alt="Icon 256x256"'
    And the file "goodbye_world_file.html" should contain 'img src="/Resources/en.lproj/assets/images/subdirectory/logo_32x32.png" alt="Logo 32x32"'
    And the file "goodbye_world_file.html" should contain 'img src="/Resources/en.lproj/assets/images/neat_thing_32x32.png" alt="Neat thing 32x32"'
    And the file "goodbye_world_file.html" should contain 'img src="/Resources/en.lproj/assets/images/subdirectory/pro-image_32x32.png" alt="Pro image 32x32"'
    And the file "goodbye_world_file.html" should contain 'img src="/Resources/en.lproj/assets/images/all-graphic_32x32.png" alt="All graphic 32x32'
    And the file "goodbye_world_file.html" should contain 'img src="/Resources/SharedGlobalAssets/images/myfile-NOT_IN_SITEMAP" alt="Myfile not in sitemap"'
    And the file "goodbye_world_file.html" should contain 'img src="/Resources/SharedGlobalAssets/images/myfile-NOT_IN_SITEMAP.png" alt="Myfile not in sitemap"'


  Scenario:
    The link_to helper should return links that are useful to the Apple help
    book engine instead of normal HTML links, unless the link is to a page
    that is not in the project.
    When I cd to "New_Project_(pro).help/Contents/Resources/en.lproj/"
    And the file "goodbye_world_file.html" should contain 'a href="#/topic-en.lproj-hello_world_file"'
    And the file "goodbye_world_file.html" should contain 'a href="#/topic-sample_group_number_two-page_two"'
    And the file "goodbye_world_file.html" should contain 'a href="doesntexist.html"'
