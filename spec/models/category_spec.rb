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

  describe ".find_by_name" do

    context "when category exists under published root" do
      let!(:subcategory) { create(:category, name: "Technology", parent: Category.published_root) }
      let!(:sub_subcategory) { create(:category, name: "Programming", parent: subcategory) }

      it "returns the category with matching path_name" do
        expect(Category.find_by_name("technology")).to eq(subcategory)
        expect(Category.find_by_name("programming")).to eq(sub_subcategory)
      end

      it "handles case sensitivity" do
        expect(Category.find_by_name("TECHNOLOGY")).to be_nil
        expect(Category.find_by_name("Programming")).to be_nil
      end
    end

    context "when category does not exist under published root" do
      let!(:draft_category) { create(:category, name: "Draft-Category", parent: Category.drafts_root) }

      it "returns nil" do
        expect(Category.find_by_name("nonexistent")).to be_nil
        expect(Category.find_by_name("draft-category")).to be_nil
      end
    end
  end

  describe ".find_by_name_from_drafts" do
    context "when category exists under drafts root" do
      let!(:draft_subcategory) { create(:category, name: "Draft-Tech", parent: Category.drafts_root) }
      let!(:draft_sub_subcategory) { create(:category, name: "Draft-Programming", parent: draft_subcategory) }

      it "returns the category with matching path_name" do
        expect(Category.find_by_name_from_drafts("draft-tech")).to eq(draft_subcategory)
        expect(Category.find_by_name_from_drafts("draft-programming")).to eq(draft_sub_subcategory)
      end

      it "handles case insensitivity" do
        expect(Category.find_by_name_from_drafts("DRAFT-TECH")).to be_nil
        expect(Category.find_by_name_from_drafts("Draft-Programming")).to be_nil
      end
    end

    context "when category does not exist under drafts root" do
      let!(:published_category) { create(:category, name: "Published-Category", parent: Category.published_root) }

      it "returns nil" do
        expect(Category.find_by_name_from_drafts("nonexistent")).to be_nil
        expect(Category.find_by_name_from_drafts("published-category")).to be_nil
      end
    end
  end
end
