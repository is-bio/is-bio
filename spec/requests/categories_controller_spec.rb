require "rails_helper"

RSpec.describe CategoriesController, type: :request do
  let(:category) { create(:category, name: "Test-Category") }
  # rubocop:disable RSpec/LetSetup
  let!(:first_post) { create(:post, title: "First Post", category: category) }
  let!(:second_post) { create(:post, title: "Second Post", category: category) }
  # rubocop:enable RSpec/LetSetup

  describe "GET #show" do
    context "when category exists" do
      before do
        allow(Category).to receive(:find_by_name).with(category.path_name).and_return(category)
      end

      it "renders the show template" do
        get "/category/#{category.path_name}"
        expect(response).to render_template(:show)
        expect(response.body).to include(first_post.title)
        expect(response.body).to include(second_post.title)
        expect(response.body).to include(category.name.titleize)
      end

      it "displays all posts from the category" do
        get "/category/#{category.path_name}"
        expect(response.body).to include(first_post.path)
        expect(response.body).to include(second_post.path)
      end
    end

    context "when category does not exist" do
      before do
        allow(Category).to receive(:find_by_name).with("non-existent").and_return(nil)
      end

      it "raises a routing error (404)" do
        expect {
          get "/category/non-existent"
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe "GET #drafts_show" do
    context "when category exists in drafts" do
      before do
        allow(Category).to receive(:find_by_name_from_drafts).with(category.path_name).and_return(category)
      end

      it "renders the show template" do
        get "/drafts/#{category.path_name}"
        expect(response).to render_template(:show)
        expect(response.body).to include(first_post.title)
        expect(response.body).to include(second_post.title)
        expect(response.body).to include(first_post.path)
      end
    end

    context "when category does not exist in drafts" do
      before do
        allow(Category).to receive(:find_by_name_from_drafts).with("non-existent").and_return(nil)
      end

      it "raises a routing error (404)" do
        expect {
          get "/drafts/non-existent"
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
