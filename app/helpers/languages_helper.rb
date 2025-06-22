module LanguagesHelper
  def proficiency_options
    options = Language.proficiencies.map do |key, value|
      [ key.humanize, key ]
    end

    options.unshift([ "Please select", nil ])
  end
end
