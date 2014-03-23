#encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "cic_payment"
  s.version     = "0.4.2"
  s.date        = "2014-03-18"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Novelys Team", 'Guillaume Barillot', 'Regis Millet (aka Kulgar)']
  s.email       = "kulgar@ct2c.fr"
  s.homepage    = "https://github.com/Kulgar/cic_payment"
  s.summary     = %q{CIC / Credit Mutuel credit card payment toolbox}
  s.description = %q{CIC Payment is a gem to ease credit card payment with the CIC / Credit Mutuel banks system. It's a Ruby on Rails port of the connexion kits published by the bank.}
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
