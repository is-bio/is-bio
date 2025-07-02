require 'rails_helper'

RSpec.describe Admin::TechnicalSkillsController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let!(:technical_skill) { create(:technical_skill) }

  describe 'when authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
    end

    describe 'GET /admin/technical_skills' do
      it 'returns http success' do
        get admin_technical_skills_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns @technical_skills with all technical skills' do
        get admin_technical_skills_path
        expect(assigns(:technical_skills)).to include(technical_skill)
      end

      it 'renders the index template' do
        get admin_technical_skills_path
        expect(response).to render_template(:index)
      end
    end

    describe 'GET /admin/technical_skills/new' do
      it 'returns http success' do
        get new_admin_technical_skill_path
        expect(response).to have_http_status(:success)
      end

      it 'initializes a new technical skill' do
        get new_admin_technical_skill_path
        expect(assigns(:technical_skill)).to be_a_new(TechnicalSkill)
      end

      it 'renders the new template' do
        get new_admin_technical_skill_path
        expect(response).to render_template(:new)
      end
    end

    describe 'GET /admin/technical_skills/:id/edit' do
      it 'returns http success' do
        get edit_admin_technical_skill_path(technical_skill)
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested technical skill to @technical_skill' do
        get edit_admin_technical_skill_path(technical_skill)
        expect(assigns(:technical_skill)).to eq(technical_skill)
      end

      it 'renders the edit template' do
        get edit_admin_technical_skill_path(technical_skill)
        expect(response).to render_template(:edit)
      end
    end

    describe 'POST /admin/technical_skills' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            technical_skill: {
              name: 'Ruby on Rails'
            }
          }
        end

        it 'creates a new technical skill' do
          expect {
            post admin_technical_skills_path, params: valid_params
          }.to change(TechnicalSkill, :count).by(1)
        end

        it 'redirects to the technical skills index' do
          post admin_technical_skills_path, params: valid_params
          expect(response).to redirect_to(admin_technical_skills_path)
        end

        it 'sets a success flash message' do
          post admin_technical_skills_path, params: valid_params
          expect(flash[:notice]).to eq('Technical skill was successfully created.')
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            technical_skill: {
              name: ''
            }
          }
        end

        it 'does not create a new technical skill' do
          expect {
            post admin_technical_skills_path, params: invalid_params
          }.not_to change(TechnicalSkill, :count)
        end

        it 'returns unprocessable entity status' do
          post admin_technical_skills_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders the new template' do
          post admin_technical_skills_path, params: invalid_params
          expect(response).to render_template(:new)
        end
      end
    end

    describe 'PATCH /admin/technical_skills/:id' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            technical_skill: {
              name: 'Updated Technical Skill'
            }
          }
        end

        it 'updates the technical skill' do
          patch admin_technical_skill_path(technical_skill), params: valid_params
          technical_skill.reload
          expect(technical_skill.name).to eq('Updated Technical Skill')
        end

        it 'redirects to the technical skills index' do
          patch admin_technical_skill_path(technical_skill), params: valid_params
          expect(response).to redirect_to(admin_technical_skills_path)
        end

        it 'sets a success flash message' do
          patch admin_technical_skill_path(technical_skill), params: valid_params
          expect(flash[:notice]).to eq('Technical skill was successfully updated.')
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            technical_skill: {
              name: ''
            }
          }
        end

        it 'does not update the technical skill' do
          original_name = technical_skill.name
          patch admin_technical_skill_path(technical_skill), params: invalid_params
          technical_skill.reload
          expect(technical_skill.name).to eq(original_name)
        end

        it 'returns unprocessable entity status' do
          patch admin_technical_skill_path(technical_skill), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders the edit template' do
          patch admin_technical_skill_path(technical_skill), params: invalid_params
          expect(response).to render_template(:edit)
        end
      end
    end

    describe 'DELETE /admin/technical_skills/:id' do
      let!(:technical_skill_to_delete) { create(:technical_skill) }

      it 'destroys the technical skill' do
        expect {
          delete admin_technical_skill_path(technical_skill_to_delete)
        }.to change(TechnicalSkill, :count).by(-1)
      end

      it 'redirects to the technical skills index' do
        delete admin_technical_skill_path(technical_skill_to_delete)
        expect(response).to redirect_to(admin_technical_skills_path)
      end

      it 'returns see other status' do
        delete admin_technical_skill_path(technical_skill_to_delete)
        expect(response).to have_http_status(:see_other)
      end

      it 'sets a success flash message' do
        delete admin_technical_skill_path(technical_skill_to_delete)
        expect(flash[:notice]).to eq('Technical skill was successfully destroyed.')
      end
    end
  end

  describe 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(nil)
    end

    it 'redirects to login page when trying to access technical skills index' do
      get admin_technical_skills_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to access new technical skill' do
      get new_admin_technical_skill_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to edit a technical skill' do
      get edit_admin_technical_skill_path(technical_skill)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to create a technical skill' do
      post admin_technical_skills_path, params: { technical_skill: { name: 'Test' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to update a technical skill' do
      patch admin_technical_skill_path(technical_skill), params: { technical_skill: { name: 'Updated' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to delete a technical skill' do
      delete admin_technical_skill_path(technical_skill)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
