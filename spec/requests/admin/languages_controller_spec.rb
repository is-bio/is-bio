require 'rails_helper'

RSpec.describe Admin::LanguagesController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let!(:resume) { create(:resume) }
  let!(:language) { create(:language, resume: resume) }

  describe 'when authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
      allow(Resume).to receive(:first!).and_return(resume)
    end

    describe 'GET /admin/languages' do
      it 'returns http success' do
        get admin_languages_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns @languages with all languages' do
        get admin_languages_path
        expect(assigns(:languages)).to include(language)
      end

      it 'renders the index template' do
        get admin_languages_path
        expect(response).to render_template(:index)
      end
    end

    describe 'GET /admin/languages/new' do
      it 'returns http success' do
        get new_admin_language_path
        expect(response).to have_http_status(:success)
      end

      it 'initializes a new language' do
        get new_admin_language_path
        expect(assigns(:language)).to be_a_new(Language)
      end

      it 'renders the new template' do
        get new_admin_language_path
        expect(response).to render_template(:new)
      end
    end

    describe 'GET /admin/languages/:id/edit' do
      it 'returns http success' do
        get edit_admin_language_path(language)
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested language to @language' do
        get edit_admin_language_path(language)
        expect(assigns(:language)).to eq(language)
      end

      it 'renders the edit template' do
        get edit_admin_language_path(language)
        expect(response).to render_template(:edit)
      end

      # context 'when language does not exist' do
      #   it 'raises ActiveRecord::RecordNotFound' do
      #     expect {
      #       get edit_admin_language_path(id: 'nonexistent')
      #     }.to raise_error(ActiveRecord::RecordNotFound)
      #   end
      # end
    end

    describe 'POST /admin/languages' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            language: {
              name: 'French',
              proficiency: 'full_professional'
            }
          }
        end

        it 'creates a new language' do
          expect {
            post admin_languages_path, params: valid_params
          }.to change(Language, :count).by(1)
        end

        it 'associates the language with the first resume' do
          post admin_languages_path, params: valid_params
          created_language = Language.last
          expect(created_language.resume).to eq(resume)
        end

        it 'redirects to the languages index' do
          post admin_languages_path, params: valid_params
          expect(response).to redirect_to(admin_languages_path)
        end

        it 'sets a success flash message' do
          post admin_languages_path, params: valid_params
          expect(flash[:notice]).to eq('Language was successfully created.')
        end

        it 'sets the correct proficiency' do
          post admin_languages_path, params: valid_params
          created_language = Language.last
          expect(created_language.proficiency).to eq('full_professional')
        end
      end

      context 'with valid parameters but no proficiency' do
        let(:valid_params) do
          {
            language: {
              name: 'German'
            }
          }
        end

        it 'creates a new language without proficiency' do
          expect {
            post admin_languages_path, params: valid_params
          }.to change(Language, :count).by(1)
        end

        it 'allows nil proficiency' do
          post admin_languages_path, params: valid_params
          created_language = Language.last
          expect(created_language.proficiency).to be_nil
        end
      end

      context 'with invalid parameters' do
        context 'when name is blank' do
          let(:invalid_params) do
            {
              language: {
                name: '',
                proficiency: 'professional_working'
              }
            }
          end

          it 'does not create a new language' do
            expect {
              post admin_languages_path, params: invalid_params
            }.not_to change(Language, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_languages_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the new template' do
            post admin_languages_path, params: invalid_params
            expect(response).to render_template(:new)
          end

          it 'assigns the language with errors' do
            post admin_languages_path, params: invalid_params
            expect(assigns(:language).errors[:name]).to include("can't be blank")
          end
        end

        context 'when name is not unique' do
          let(:invalid_params) do
            {
              language: {
                name: language.name,
                proficiency: 'elementary'
              }
            }
          end

          it 'does not create a new language' do
            expect {
              post admin_languages_path, params: invalid_params
            }.not_to change(Language, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_languages_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the new template' do
            post admin_languages_path, params: invalid_params
            expect(response).to render_template(:new)
          end

          it 'assigns the language with uniqueness errors' do
            post admin_languages_path, params: invalid_params
            expect(assigns(:language).errors[:name]).to include("has already been taken")
          end
        end

        context 'when proficiency is invalid' do
          let(:invalid_params) do
            {
              language: {
                name: 'Italian',
                proficiency: 'invalid_proficiency'
              }
            }
          end

          it 'raises ArgumentError for invalid proficiency enum value' do
            expect {
              post admin_languages_path, params: invalid_params
            }.to raise_error(ArgumentError, "'invalid_proficiency' is not a valid proficiency")
          end
        end
      end
    end

    describe 'PATCH /admin/languages/:id' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            language: {
              name: 'Updated Language',
              proficiency: 'native_or_bilingual'
            }
          }
        end

        it 'updates the language' do
          patch admin_language_path(language), params: valid_params
          language.reload
          expect(language.name).to eq('Updated Language')
          expect(language.proficiency).to eq('native_or_bilingual')
        end

        it 'redirects to the languages index' do
          patch admin_language_path(language), params: valid_params
          expect(response).to redirect_to(admin_languages_path)
        end

        it 'sets a success flash message' do
          patch admin_language_path(language), params: valid_params
          expect(flash[:notice]).to eq('Language was successfully updated.')
        end
      end

      context 'with valid parameters updating only proficiency' do
        let(:valid_params) do
          {
            language: {
              proficiency: 'limited_working'
            }
          }
        end

        it 'updates only the proficiency' do
          original_name = language.name
          patch admin_language_path(language), params: valid_params
          language.reload
          expect(language.name).to eq(original_name)
          expect(language.proficiency).to eq('limited_working')
        end
      end

      context 'with invalid parameters' do
        context 'when name is blank' do
          let(:invalid_params) do
            {
              language: {
                name: '',
                proficiency: 'elementary'
              }
            }
          end

          it 'does not update the language' do
            original_name = language.name
            original_proficiency = language.proficiency
            patch admin_language_path(language), params: invalid_params
            language.reload
            expect(language.name).to eq(original_name)
            expect(language.proficiency).to eq(original_proficiency)
          end

          it 'returns unprocessable entity status' do
            patch admin_language_path(language), params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the edit template' do
            patch admin_language_path(language), params: invalid_params
            expect(response).to render_template(:edit)
          end

          it 'assigns the language with errors' do
            patch admin_language_path(language), params: invalid_params
            expect(assigns(:language).errors[:name]).to include("can't be blank")
          end
        end

        context 'when name is not unique' do
          let!(:other_language) { create(:language, name: 'Other Language', resume: resume) }
          let(:invalid_params) do
            {
              language: {
                name: other_language.name,
                proficiency: 'professional_working'
              }
            }
          end

          it 'does not update the language' do
            original_name = language.name
            original_proficiency = language.proficiency
            patch admin_language_path(language), params: invalid_params
            language.reload
            expect(language.name).to eq(original_name)
            expect(language.proficiency).to eq(original_proficiency)
          end

          it 'returns unprocessable entity status' do
            patch admin_language_path(language), params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the edit template' do
            patch admin_language_path(language), params: invalid_params
            expect(response).to render_template(:edit)
          end

          it 'assigns the language with uniqueness errors' do
            patch admin_language_path(language), params: invalid_params
            expect(assigns(:language).errors[:name]).to include("has already been taken")
          end
        end

        context 'when proficiency is invalid' do
          let(:invalid_params) do
            {
              language: {
                name: language.name,
                proficiency: 'invalid_level'
              }
            }
          end

          it 'raises ArgumentError for invalid proficiency enum value' do
            expect {
              patch admin_language_path(language), params: invalid_params
            }.to raise_error(ArgumentError, "'invalid_level' is not a valid proficiency")
          end
        end
      end

      # context 'when language does not exist' do
      #   it 'raises ActiveRecord::RecordNotFound' do
      #     expect {
      #       patch admin_language_path(id: 'nonexistent'), params: { language: { name: 'Test' } }
      #     }.to raise_error(ActiveRecord::RecordNotFound)
      #   end
      # end
    end

    describe 'DELETE /admin/languages/:id' do
      it 'destroys the language' do
        expect {
          delete admin_language_path(language)
        }.to change(Language, :count).by(-1)
      end

      it 'redirects to the languages index' do
        delete admin_language_path(language)
        expect(response).to redirect_to(admin_languages_path)
      end

      it 'sets the correct redirect status' do
        delete admin_language_path(language)
        expect(response).to have_http_status(:see_other)
      end

      it 'sets a success flash message' do
        delete admin_language_path(language)
        expect(flash[:notice]).to eq('Language was successfully destroyed.')
      end

      # context 'when language does not exist' do
      #   it 'raises ActiveRecord::RecordNotFound' do
      #     expect {
      #       delete admin_language_path(id: 'nonexistent')
      #     }.to raise_error(ActiveRecord::RecordNotFound)
      #   end
      # end
    end
  end

  describe 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(nil)
    end

    it 'redirects to login page when trying to access languages index' do
      get admin_languages_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to access new language' do
      get new_admin_language_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to edit language' do
      get edit_admin_language_path(language)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to create language' do
      post admin_languages_path, params: { language: { name: 'Test' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to update language' do
      patch admin_language_path(language), params: { language: { name: 'Test' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to destroy language' do
      delete admin_language_path(language)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
