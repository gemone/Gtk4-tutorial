# test_lib_src2md.rb
require 'minitest/autorun'
require 'fileutils'
require 'diff/lcs'
require_relative '../lib/lib_src2md.rb'

module Prepare_test
  def files
    # Many kinds of file types are supported.
    # .c => C, .h => C, .rb => ruby, Rakefile, => ruby, .xml => xml, .ui => xml, .y => bison, .lex => lex, .build => meson, .md => markdown, Makefile => makefile

    sample_c = <<~'EOS'
    /* This comment is very long, longer than 100. It must be folded if this file is converted to latex. Because latex doesn't care about verbatim lines. The lines are printed as they are. */
    #include <stdio.h>

    void
    printf_something (char *something) {
      printf ("%s\n", something);
    }

    int
    main (int argc, char **argv) {
      printf_something ("Hello world.");
    }
    EOS

    sample_h = <<~'EOS'
    #include <gtk/gtk.h>
    EOS

    sample_rb = <<~'EOS'
    print "Hello ruby.\n"
    EOS

    rakefile = <<~'EOS'
    task default: "a.out"
    file "a.out" => "sample.c" do
      sh "gcc sample.c"
    end
    EOS

    sample_xml = <<~'EOS'
    <div class="h1" color="red">Fatal error!!</div>
    EOS

    sample_ui = <<~'EOS'
    <object class="GtkWindow" id="win"></object>
    EOS

    sample_y = <<~'EOS'
    program: statement | program statement ;
    EOS

    sample_lex = <<~'EOS'
    [a-zA-Z0-9]    return ALNUM;
    EOS

    sample_build = <<~'EOS'
    project('sampe', 'c')
    EOS

    sample0_md = <<~'EOS'
    # Sample text in maridown language
    EOS

    makefile = <<~'EOS'
    a.out: sample.c
    	cc sample.c
    EOS

    sample_src_md = <<~'EOS'
    # Sample.src.md

    This .src.md file is made for the test for lib_src2md.rb.

    Sample.c with line number is:

    @@@include
     sample.c
    @@@

    The following is also Sample.c with line number.

    @@@include -n
     sample.c
    @@@

    The following is Sample.c without line number.

    @@@include -N
     sample.c
    @@@

    The following prints only `printf_something`.

    @@@include
    sample.c printf_something
    @@@

    The following prints `printf_something` and `main`.

    @@@include
    sample.c printf_something main
    @@@

    Check info string.

    @@@include
    sample.c
    sample.h
    sample.rb
    Rakefile
    sample.xml
    sample.ui
    sample.y
    sample.lex
    sample.build
    sample0.md
    @@@

    Compile sample.c with rake like this:

    @@@shell
    rake
    @@@

    @@@shell
    echo "This text is very long, longer than 100. It must be folded if this file is converted to latex. Because latex doesn't care about verbatim lines. The lines are printed as they are."
    @@@

    The target type is:

    @@@if gfm
    gfm
    @@@elif html
    html
    @@@elif latex
    latex
    @@@end

    [Relative link](sample.c) will be converted when the target type is gfm or html.
    Otherwise (latex) the link will be removed.

    Another [relative link](../../Rakefile).

    [Absolute link](https://github.com/ToshioCP) is kept as it is.

    Image link.
    If the target type is gfm or html, the size will be removed.
    Otherwise (latex) it remains.

    ![Screenshot of the box](../../image/screenshot_lb4.png){width=6.3cm height=5.325cm}
    EOS

    sample_md_gfm = <<~EOS
    # Sample.src.md

    This .src.md file is made for the test for lib_src2md.rb.

    Sample.c with line number is:

    ~~~C
    #{i=1;sample_c.lines.each {|line| line.replace(sprintf("%#2d %s", i, line)); i+=1}.join}~~~

    The following is also Sample.c with line number.

    ~~~C
    #{i=1;sample_c.lines.each {|line| line.replace(sprintf("%#2d %s", i, line)); i+=1}.join}~~~

    The following is Sample.c without line number.

    ~~~C
    #{sample_c}~~~

    The following prints only `printf_something`.

    ~~~C
    1 void
    2 printf_something (char *something) {
    3   printf ("%s\\n", something);
    4 }
    ~~~

    The following prints `printf_something` and `main`.

    ~~~C
    1 void
    2 printf_something (char *something) {
    3   printf ("%s\\n", something);
    4 }
    5#{' '}
    6 int
    7 main (int argc, char **argv) {
    8   printf_something ("Hello world.");
    9 }
    ~~~

    Check info string.

    ~~~C
    #{i=1;sample_c.lines.each {|line| line.replace(sprintf("%#2d %s", i, line)); i+=1}.join}~~~
    ~~~C
    #{i=1;sample_h.lines.each {|line| line.replace(sprintf("%#1d %s", i, line)); i+=1}.join}~~~
    ~~~ruby
    #{i=1;sample_rb.lines.each {|line| line.replace(sprintf("%#1d %s", i, line)); i+=1}.join}~~~
    ~~~ruby
    #{i=1;rakefile.lines.each {|line| line.replace(sprintf("%#1d %s", i, line)); i+=1}.join}~~~
    ~~~xml
    #{i=1;sample_xml.lines.each {|line| line.replace(sprintf("%#1d %s", i, line)); i+=1}.join}~~~
    ~~~xml
    #{i=1;sample_ui.lines.each {|line| line.replace(sprintf("%#1d %s", i, line)); i+=1}.join}~~~
    ~~~bison
    #{i=1;sample_y.lines.each {|line| line.replace(sprintf("%#1d %s", i, line)); i+=1}.join}~~~
    ~~~lex
    #{i=1;sample_lex.lines.each {|line| line.replace(sprintf("%#1d %s", i, line)); i+=1}.join}~~~
    ~~~meson
    #{i=1;sample_build.lines.each {|line| line.replace(sprintf("%#1d %s", i, line)); i+=1}.join}~~~
    ~~~markdown
    #{i=1;sample0_md.lines.each {|line| line.replace(sprintf("%#1d %s", i, line)); i+=1}.join}~~~

    Compile sample.c with rake like this:

    ~~~
    $ rake
    ~~~

    ~~~
    $ echo "This text is very long, longer than 100. It must be folded if this file is converted to latex. Because latex doesn't care about verbatim lines. The lines are printed as they are."
    This text is very long, longer than 100. It must be folded if this file is converted to latex. Because latex doesn't care about verbatim lines. The lines are printed as they are.
    ~~~

    The target type is:

    gfm

    [Relative link](../temp/sample.c) will be converted when the target type is gfm or html.
    Otherwise (latex) the link will be removed.

    Another [relative link](../../Rakefile).

    [Absolute link](https://github.com/ToshioCP) is kept as it is.

    Image link.
    If the target type is gfm or html, the size will be removed.
    Otherwise (latex) it remains.

    ![Screenshot of the box](../../image/screenshot_lb4.png)
    EOS

    sample_md_html = <<~EOS
    # Sample.src.md

    This .src.md file is made for the test for lib_src2md.rb.

    Sample.c with line number is:

    ~~~{.C .numberLines}
    #{sample_c}~~~

    The following is also Sample.c with line number.

    ~~~{.C .numberLines}
    #{sample_c}~~~

    The following is Sample.c without line number.

    ~~~{.C}
    #{sample_c}~~~

    The following prints only `printf_something`.

    ~~~{.C .numberLines}
    void
    printf_something (char *something) {
      printf ("%s\\n", something);
    }
    ~~~

    The following prints `printf_something` and `main`.

    ~~~{.C .numberLines}
    void
    printf_something (char *something) {
      printf ("%s\\n", something);
    }

    int
    main (int argc, char **argv) {
      printf_something ("Hello world.");
    }
    ~~~

    Check info string.

    ~~~{.C .numberLines}
    #{sample_c}~~~
    ~~~{.C .numberLines}
    #{sample_h}~~~
    ~~~{.ruby .numberLines}
    #{sample_rb}~~~
    ~~~{.ruby .numberLines}
    #{rakefile}~~~
    ~~~{.xml .numberLines}
    #{sample_xml}~~~
    ~~~{.xml .numberLines}
    #{sample_ui}~~~
    ~~~{.bison .numberLines}
    #{sample_y}~~~
    ~~~{.lex .numberLines}
    #{sample_lex}~~~
    ~~~{.numberLines}
    #{sample_build}~~~
    ~~~{.markdown .numberLines}
    #{sample0_md}~~~

    Compile sample.c with rake like this:

    ~~~
    $ rake
    ~~~

    ~~~
    $ echo "This text is very long, longer than 100. It must be folded if this file is converted to latex. Because latex doesn't care about verbatim lines. The lines are printed as they are."
    This text is very long, longer than 100. It must be folded if this file is converted to latex. Because latex doesn't care about verbatim lines. The lines are printed as they are.
    ~~~

    The target type is:

    html

    [Relative link](../temp/sample.c) will be converted when the target type is gfm or html.
    Otherwise (latex) the link will be removed.

    Another [relative link](../../Rakefile).

    [Absolute link](https://github.com/ToshioCP) is kept as it is.

    Image link.
    If the target type is gfm or html, the size will be removed.
    Otherwise (latex) it remains.

    ![Screenshot of the box](../../image/screenshot_lb4.png)
    EOS

    sample_md_latex = <<~EOS
    # Sample.src.md

    This .src.md file is made for the test for lib_src2md.rb.

    Sample.c with line number is:

    ~~~{.C .numberLines}
    #{sample_c}~~~

    The following is also Sample.c with line number.

    ~~~{.C .numberLines}
    #{sample_c}~~~

    The following is Sample.c without line number.

    ~~~{.C}
    #{sample_c}~~~

    The following prints only `printf_something`.

    ~~~{.C .numberLines}
    void
    printf_something (char *something) {
      printf ("%s\\n", something);
    }
    ~~~

    The following prints `printf_something` and `main`.

    ~~~{.C .numberLines}
    void
    printf_something (char *something) {
      printf ("%s\\n", something);
    }

    int
    main (int argc, char **argv) {
      printf_something ("Hello world.");
    }
    ~~~

    Check info string.

    ~~~{.C .numberLines}
    #{sample_c}~~~
    ~~~{.C .numberLines}
    #{sample_h}~~~
    ~~~{.ruby .numberLines}
    #{sample_rb}~~~
    ~~~{.ruby .numberLines}
    #{rakefile}~~~
    ~~~{.xml .numberLines}
    #{sample_xml}~~~
    ~~~{.xml .numberLines}
    #{sample_ui}~~~
    ~~~{.numberLines}
    #{sample_y}~~~
    ~~~{.numberLines}
    #{sample_lex}~~~
    ~~~{.numberLines}
    #{sample_build}~~~
    ~~~{.numberLines}
    #{sample0_md}~~~

    Compile sample.c with rake like this:

    ~~~
    $ rake
    ~~~

    ~~~
    $ echo "This text is very long, longer than 100. It must be folded if this file is converted to latex. Because latex doesn't care about verbatim lines. The lines are printed as they are."
    This text is very long, longer than 100. It must be folded if this file is converted to latex. Because latex doesn't care about verbatim lines. The lines are printed as they are.
    ~~~

    The target type is:

    latex

    Relative link will be converted when the target type is gfm or html.
    Otherwise (latex) the link will be removed.

    Another relative link.

    [Absolute link](https://github.com/ToshioCP) is kept as it is.

    Image link.
    If the target type is gfm or html, the size will be removed.
    Otherwise (latex) it remains.

    ![Screenshot of the box](../../image/screenshot_lb4.png){width=6.3cm height=5.325cm}
    EOS

    # -------------------
    #  Return the follwoing array.
    # -------------------
    {files: [
        [sample_c, "sample.c", "C"],
        [sample_h, "sample.h", "C"],
        [sample_rb, "sample.rb", "ruby"],
        [rakefile, "Rakefile", "ruby"],
        [sample_xml, "sample.xml", "xml"],
        [sample_ui, "sample.ui", "xml"],
        [sample_y, "sample.y", "bison"],
        [sample_lex, "sample.lex", "lex"],
        [sample_build, "sample.build", "meson"],
        [sample0_md, "sample0.md", "markdown"],
        [makefile, "Makefile", "makefile"],
        [sample_src_md, "sample.src.md", nil]
      ],
    sample_md_gfm: sample_md_gfm,
    sample_md_html: sample_md_html,
    sample_md_latex: sample_md_latex
  }
  end
end

class Test_lib_src_file < Minitest::Test
  include FileUtils
  include Prepare_test

  def test_string_partitions
    sample = <<~'EOS'
    For further information, See [Section 1](sec1.src.md).
    ![image](../image/image.png){width=4cm, height=4cm}
    The diagram above shows the relation among groups.
    Refer to [Document](https://doc.sampeluniv.ac.jp).
    EOS
    expected = [
    "For further information, See ",
    "[Section 1](sec1.src.md)",
    ".\n",
    "![image](../image/image.png){width=4cm, height=4cm}",
    "\nThe diagram above shows the relation among groups.\nRefer to ",
    "[Document](https://doc.sampeluniv.ac.jp)",
    ".\n"
    ]
    actual = sample.partitions(/!?\[.*?\]\(.*?\)(\{.*?\})?/)
    assert_equal expected, actual
  end
  def test_lang
    files()[:files].each do |f|
      assert_equal f[2], lang(f[1], "gfm") if f[2]
      assert_equal f[2], lang(f[1], "html") if f[2] && f[2]=~/C|ruby|xml|markdown|bison|lex|makefile/
      assert_equal f[2], lang(f[1], "latex") if f[2] && f[2]=~/C|ruby|xml|makefile/
      assert_equal "", lang(f[1], "gfm") if f[2] == nil
      assert_equal "", lang(f[1], "html") if f[2] == nil || !f[2]=~/C|ruby|xml|markdown|bison|lex|makefile/
      assert_equal "", lang(f[1], "latex") if f[2] == nil || !f[2]=~/C|ruby|xml|makefile/
    end
  end
  def test_width
    assert_equal [1,1,2,2,3,3,4,4,5,5], [1,9,10,99,100,999,1000,9999,10000,99999].map{|n| width(n)}
  end
  def test_at_if_else
    str = <<~'EOS'
    head
    @@@if gfm
    gfm
    @@@elif html
    html
    @@@elif latex
    latex
    @@@else
    others
    @@@end
    tail
    EOS
    assert_equal "head\ngfm\ntail\n", at_if_else(str, "gfm")
    assert_equal "head\nhtml\ntail\n", at_if_else(str, "html")
    assert_equal "head\nlatex\ntail\n", at_if_else(str, "latex")
    assert_equal "head\nothers\ntail\n", at_if_else(str, "others")
  end
  def test_do_include
    temp = "temp_do_include"+Time.now.to_f.to_s.gsub(/\./,'')
    Dir.mkdir(temp) unless Dir.exist?(temp)
    File.write("#{temp}/temp.c", <<~'EOS')
      #include <stdio.h>
      int
      fact(int n) {
        int f;

        if (n < 0)
          return -1; /* error */
        if (n == 0)
          return 1;
        for (f = 1; n >= 1; --n)
          f *= n;
        return f;
      }

      int
      main (int argc, char **argv) {
        printf ("%d\n", fact(5));
      }
    EOS
    expected_c_gfm = <<~EOS
      ~~~C
       1 #include <stdio.h>
       2 int
       3 fact(int n) {
       4   int f;
       5#{" "}
       6   if (n < 0)
       7     return -1; /* error */
       8   if (n == 0)
       9     return 1;
      10   for (f = 1; n >= 1; --n)
      11     f *= n;
      12   return f;
      13 }
      14#{" "}
      15 int
      16 main (int argc, char **argv) {
      17   printf ("%d\\n", fact(5));
      18 }
      ~~~
    EOS
    expected_c_pandoc = <<~'EOS'
      ~~~{.C .numberLines}
      #include <stdio.h>
      int
      fact(int n) {
        int f;

        if (n < 0)
          return -1; /* error */
        if (n == 0)
          return 1;
        for (f = 1; n >= 1; --n)
          f *= n;
        return f;
      }

      int
      main (int argc, char **argv) {
        printf ("%d\n", fact(5));
      }
      ~~~
    EOS
    File.write("#{temp}/temp.rb", <<~'EOS')
      src = File.read("temp.c")
      words = src.split(/\W/).reject{|s| s==""}.uniq.sort
      print "Words are:\n"
      words.each {|word| print "#{word}\n"}
    EOS
    expected_ruby_gfm = <<~'EOS'
    ~~~ruby
    src = File.read("temp.c")
    words = src.split(/\W/).reject{|s| s==""}.uniq.sort
    print "Words are:\n"
    words.each {|word| print "#{word}\n"}
    ~~~
    EOS
    expected_ruby_n_gfm = <<~'EOS'
    ~~~ruby
    1 src = File.read("temp.c")
    2 words = src.split(/\W/).reject{|s| s==""}.uniq.sort
    3 print "Words are:\n"
    4 words.each {|word| print "#{word}\n"}
    ~~~
    EOS
    expected_ruby_pandoc = <<~'EOS'
    ~~~{.ruby}
    src = File.read("temp.c")
    words = src.split(/\W/).reject{|s| s==""}.uniq.sort
    print "Words are:\n"
    words.each {|word| print "#{word}\n"}
    ~~~
    EOS
    expected_c_main_gfm = <<~EOS
      ~~~C
      1 int
      2 main (int argc, char **argv) {
      3   printf ("%d\\n", fact(5));
      4 }
      ~~~
    EOS
    actual_c_gfm = do_include("@@@include -n\ntemp.c\n@@@\n", temp, "gfm")
    actual_c_pandoc = do_include("@@@include\ntemp.c\n@@@\n", temp, "html")
    actual_ruby_gfm = do_include("@@@include -N\ntemp.rb\n@@@\n", temp, "gfm")
    actual_ruby_pandoc = do_include("@@@include -N\ntemp.rb\n@@@\n", temp, "latex")
    actual_c_ruby_gfm = do_include("@@@include -n\ntemp.c\ntemp.rb\n@@@\n", temp, "gfm")
    actual_c_main_gfm = do_include("@@@include -n\ntemp.c main\n@@@\n", temp, "gfm")
    remove_entry_secure(temp)
    # If you want to see the difference
    # p Diff::LCS.diff(expected_c_gfm.each_line.to_a, actual_c_gfm.each_line.to_a)
    # p Diff::LCS.diff(expected_c_pandoc.each_line.to_a, actual_c_pandoc.each_line.to_a)
    assert_equal expected_c_gfm, actual_c_gfm
    assert_equal expected_c_pandoc, actual_c_pandoc
    assert_equal expected_ruby_gfm, actual_ruby_gfm
    assert_equal expected_ruby_pandoc, actual_ruby_pandoc
    assert_equal expected_c_gfm+expected_ruby_n_gfm, actual_c_ruby_gfm
    assert_equal expected_c_main_gfm, actual_c_main_gfm
  end
  def test_do_shell
    actual = do_shell("@@@shell\necho abc\n@@@\n", ".")
    expected = "~~~\n$ echo abc\nabc\n~~~\n"
    assert_equal expected, actual
  end
  # Change relative links in the secXX.src.md to the one in gfm/secXX.md, html/secXX.html or latex/secXX.tex
  # Example:
  #  src=>gfm:  [Section 1](sec1.src.md) => [Section 1](sec1.md)
  #  src=>html:  [Section 1](sec1.src.md) => [Section 1](sec1.html)
  #  src=>latex:  [Section 1](sec1.src.md) => Section 1
  #  src=>gfm:  [document](../doc/document.md) => [document](document.md)
  #  src=>html:  [document](../doc/document.md) => [document]document.html
  #  src=>latex:  [document](../doc/document.md) => document
  #  src=>latex:  [Github](https://github.com/ToshioCP) => [Github](https://github.com/ToshioCP)
  # The examples above are simple. But some source files are located in the different directories.
  #  src/abstract.src.md => ./Readme.md: [Section 1](src/sec1.src.md) => [Section 1](gfm/sec1.md).
  #  src/abstract.src.md => html/index.md: [Section 1](src/sec1.src.md) => [Section 1](sec1.html).
  #  src/abstract.src.md => latex/abstract.md: [Section 1](src/sec1.src.md) => Section 1
  #  src/turtle/turtle_doc.src.md => src/turtle/turtle_doc.md: [Section 1](../sec1.src.md) => [Section 1](../../gfm/sec1.md)
  #  src/turtle/turtle_doc.src.md => gfm/turtle_doc.md: [Section 1](../sec1.src.md) => [Section 1](sec1.md)
  def test_change_link
    src_src = <<~'EOS'
      [Section 1](sec1.src.md)
      [document](../doc/document.src.md)
      ![image](../image/image.png){width=9.0cm height=6.0cm}
      [Github](https://github.com/ToshioCP)
    EOS
    src_top = "[Section 1](src/sec1.src.md)\n"
    src_turtle = "[Section 1](../sec1.src.md)\n"
    dst_src = <<~'EOS'
      [Section 1](sec1.md)
      [document](document.md)
      ![image](../image/image.png)
      [Github](https://github.com/ToshioCP)
    EOS
    assert_equal dst_src, change_link(src_src, "src", "gfm", "gfm")
    dst_src = <<~'EOS'
      [Section 1](sec1.html)
      [document](document.html)
      ![image](../image/image.png)
      [Github](https://github.com/ToshioCP)
    EOS
    assert_equal dst_src, change_link(src_src, "src", "html", "html")
    dst_src = <<~'EOS'
      Section 1
      document
      ![image](../image/image.png){width=9.0cm height=6.0cm}
      [Github](https://github.com/ToshioCP)
    EOS
    assert_equal dst_src, change_link(src_src, "src", "latex", "latex")
    assert_equal "[Section 1](sec1.md)\n", change_link(src_top, ".", "gfm", ".")
    assert_equal "[Section 1](sec1.html)\n", change_link(src_top, ".", "html", "html")
    assert_equal "Section 1\n", change_link(src_top, ".", "latex", "latex")
    assert_equal "[Section 1](sec1.md)\n", change_link(src_turtle, "turtle", "gfm", "turtle")
    assert_equal "[Section 1](sec1.md)\n", change_link(src_turtle, "turtle", "gfm", "gfm")

    assert_equal "[sample.c](../test/temp/sample.c)", change_link("[sample.c](temp/sample.c)", "test", "gfm")
    assert_equal "[Section 3](sec3.md)", change_link("[Section 3](sec3.src.md)", "src", "gfm")
    assert_equal "[Section 3](sec3.html)", change_link("[Section 3](sec3.src.md)", "src", "html")
    assert_equal "Section 3", change_link("[Section 3](sec3.src.md)", "src", "latex")
  end
  def test_src2md
    temp = "temp"
    Dir.mkdir(temp) unless Dir.exist?(temp)
    files()[:files].each do |f|
      File.write "#{temp}/#{f[1]}", f[0]
    end
    dst_dirs = ["gfm", "html", "latex"]
    dst_md = {}
    dst_dirs.each do |d|
      Dir.mkdir(d) unless Dir.exist?(d)
      src2md "#{temp}/sample.src.md", "#{d}/sample.md", d
      dst_md[d] = File.read "#{d}/sample.md"
      remove_entry_secure(d)
    end
    remove_entry_secure(temp)

    # If you want to see the difference
    # Diff::LCS.diff(files()[:sample_md_gfm].each_line.to_a, dst_md["gfm"].each_line.to_a).each do |array|
    #   array.each do |change|
    #     print "#{change.action}  #{change.position.to_s.chomp}: #{change.element.to_s.chomp}\n"
    #   end
    # end
    # Diff::LCS.diff(files()[:sample_md_latex].each_line.to_a, dst_md["latex"].each_line.to_a).each do |array|
    #   array.each do |change|
    #     print "#{change.action}  #{change.position.to_s.chomp}: #{change.element.to_s.chomp}\n"
    #   end
    # end
    assert_equal files()[:sample_md_gfm], dst_md["gfm"]
    assert_equal files()[:sample_md_html], dst_md["html"]
    assert_equal files()[:sample_md_latex], dst_md["latex"]
  end

end
