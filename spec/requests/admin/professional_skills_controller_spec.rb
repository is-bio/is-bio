require 'rails_helper'

RSpec.describe Admin::ProfessionalSkillsController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let!(:professional_skill) { create(:professional_skill) }

  describe 'when authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
    end

    describe 'GET /admin/professional_skills' do
      it 'returns http success' do
        get admin_professional_skills_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns @professional_skills with all professional skills' do
        get admin_professional_skills_path
        expect(assigns(:professional_skills)).to include(professional_skill)
      end

      it 'renders the index template' do
        get admin_professional_skills_path
        expect(response).to render_template(:index)
      end
    end

    describe 'GET /admin/professional_skills/new' do
      it 'returns http success' do
        get new_admin_professional_skill_path
        expect(response).to have_http_status(:success)
      end

      it 'initializes a new professional skill' do
        get new_admin_professional_skill_path
        expect(assigns(:professional_skill)).to be_a_new(ProfessionalSkill)
      end

      it 'renders the new template' do
        get new_admin_professional_skill_path
        expect(response).to render_template(:new)
      end
    end

    describe 'GET /admin/professional_skills/:id/edit' do
      it 'returns http success' do
        get edit_admin_professional_skill_path(professional_skill)
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested professional skill to @professional_skill' do
        get edit_admin_professional_skill_path(professional_skill)
        expect(assigns(:professional_skill)).to eq(professional_skill)
      end

      it 'renders the edit template' do
        get edit_admin_professional_skill_path(professional_skill)
        expect(response).to render_template(:edit)
      end
    end

    describe 'POST /admin/professional_skills' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            professional_skill: {
              name: 'Project Management'
            }
          }
        end

        it 'creates a new professional skill' do
          expect {
            post admin_professional_skills_path, params: valid_params
          }.to change(ProfessionalSkill, :count).by(1)
        end

        it 'redirects to the professional skills index' do
          post admin_professional_skills_path, params: valid_params
          expect(response).to redirect_to(admin_professional_skills_path)
        end

        it 'sets a success flash message' do
          post admin_professional_skills_path, params: valid_params
          expect(flash[:notice]).to eq('Professional skill was successfully created.')
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            professional_skill: {
              name: ''
            }
          }
        end

        it 'does not create a new professional skill' do
          expect {
            post admin_professional_skills_path, params: invalid_params
          }.not_to change(ProfessionalSkill, :count)
        end

        it 'returns unprocessable entity status' do
          post admin_professional_skills_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders the new template' do
          post admin_professional_skills_path, params: invalid_params
          expect(response).to render_template(:new)
        end
      end
    end

    describe 'PATCH /admin/professional_skills/:id' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            professional_skill: {
              name: 'Updated Professional Skill'
            }
          }
        end

        it 'updates the professional skill' do
          patch admin_professional_skill_path(professional_skill), params: valid_params
          professional_skill.reload
          expect(professional_skill.name).to eq('Updated Professional Skill')
        end

        it 'redirects to the professional skills index' do
          patch admin_professional_skill_path(professional_skill), params: valid_params
          expect(response).to redirect_to(admin_professional_skills_path)
        end

        it 'sets a success flash message' do
          patch admin_professional_skill_path(professional_skill), params: valid_params
          expect(flash[:notice]).to eq('Professional skill was successfully updated.')
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            professional_skill: {
              name: ''
            }
          }
        end

        it 'does not update the professional skill' do
          original_name = professional_skill.name
          patch admin_professional_skill_path(professional_skill), params: invalid_params
          professional_skill.reload
          expect(professional_skill.name).to eq(original_name)
        end

        it 'returns unprocessable entity status' do
          patch admin_professional_skill_path(professional_skill), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders the edit template' do
          patch admin_professional_skill_path(professional_skill), params: invalid_params
          expect(response).to render_template(:edit)
        end
      end
    end

    describe 'DELETE /admin/professional_skills/:id' do
      let!(:professional_skill_to_delete) { create(:professional_skill) }

      it 'destroys the professional skill' do
        expect {
          delete admin_professional_skill_path(professional_skill_to_delete)
        }.to change(ProfessionalSkill, :count).by(-1)
      end

      it 'redirects to the professional skills index' do
        delete admin_professional_skill_path(professional_skill_to_delete)
        expect(response).to redirect_to(admin_professional_skills_path)
      end

      it 'returns see other status' do
        delete admin_professional_skill_path(professional_skill_to_delete)
        expect(response).to have_http_status(:see_other)
      end

      it 'sets a success flash message' do
        delete admin_professional_skill_path(professional_skill_to_delete)
        expect(flash[:notice]).to eq('Professional skill was successfully destroyed.')
      end
    end
  end

  describe 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
    end

    it 'redirects to login for index' do
      get admin_professional_skills_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for new' do
      get new_admin_professional_skill_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for edit' do
      get edit_admin_professional_skill_path(professional_skill)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for create' do
      post admin_professional_skills_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for update' do
      patch admin_professional_skill_path(professional_skill)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for destroy' do
      delete admin_professional_skill_path(professional_skill)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
