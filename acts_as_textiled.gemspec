$LOAD_PATH.unshift 'lib'

Gem::Specification.new do |s|
  s.name              = "acts_as_textiled"
  s.version           = "0.3.1"
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Render Textile"
  s.homepage          = "http://github.com/analog-analytics/acts_as_textiled"
  s.email             = "engineering@analoganalytics.com"
  s.authors           = [ "Chris Wanstrath" ]
  s.has_rdoc          = false

  s.files             = %w( README Rakefile )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("man/**/*")
  s.files            += Dir.glob("test/**/*")

  s.description       = <<desc
  This simple plugin allows you to forget about constantly rendering Textile in 
  your application.  Instead, you can rest easy knowing the Textile fields you 
  want to display as HTML will always be displayed as HTML (unless you tell your
  code otherwise).
desc
end
