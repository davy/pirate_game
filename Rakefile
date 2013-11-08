# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :minitest
Hoe.plugin :git

Hoe.spec 'pirate_game' do
  developer 'Davy Stevenson', 'davy.stevenson@gmail.com'
  developer 'Eric Hodel', 'drbrain@segment7.net'

  rdoc_locations << 'docs.seattlerb.org:/data/www/docs.seattlerb.org/pirate_game/'

  extra_deps << ['json', '~> 1.8.0']
  extra_deps << ['pirate_command', '~> 0.0', '>= 0.0.2']
  extra_deps << ['shuttlecraft', '~> 0.0']

  license 'MIT'

  self.readme_file = 'README.md'
end

# vim: syntax=ruby
