require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"

class HTML < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
end
