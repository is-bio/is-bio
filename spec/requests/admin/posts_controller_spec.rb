require 'rails_helper'

RSpec.describe Admin::PostsController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let(:category) { create(:category) }
  let(:post_item) { create(:post, category: category) }

  before do
    allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
  end

  describe 'GET /admin/posts/new' do
    it 'returns http success' do
      get new_admin_post_path
      expect(response).to have_http_status(:success)
    end

    it 'initializes a new post' do
      get new_admin_post_path
      expect(assigns(:post)).to be_a_new(Post)
    end

    it 'sets the category options' do
      get new_admin_post_path
      expect(assigns(:category_options)).not_to be_empty
    end
  end

  describe 'POST /admin/posts' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          post: {
            title: 'Test Post Title',
            content: 'Test post content',
            category_id: category.id,
            published_at: Time.current,
            permalink: 'test-post'
          }
        }
      end

      it 'creates a new post' do
        expect {
          post admin_posts_path, params: valid_params
        }.to change(Post, :count).by(1)
      end

      it 'redirects to the post path' do
        post admin_posts_path, params: valid_params
        expect(response).to redirect_to(Post.last.path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          post: {
            category_id: nil
          }
        }
      end

      it 'does not create a new post' do
        expect {
          post admin_posts_path, params: invalid_params
        }.not_to change(Post, :count)
      end

      it 'returns unprocessable entity status' do
        post admin_posts_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /admin/posts/:id/edit' do
    it 'returns http success' do
      get edit_admin_post_path(post_item)
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested post' do
      get edit_admin_post_path(post_item)
      expect(assigns(:post)).to eq(post_item)
    end

    it 'sets the category options' do
      get edit_admin_post_path(post_item)
      expect(assigns(:category_options)).not_to be_empty
    end
  end

  describe 'PATCH /admin/posts/:id' do
    let(:post_item) { create(:post, category: category, title: 'Original Title') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          post: {
            title: 'Updated Title',
            content: 'Updated content',
            category_id: category.id
          }
        }
      end

      before do
        allow_any_instance_of(Admin::PostsController).to receive(:params).and_return(
          ActionController::Parameters.new(id: post_item.id.to_s).permit!
        )
        allow_any_instance_of(Admin::PostsController).to receive(:post_params).and_return(
          ActionController::Parameters.new(valid_params[:post]).permit!
        )
      end

      it 'updates the post' do
        patch admin_post_path(post_item), params: valid_params
        post_item.reload
        expect(post_item.title).to eq('Updated Title')
      end

      it 'redirects to the post path' do
        patch admin_post_path(post_item), params: valid_params
        expect(response).to redirect_to(post_item.path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          post: {
            category_id: nil
          }
        }
      end

      before do
        allow_any_instance_of(Admin::PostsController).to receive(:params).and_return(
          ActionController::Parameters.new(id: post_item.id.to_s).permit!
        )
        allow_any_instance_of(Admin::PostsController).to receive(:post_params).and_return(
          ActionController::Parameters.new(invalid_params[:post]).permit!
        )
      end

      it 'does not update the post' do
        original_title = post_item.title
        patch admin_post_path(post_item), params: invalid_params
        post_item.reload
        expect(post_item.title).to eq(original_title)
      end

      it 'returns unprocessable entity status' do
        patch admin_post_path(post_item), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /admin/posts/:id' do
    let!(:post_to_delete) { create(:post, category: category) }

    before do
      allow_any_instance_of(Admin::PostsController).to receive(:params).and_return(
        ActionController::Parameters.new(id: post_to_delete.id.to_s).permit!
      )
    end

    it 'destroys the post' do
      expect {
        delete admin_post_path(post_to_delete)
      }.to change(Post, :count).by(-1)
    end

    it 'redirects to the root path' do
      delete admin_post_path(post_to_delete)
      expect(response).to redirect_to(root_path)
      expect(response).to have_http_status(:see_other)
    end
  end

  context 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(nil)
    end

    it 'redirects to login page when trying to access new post form' do
      get new_admin_post_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to create a post' do
      post admin_posts_path, params: { post: { title: 'Test' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to edit a post' do
      get edit_admin_post_path(post_item)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
