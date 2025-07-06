require 'rails_helper'

RSpec.describe Admin::ExperiencesController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let!(:experience) { create(:experience) }

  describe 'when authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
    end

    describe 'GET /admin/experiences' do
      it 'returns http success' do
        get admin_experiences_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns @experiences with all experiences' do
        get admin_experiences_path
        expect(assigns(:experiences)).to include(experience)
      end

      it 'renders the index template' do
        get admin_experiences_path
        expect(response).to render_template(:index)
      end
    end

    describe 'GET /admin/experiences/new' do
      it 'returns http success' do
        get new_admin_experience_path
        expect(response).to have_http_status(:success)
      end

      it 'initializes a new experience' do
        get new_admin_experience_path
        expect(assigns(:experience)).to be_a_new(Experience)
      end

      it 'renders the new template' do
        get new_admin_experience_path
        expect(response).to render_template(:new)
      end
    end

    describe 'GET /admin/experiences/:id/edit' do
      it 'returns http success' do
        get edit_admin_experience_path(experience)
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested experience to @experience' do
        get edit_admin_experience_path(experience)
        expect(assigns(:experience)).to eq(experience)
      end

      it 'renders the edit template' do
        get edit_admin_experience_path(experience)
        expect(response).to render_template(:edit)
      end
    end

    describe 'POST /admin/experiences' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            experience: {
              company_name: 'Google Inc.',
              title: 'Software Engineer',
              description: 'Developed web applications using Ruby on Rails',
              start_year: 2020,
              start_month: 6,
              end_year: 2022,
              end_month: 12
            }
          }
        end

        it 'creates a new experience' do
          expect {
            post admin_experiences_path, params: valid_params
          }.to change(Experience, :count).by(1)
        end

        it 'redirects to the experiences index' do
          post admin_experiences_path, params: valid_params
          expect(response).to redirect_to(admin_experiences_path)
        end

        it 'sets a success flash message' do
          post admin_experiences_path, params: valid_params
          expect(flash[:notice]).to eq('Experience was successfully created.')
        end
      end

      context 'with invalid parameters' do
        context 'when company_name is blank' do
          let(:invalid_params) do
            {
              experience: {
                company_name: '',
                title: 'Software Engineer',
                description: 'Developed web applications',
                start_year: 2020
              }
            }
          end

          it 'does not create a new experience' do
            expect {
              post admin_experiences_path, params: invalid_params
            }.not_to change(Experience, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_experiences_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the new template' do
            post admin_experiences_path, params: invalid_params
            expect(response).to render_template(:new)
          end
        end

        context 'when title is blank' do
          let(:invalid_params) do
            {
              experience: {
                company_name: 'Google Inc.',
                title: '',
                description: 'Developed web applications',
                start_year: 2020
              }
            }
          end

          it 'does not create a new experience' do
            expect {
              post admin_experiences_path, params: invalid_params
            }.not_to change(Experience, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_experiences_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when description is blank' do
          let(:invalid_params) do
            {
              experience: {
                company_name: 'Google Inc.',
                title: 'Software Engineer',
                description: '',
                start_year: 2020
              }
            }
          end

          it 'does not create a new experience' do
            expect {
              post admin_experiences_path, params: invalid_params
            }.not_to change(Experience, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_experiences_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when start_year is blank' do
          let(:invalid_params) do
            {
              experience: {
                company_name: 'Google Inc.',
                title: 'Software Engineer',
                description: 'Developed web applications',
                start_year: nil
              }
            }
          end

          it 'does not create a new experience' do
            expect {
              post admin_experiences_path, params: invalid_params
            }.not_to change(Experience, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_experiences_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when start_year is before 1960' do
          let(:invalid_params) do
            {
              experience: {
                company_name: 'Test Company',
                title: 'Software Engineer',
                description: 'Developed applications',
                start_year: 1950
              }
            }
          end

          it 'does not create a new experience' do
            expect {
              post admin_experiences_path, params: invalid_params
            }.not_to change(Experience, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_experiences_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when start_year is after MAX_YEAR' do
          let(:invalid_params) do
            {
              experience: {
                company_name: 'Test Company',
                title: 'Software Engineer',
                description: 'Developed applications',
                start_year: Experience::MAX_YEAR + 1
              }
            }
          end

          it 'does not create a new experience' do
            expect {
              post admin_experiences_path, params: invalid_params
            }.not_to change(Experience, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_experiences_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when start_month is invalid' do
          let(:invalid_params) do
            {
              experience: {
                company_name: 'Test Company',
                title: 'Software Engineer',
                description: 'Developed applications',
                start_year: 2020,
                start_month: 13
              }
            }
          end

          it 'does not create a new experience' do
            expect {
              post admin_experiences_path, params: invalid_params
            }.not_to change(Experience, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_experiences_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when end_month is invalid' do
          let(:invalid_params) do
            {
              experience: {
                company_name: 'Test Company',
                title: 'Software Engineer',
                description: 'Developed applications',
                start_year: 2020,
                end_year: 2021,
                end_month: 0
              }
            }
          end

          it 'does not create a new experience' do
            expect {
              post admin_experiences_path, params: invalid_params
            }.not_to change(Experience, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_experiences_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when end date is earlier than start date' do
          let(:invalid_params) do
            {
              experience: {
                company_name: 'Test Company',
                title: 'Software Engineer',
                description: 'Developed applications',
                start_year: 2022,
                start_month: 6,
                end_year: 2020,
                end_month: 12
              }
            }
          end

          it 'does not create a new experience' do
            expect {
              post admin_experiences_path, params: invalid_params
            }.not_to change(Experience, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_experiences_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end

    describe 'PATCH /admin/experiences/:id' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            experience: {
              company_name: 'Updated Company',
              title: 'Senior Software Engineer',
              description: 'Led development team'
            }
          }
        end

        it 'updates the experience' do
          patch admin_experience_path(experience), params: valid_params
          experience.reload
          expect(experience.company_name).to eq('Updated Company')
          expect(experience.title).to eq('Senior Software Engineer')
          expect(experience.description).to eq('Led development team')
        end

        it 'redirects to the experiences index' do
          patch admin_experience_path(experience), params: valid_params
          expect(response).to redirect_to(admin_experiences_path)
        end

        it 'sets a success flash message' do
          patch admin_experience_path(experience), params: valid_params
          expect(flash[:notice]).to eq('Experience was successfully updated.')
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            experience: {
              company_name: '',
              title: 'Senior Software Engineer'
            }
          }
        end

        it 'does not update the experience' do
          original_company_name = experience.company_name
          patch admin_experience_path(experience), params: invalid_params
          experience.reload
          expect(experience.company_name).to eq(original_company_name)
        end

        it 'returns unprocessable entity status' do
          patch admin_experience_path(experience), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders the edit template' do
          patch admin_experience_path(experience), params: invalid_params
          expect(response).to render_template(:edit)
        end
      end
    end

    describe 'DELETE /admin/experiences/:id' do
      it 'destroys the experience' do
        expect {
          delete admin_experience_path(experience)
        }.to change(Experience, :count).by(-1)
      end

      it 'redirects to the experiences index' do
        delete admin_experience_path(experience)
        expect(response).to redirect_to(admin_experiences_path)
      end

      it 'sets a success flash message' do
        delete admin_experience_path(experience)
        expect(flash[:notice]).to eq('Experience was successfully destroyed.')
      end

      it 'returns see_other status' do
        delete admin_experience_path(experience)
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
    end

    describe 'GET /admin/experiences' do
      it 'redirects to login' do
        get admin_experiences_path
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'GET /admin/experiences/new' do
      it 'redirects to login' do
        get new_admin_experience_path
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'GET /admin/experiences/:id/edit' do
      it 'redirects to login' do
        get edit_admin_experience_path(experience)
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'POST /admin/experiences' do
      it 'redirects to login' do
        post admin_experiences_path, params: { experience: { company_name: 'Test' } }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'PATCH /admin/experiences/:id' do
      it 'redirects to login' do
        patch admin_experience_path(experience), params: { experience: { company_name: 'Test' } }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'DELETE /admin/experiences/:id' do
      it 'redirects to login' do
        delete admin_experience_path(experience)
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
