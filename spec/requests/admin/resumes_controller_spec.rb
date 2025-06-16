require 'rails_helper'

RSpec.describe Admin::ResumesController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let(:resume) { create(:resume) }

  before do
    allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
  end

  describe 'GET /admin/resumes' do
    it 'returns http success' do
      get admin_resumes_path
      expect(response).to have_http_status(:success)
    end

    it 'assigns @resumes with all resumes' do
      resume1 = create(:resume)
      resume2 = create(:resume)

      get admin_resumes_path

      expect(assigns(:resumes)).to include(resume1, resume2)
    end

    it 'renders the index template' do
      get admin_resumes_path
      expect(response).to render_template(:index)
    end
  end

  describe 'GET /admin/resumes/new' do
    it 'returns http success' do
      get new_admin_resume_path
      expect(response).to have_http_status(:success)
    end

    it 'initializes a new resume' do
      get new_admin_resume_path
      expect(assigns(:resume)).to be_a_new(Resume)
    end
  end

  describe 'POST /admin/resumes' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          resume: {
            title: 'Developer Resume',
            name: 'Jane Smith',
            email_address: 'jane@example.com',
            phone_number: '+1 (555) 987-6543',
            position: 'Python Web Developer',
            city: 'Los Angeles, United States',
            summary: 'I am a full-stack web developer'
            # birth_date: '1985-03-15',
            # height: 175.5,
            # weight: 68.2
          }
        }
      end

      it 'creates a new resume' do
        expect {
          post admin_resumes_path, params: valid_params
        }.to change(Resume, :count).by(1)
      end

      it 'redirects to the resumes index with a notice' do
        post admin_resumes_path, params: valid_params
        expect(response).to redirect_to(admin_resumes_path)
        expect(flash[:notice]).to eq("Resume was successfully created.")
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          resume: {
            title: '',
            name: '',
            email_address: 'invalid-email'
          }
        }
      end

      it 'does not create a new resume' do
        expect {
          post admin_resumes_path, params: invalid_params
        }.not_to change(Resume, :count)
      end

      it 'returns unprocessable entity status' do
        post admin_resumes_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders the new template' do
        post admin_resumes_path, params: invalid_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET /admin/resumes/:id/edit' do
    it 'returns http success' do
      get edit_admin_resume_path(resume)
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested resume as @resume' do
      get edit_admin_resume_path(resume)
      expect(assigns(:resume)).to eq(resume)
    end
  end

  describe 'PATCH /admin/resumes/:id' do
    let(:resume) { create(:resume, title: 'Original Title') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          resume: {
            title: 'Updated Title',
            name: 'Updated Name',
            email_address: 'updated@example.com'
          }
        }
      end

      before do
        allow_any_instance_of(Admin::ResumesController).to receive(:params).and_return(
          ActionController::Parameters.new(id: resume.id.to_s).permit!
        )
        allow_any_instance_of(Admin::ResumesController).to receive(:resume_params).and_return(
          ActionController::Parameters.new(valid_params[:resume]).permit!
        )
      end

      it 'updates the resume' do
        patch admin_resume_path(resume), params: valid_params
        resume.reload
        expect(resume.title).to eq('Updated Title')
        expect(resume.name).to eq('Updated Name')
        expect(resume.email_address).to eq('updated@example.com')
      end

      it 'redirects to the resumes index with a notice' do
        patch admin_resume_path(resume), params: valid_params
        expect(response).to redirect_to(admin_resumes_path)
        expect(flash[:notice]).to eq("Resume was successfully updated.")
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          resume: {
            title: '',
            email_address: 'invalid'
          }
        }
      end

      before do
        allow_any_instance_of(Admin::ResumesController).to receive(:params).and_return(
          ActionController::Parameters.new(id: resume.id.to_s).permit!
        )
        allow_any_instance_of(Admin::ResumesController).to receive(:resume_params).and_return(
          ActionController::Parameters.new(invalid_params[:resume]).permit!
        )
      end

      it 'does not update the resume' do
        original_title = resume.title
        patch admin_resume_path(resume), params: invalid_params
        resume.reload
        expect(resume.title).to eq(original_title)
      end

      it 'returns unprocessable entity status' do
        patch admin_resume_path(resume), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders the edit template' do
        patch admin_resume_path(resume), params: invalid_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE /admin/resumes/:id' do
    let!(:resume_to_delete) { create(:resume) }

    before do
      allow_any_instance_of(Admin::ResumesController).to receive(:params).and_return(
        ActionController::Parameters.new(id: resume_to_delete.id.to_s).permit!
      )
    end

    it 'destroys the resume' do
      expect {
        delete admin_resume_path(resume_to_delete)
      }.to change(Resume, :count).by(-1)
    end

    it 'redirects to the resumes index with a notice' do
      delete admin_resume_path(resume_to_delete)
      expect(response).to redirect_to(admin_resumes_path)
      expect(flash[:notice]).to eq("Resume was successfully deleted.")
    end
  end

  context 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(nil)
    end

    it 'redirects to login page when trying to access resumes index' do
      get admin_resumes_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to access new resume form' do
      get new_admin_resume_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to create a resume' do
      post admin_resumes_path, params: { resume: { title: 'Test' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to edit a resume' do
      get edit_admin_resume_path(resume)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
