require "rails_helper"

RSpec.describe RemoveEmptyDirectoriesJob, type: :job do
  describe "#perform" do
    context "when there are empty directories" do
      let!(:empty_category) { create(:category, name: "Empty Category") }
      let!(:category_with_children) { create(:category, name: "Parent Category") }
      let!(:child_category) { create(:category, name: "Child Category", parent: category_with_children) }
      let!(:category_with_posts) { create(:category, name: "Category With Posts") }
      let!(:post) { create(:post, category: category_with_posts) }

      it "deletes directories without children and posts" do
        expect {
          described_class.perform_now
        }.to change { Category.count }.by(-2)

        expect(Category.find_by(name: "Empty Category")).to be_nil
        expect(Category.find_by(name: "Parent Category")).to be_present
        expect(Category.find_by(name: "Child Category")).to be_nil
        expect(Category.find_by(name: "Category With Posts")).to be_present
      end
    end

    context "when there are no empty directories" do
      let!(:category_with_children) { create(:category, name: "Parent Category") }
      let!(:child_category) { create(:category, name: "Child Category", parent: category_with_children) }
      let!(:post_first) { create(:post, category: child_category) }
      let!(:category_with_posts) { create(:category, name: "Category With Posts") }
      let!(:post_second) { create(:post, category: category_with_posts) }

      it "does not delete any directories" do
        expect {
          described_class.perform_now
        }.not_to change { Category.count }
      end
    end

    context "when root directories have no children" do
      it "does not delete root directories" do
        expect {
          described_class.perform_now
        }.not_to change { Category.count }

        expect(Category.find(Category::ID_PUBLISHED)).to be_present
        expect(Category.find(Category::ID_DRAFTS)).to be_present
      end
    end
  end
end
