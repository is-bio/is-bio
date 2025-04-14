require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let!(:published_category) { Category.find_by(id: Category::ID_PUBLISHED) || create(:category, id: Category::ID_PUBLISHED, name: 'Published') }
  let!(:drafts_category) { Category.find_by(id: Category::ID_DRAFTS) || create(:category, id: Category::ID_DRAFTS, name: 'Drafts') }
  let!(:subcategory1) { create(:category, parent: published_category, name: 'Subcategory1') }
  let!(:subcategory2) { create(:category, parent: drafts_category, name: 'Subcategory2') }

  before do
    allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
  end

  describe 'GET /admin/categories' do
    it 'returns http success' do
      get admin_categories_path
      expect(response).to have_http_status(:success)
    end

    it 'assigns @categories with all categories' do
      get admin_categories_path
      expect(assigns(:categories)).to include(published_category, drafts_category, subcategory1, subcategory2)
    end

    it 'includes posts data with categories' do
      post1 = create(:post, category: subcategory1)
      post2 = create(:post, category: subcategory2)

      get admin_categories_path

      # Verify that the posts are eager loaded with the categories
      expect(assigns(:categories).detect { |c| c.id == subcategory1.id }.posts).to include(post1)
      expect(assigns(:categories).detect { |c| c.id == subcategory2.id }.posts).to include(post2)
    end

    it 'renders the index template' do
      get admin_categories_path
      expect(response).to render_template(:index)
    end
  end

  context 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(nil)
    end

    it 'redirects to login page when trying to access categories index' do
      get admin_categories_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
