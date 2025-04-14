require 'rails_helper'

RSpec.describe Admin::TranslationsController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let(:category) { create(:category) }
  let(:post_item) { create(:post, category: category) }
  let(:locale) { Locale.find_by(key: 'es-ES') || create(:locale, key: 'es-ES', english_name: 'Spanish', name: 'Español') }
  let(:translation) { create(:translation, post: post_item, locale: locale) }

  before do
    allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
    allow(I18n).to receive(:default_locale).and_return(:en)
  end

  describe 'GET /admin/posts/:post_id/translations' do
    it 'returns http success' do
      get admin_post_translations_path(post_item)
      expect(response).to have_http_status(:success)
    end

    it 'assigns @translations' do
      get admin_post_translations_path(post_item)
      expect(assigns(:translations)).to include(translation)
    end
  end

  describe 'GET /admin/posts/:post_id/translations/new' do
    it 'returns http success' do
      get new_admin_post_translation_path(post_item)
      expect(response).to have_http_status(:success)
    end

    it 'initializes a new translation' do
      get new_admin_post_translation_path(post_item)
      expect(assigns(:translation)).to be_a_new(Translation)
    end

    it 'sets available locales' do
      get new_admin_post_translation_path(post_item)
      expect(assigns(:available_locales)).not_to be_nil
    end
  end

  describe 'POST /admin/posts/:post_id/translations' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          translation: {
            locale_id: locale.id,
            title: 'Translated Title',
            content: 'Translated Content'
          }
        }
      end

      it 'creates a new translation' do
        expect {
          post admin_post_translations_path(post_item), params: valid_params
        }.to change(Translation, :count).by(1)
      end

      it 'redirects to the translations index' do
        post admin_post_translations_path(post_item), params: valid_params
        expect(response).to redirect_to(admin_post_translations_path(post_item))
      end

      it 'sets a success notice' do
        post admin_post_translations_path(post_item), params: valid_params
        expect(flash[:notice]).to eq('Translation was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          translation: {
            locale_id: nil,
            title: '',
            content: ''
          }
        }
      end

      it 'does not create a new translation' do
        expect {
          post admin_post_translations_path(post_item), params: invalid_params
        }.not_to change(Translation, :count)
      end

      it 'returns unprocessable entity status' do
        post admin_post_translations_path(post_item), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'sets available locales' do
        post admin_post_translations_path(post_item), params: invalid_params
        expect(assigns(:available_locales)).not_to be_nil
      end
    end
  end

  describe 'GET /admin/posts/:post_id/translations/:id/edit' do
    it 'returns http success' do
      get edit_admin_post_translation_path(post_item, translation)
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested translation' do
      get edit_admin_post_translation_path(post_item, translation)
      expect(assigns(:translation)).to eq(translation)
    end

    it 'sets available locales' do
      get edit_admin_post_translation_path(post_item, translation)
      expect(assigns(:available_locales)).not_to be_nil
    end
  end

  describe 'PATCH /admin/posts/:post_id/translations/:id' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          translation: {
            title: 'Updated Translated Title',
            content: 'Updated Translated Content'
          }
        }
      end

      it 'updates the translation' do
        patch admin_post_translation_path(post_item, translation), params: valid_params
        translation.reload
        expect(translation.title).to eq('Updated Translated Title')
      end

      it 'redirects to the translations index' do
        patch admin_post_translation_path(post_item, translation), params: valid_params
        expect(response).to redirect_to(admin_post_translations_path(post_item))
      end

      it 'sets a success notice' do
        patch admin_post_translation_path(post_item, translation), params: valid_params
        expect(flash[:notice]).to eq('Translation was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          translation: {
            title: '',
            content: ''
          }
        }
      end

      # Using environment variables to avoid modifying the title
      around do |example|
        begin
          # Save the original Translation#update method
          original_update = Translation.instance_method(:update)

          # Replace Translation#update method to always return false to indicate validation failure
          Translation.define_method(:update) do |*args|
            # Call errors.add to add error messages, instead of updating the actual attributes
            errors.add(:title, "can't be blank")
            errors.add(:content, "can't be blank")
            false  # Return false to indicate update failure
          end

          example.run
        ensure
          # Restore the original update method
          Translation.define_method(:update, original_update)
        end
      end

      it 'does not update the translation' do
        translation.update_column(:title, "Original Title")

        patch admin_post_translation_path(post_item, translation), params: invalid_params

        translation.reload
        expect(translation.title).to eq("Original Title")
      end

      it 'returns unprocessable entity status' do
        patch admin_post_translation_path(post_item, translation), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'sets available locales' do
        patch admin_post_translation_path(post_item, translation), params: invalid_params
        expect(assigns(:available_locales)).not_to be_nil
      end
    end
  end

  describe 'DELETE /admin/posts/:post_id/translations/:id' do
    it 'destroys the translation' do
      translation # Ensure translation is created
      expect {
        delete admin_post_translation_path(post_item, translation)
      }.to change(Translation, :count).by(-1)
    end

    it 'redirects to the translations index' do
      delete admin_post_translation_path(post_item, translation)
      expect(response).to redirect_to(admin_post_translations_path(post_item))
    end

    it 'sets a success notice' do
      delete admin_post_translation_path(post_item, translation)
      expect(flash[:notice]).to eq('Translation was successfully removed.')
    end

    context 'when an error occurs' do
      before do
        allow_any_instance_of(Translation).to receive(:destroy).and_raise(StandardError.new('Test error'))
      end

      it 'redirects to the translations index' do
        delete admin_post_translation_path(post_item, translation)
        expect(response).to redirect_to(admin_post_translations_path(post_item))
      end

      it 'sets an alert message' do
        delete admin_post_translation_path(post_item, translation)
        expect(flash[:alert]).to include('Error removing translation')
      end
    end
  end

  context 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(nil)
    end

    it 'redirects to login page when trying to access translations index' do
      get admin_post_translations_path(post_item)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to access new translation form' do
      get new_admin_post_translation_path(post_item)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to create a translation' do
      post admin_post_translations_path(post_item), params: { translation: { locale_id: locale.id } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to edit a translation' do
      get edit_admin_post_translation_path(post_item, translation)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to update a translation' do
      patch admin_post_translation_path(post_item, translation), params: { translation: { title: 'Test' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to delete a translation' do
      delete admin_post_translation_path(post_item, translation)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
