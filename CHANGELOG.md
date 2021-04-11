middlemac change log
====================

- Version 3.1.1 / 2021-April-12

  - Compatibility Updates
      - Version bump.
      - Vendor the source of the fast_trie gem, because it's no longer maintained, and I
        don't want to create another unmaintained Ruby gem. Updates to fast_trie are needed
        because Clang now has added diagnostics including default C99 which causes the
        original fast_trie to no longer build. I've also silenced warnings.
      - Make the landing page use target magic images instead of the static image it uses.
        This means you should have `target1-icon_256x256` and `target2-icon_256x256` in
        your images, or to use the same icon for all targets, `all-icon_256x256`.
      - Enforce a newer minimum Middleman version, because it has removed support for
        automatic alt attributes, and we've done the same. This keeps us in sync.
      - Enforce Ruby versions. Right now Ruby 2.6.0 approaching 3.0 is supported. Once
        Middleman has a numbered release supporting Ruby 3.0, I'll take a look at supporting
        it.

- Version 3.1.0 / 2019-October-11

  - Version 3.1.0
    - Introduce a couple of new options in order to influence the file name of the
      help book.
  - Added .gitattributes for proper language reporting in GitHub.
    No version bump.
    No new gem.

- Version 3.0.1 / 2019-September-08

  - Bump to 3.0.1:
    - Fix YAML parsing issue for picky parsers.
    - Added redirect files, to avoid recent macOS issue where /Resources/index.html
      and the language.lproj/index.html files would confuse help viewer.
    - Updated tests
    - Updated documentation in the documentation project.

- Version 3.0.0 / 2018-June-18

  - All new Middlemac 3.0.
  - Git Commit Issues Fix
      - Ensure that build.sh is captured in version control.
      - Added blank build.sh. Todo is recreate this. Sorry.

- Version 2.0.0 / 2016-May-15

  - Touchup changelog, and release gem.
  - All new Middlemac version 2.0.0!
      - _Significant_, major upgrade to _Middlemac_.
      - Now packaged as a real Ruby gem.
      - Uses the latest Middleman 4.1 series (4.1.7 or newer required).
      - This version _will_ break old projects.
      - Read the full documentation to understand the full scope of changes.
  - - Updated to newer middleman.
    - Use font-awesome-sass gem instead of keeping it in the file system.
  - Fixed 256x256 image file.
  - Added built output. RC1
  - Content. Readme. Version.
  - Ibid.
  - More content added.
  - Typo.
  - More content
  - More yummy content\!
  - Partials overview complete.
  - More content. yay
  - Added new content.
  - Header information added.
  - Header information added.
  - Content cleanup; new features content.
  - Reverted to full breadcrumbs; breadcrumb css tweak.
  - Separate navigate (children do) and navigator (I do)
  - Content enhancements.
  - Fixed indentation error.
  - README, getting started.
  - Overhaul of helpers and sitemap manipulators complete.
  - BRETHREN checkpoint
