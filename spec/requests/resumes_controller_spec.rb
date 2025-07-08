require 'rails_helper'

RSpec.describe ResumesController, type: :request do
  let!(:user) { create(:user) }
  let!(:session) { create(:session, user: user) }
  let!(:resume) { Resume.first || create(:resume) }
  let!(:social_media_account1) {
    SocialMediaAccount.delete_by(key: "website_url")
    create(:social_media_account, key: "website_url", value: "https://example-site.com")
  }
  let!(:social_media_account2) { create(:social_media_account, value: nil) }
  let!(:technical_skill1) { create(:technical_skill) }
  let!(:technical_skill2) { create(:technical_skill) }
  let!(:professional_skill1) { create(:professional_skill) }
  let!(:professional_skill2) { create(:professional_skill) }
  let!(:interest1) { create(:interest) }
  let!(:interest2) { create(:interest) }
  let!(:language1) { create(:language) }
  let!(:language2) { create(:language) }
  let!(:education1) { create(:education, start_year: 2016, end_year: 2020) }
  let!(:education2) { create(:education, start_year: 2020, end_year: 2023) }
  let!(:experience1) { create(:experience, start_year: 2019, start_month: 6) }
  let!(:experience2) { create(:experience, start_year: 2020, start_month: 3) }
  let!(:project1) { create(:project) }
  let!(:project2) { create(:project) }

  describe 'GET /resume' do
    context 'when user is not authenticated' do
      before do
        allow_any_instance_of(ResumesController).to receive(:authenticated?).and_return(false)
      end

      it 'returns http success' do
        get resume_path
        expect(response).to have_http_status(:success)
      end

      it 'renders the show template' do
        get resume_path
        expect(response).to render_template(:show)
      end

      it 'uses resume layout' do
        get resume_path
        expect(response).to render_template(layout: 'resume')
      end

      it 'assigns @resume with existing resume' do
        get resume_path
        expect(assigns(:resume)).to eq(resume)
      end

      it 'assigns @can_edit as false' do
        get resume_path
        expect(assigns(:can_edit)).to be false
      end

      it 'assigns all required instance variables' do
        get resume_path

        expect(assigns(:social_media_accounts)).to include(social_media_account1)
        expect(assigns(:social_media_accounts)).not_to include(social_media_account2)

        expect(assigns(:technical_skills)).to include(technical_skill1, technical_skill2)
        expect(assigns(:professional_skills)).to include(professional_skill1, professional_skill2)
        expect(assigns(:interests)).to include(interest1, interest2)
        expect(assigns(:languages)).to include(language1, language2)
        expect(assigns(:educations)).to eq([education2, education1])
        expect(assigns(:experiences)).to eq([experience2, experience1])
        expect(assigns(:projects)).to include(project1, project2)
      end

      context 'when no resume exists' do
        before do
          Resume.destroy_all
        end

        it 'initializes a new resume' do
          get resume_path
          expect(assigns(:resume)).to be_a_new(Resume)
        end

        it 'does not redirect' do
          get resume_path
          expect(response).to have_http_status(:success)
          expect(response).not_to be_redirect
        end
      end
    end

    context 'when user is authenticated' do
      before do
        allow_any_instance_of(ResumesController).to receive(:authenticated?).and_return(true)
        allow_any_instance_of(ResumesController).to receive(:resume_session).and_return(session)
      end

      it 'returns http success' do
        get resume_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns @can_edit as true by default' do
        get resume_path
        expect(assigns(:can_edit)).to be true
      end

      context 'when view=visitor parameter is present' do
        it 'assigns @can_edit as false' do
          get resume_path, params: { view: 'visitor' }
          expect(assigns(:can_edit)).to be false
        end
      end

      context 'when no resume exists' do
        before do
          Resume.destroy_all
        end

        it 'redirects to admin resumes path' do
          get resume_path
          expect(response).to redirect_to(admin_resumes_path)
        end
      end
    end
  end
end
