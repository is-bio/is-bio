# == Schema Information
#
# Table name: categories
#
#  id       :integer          not null, primary key
#  ancestry :string           not null
#  name     :string           not null
#
# Indexes
#
#  index_categories_on_ancestry  (ancestry)
#
require "rails_helper"

RSpec.describe Category, type: :model do
  describe "#path_name" do
    context "when name is capitalized" do
      let!(:category) { create(:category, name: "Ruby-On-Rails") }

      it { expect(category.path_name).to eq("ruby-on-rails") }
    end
  end

  # pending "add some examples to (or delete) #{__FILE__}"
end
