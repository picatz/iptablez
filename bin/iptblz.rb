$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
#!/usr/bin/env ruby

require 'iptablez'
require 'colorize'
require 'pry'

include Iptablez

prompt_name = "🦑  #{"~".blue} "

Pry.config.prompt = [
  proc { |target_self, nest_level, pry|
    "#{prompt_name}(#{Pry.view_clip(target_self)})#{":#{nest_level}" unless nest_level.zero?}> "
  },
  proc { |target_self, nest_level, pry|
    "#{prompt_name}(#{Pry.view_clip(target_self)})#{":#{nest_level}" unless nest_level.zero?}* "
  }
]
Pry.config.prompt_name = prompt_name
Pry.start
