require File.join(File.dirname(__FILE__), 'setup_test')

class TestTextiled < Test::Unit::TestCase
  fixtures :stories, :authors

  def test_desc_is_html
    story = Story.find(1)

    desc_html    = '_why announces <i>Sandbox</i>'
    desc_textile = '_why announces __Sandbox__'
    desc_plain   = '_why announces Sandbox'

    assert_equal desc_html, story.description
    assert_equal desc_textile, story.description_source
    assert_equal desc_plain, story.description_plain
  end

  def test_desc_after_save
    story = Story.find(2)
    
    start_html = '<i>Beautify</i> your <strong>IRb</strong> prompt'
    assert_equal start_html, story.description

    story.description = "**IRb** is simple"
    changed_html = "<b>IRb</b> is simple"
    assert_equal changed_html, story.description
    story.save
    assert_equal changed_html, story.description
    assert_equal 'IRb is simple', story.description_plain
  end

  def test_desc_toggle_textile
    story = Story.find(2)
    
    desc_html = '<i>Beautify</i> your <strong>IRb</strong> prompt'
    desc_textile = '__Beautify__ your *IRb* prompt'

    assert_equal desc_html, story.description
    story.textiled = false
    assert_equal desc_textile, story.description
    story.save
    assert_equal desc_textile, story.description
    story.textiled = true
    assert_equal desc_html, story.description
  end

  def test_assocation_textiled
    story = Story.find(2)

    blog_html = '<a href="http://ozmm.org">ones zeros majors and minors</a>'
    blog_textile = '"ones zeros majors and minors":http://ozmm.org'
    blog_plain = 'ones zeros majors and minors'

    assert_equal blog_html, story.author.blog
    assert_equal blog_textile, story.author.blog_source
    assert_equal blog_plain, story.author.blog_plain
  end

  def test_assocation_textile_toggle
    story = Story.find(1)

    blog_html = '<a href="http://redhanded.hobix.com">RedHanded</a>'
    blog_textile = '"RedHanded":http://redhanded.hobix.com'
    blog_plain = 'RedHanded'

    assert_equal blog_html, story.author.blog
    story.author.textiled = false
    assert_equal blog_textile, story.author.blog
    story.author.textiled = true
    assert_equal blog_html, story.author.blog
  end

  def test_body_is_html
    story = Story.find(3)

    body_html = %[<p><em>Textile</em> is useful because it makes text <em>slightly</em> easier to <strong>read</strong>.</p>\n\n\n\t<p>If only it were so <strong>easy</strong> to use in every programming language.  In Rails,\nwith the help of <a href="http://google.com/search?q=acts_as_textiled">acts_as_textiled</a>,\nit&#8217;s way easy.  Thanks in no small part to <span style="color:red;">RedCloth</span>, of course.</p>]
    body_textile = %[_Textile_ is useful because it makes text _slightly_ easier to *read*.\n\nIf only it were so *easy* to use in every programming language.  In Rails,\nwith the help of "acts_as_textiled":http://google.com/search?q=acts_as_textiled,\nit's way easy.  Thanks in no small part to %{color:red}RedCloth%, of course.\n]
    body_plain = %[Textile is useful because it makes text slightly easier to read.\n\n\n\tIf only it were so easy to use in every programming language.  In Rails,\nwith the help of acts_as_textiled,\nit's way easy.  Thanks in no small part to RedCloth, of course.]

    assert_equal body_html, story.body
    assert_equal body_textile, story.body_source
    assert_equal body_plain, story.body_plain
  end

  def test_character_conversions
    story = Story.find(4)

    body_html = "<p>Is Textile&#8482; the wave of the future?  What about acts_as_textiled&#169;?  It&#8217;s\ndoubtful.  Why does Textile&#8482; smell like <em>Python</em>?  Can we do anything to\nfix that?  No?  Well, I guess there are worse smells &#8211; like Ruby.  jk.</p>\n\n\n\t<p>But seriously, ice &gt; water and water &lt; rain.  But&#8230;nevermind.  1&#215;1?  1.</p>\n\n\n\t<p>&#8220;You&#8217;re a good kid,&#8221; he said.  &#8220;Keep it up.&#8221;</p>"
    body_plain = %[Is Textile(TM) the wave of the future?  What about acts_as_textiled(C)?  It's\ndoubtful.  Why does Textile(TM) smell like Python?  Can we do anything to\nfix that?  No?  Well, I guess there are worse smells-like Ruby.  jk.\n\n\n\tBut seriously, ice > water and water < rain.  But...nevermind.  1x1?  1.\n\n\n\t"You're a good kid," he said.  "Keep it up."]

    assert_equal body_html, story.body
    assert_equal body_plain, story.body_plain
  end

  def test_textilize
    story = Story.find(1)
    desc_html = '_why announces <i>Sandbox</i>'

    assert_equal 0, story.textiled.size

    story.textilize

    assert_equal 2, story.textiled.size
    assert_equal desc_html, story.description
  end

  def test_textilize_after_find
    Story.send(:define_method, :after_find, proc { textilize })
    story = Story.find(2)
    desc_html = '<i>Beautify</i> your <strong>IRb</strong> prompt'

    assert_equal 2, story.textiled.size
    assert_equal desc_html, story.description
  end
end
