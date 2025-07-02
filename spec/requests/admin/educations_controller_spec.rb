require 'rails_helper'

RSpec.describe Admin::EducationsController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let!(:education) { create(:education) }

  describe 'when authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
    end

    describe 'GET /admin/educations' do
      it 'returns http success' do
        get admin_educations_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns @educations with all educations' do
        get admin_educations_path
        expect(assigns(:educations)).to include(education)
      end

      it 'renders the index template' do
        get admin_educations_path
        expect(response).to render_template(:index)
      end
    end

    describe 'GET /admin/educations/new' do
      it 'returns http success' do
        get new_admin_education_path
        expect(response).to have_http_status(:success)
      end

      it 'initializes a new education' do
        get new_admin_education_path
        expect(assigns(:education)).to be_a_new(Education)
      end

      it 'renders the new template' do
        get new_admin_education_path
        expect(response).to render_template(:new)
      end
    end

    describe 'GET /admin/educations/:id/edit' do
      it 'returns http success' do
        get edit_admin_education_path(education)
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested education to @education' do
        get edit_admin_education_path(education)
        expect(assigns(:education)).to eq(education)
      end

      it 'renders the edit template' do
        get edit_admin_education_path(education)
        expect(response).to render_template(:edit)
      end
    end

    describe 'POST /admin/educations' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            education: {
              school_name: 'Stanford University',
              degree: 'Master of Science',
              field_of_study: 'Computer Science',
              start_year: 2020,
              end_year: 2022
            }
          }
        end

        it 'creates a new education' do
          expect {
            post admin_educations_path, params: valid_params
          }.to change(Education, :count).by(1)
        end

        it 'redirects to the educations index' do
          post admin_educations_path, params: valid_params
          expect(response).to redirect_to(admin_educations_path)
        end

        it 'sets a success flash message' do
          post admin_educations_path, params: valid_params
          expect(flash[:notice]).to eq('Education was successfully created.')
        end
      end

      context 'with invalid parameters' do
        context 'when school_name is blank' do
          let(:invalid_params) do
            {
              education: {
                school_name: '',
                degree: 'Bachelor of Science',
                field_of_study: 'Computer Science',
                start_year: 2020,
                end_year: 2022
              }
            }
          end

          it 'does not create a new education' do
            expect {
              post admin_educations_path, params: invalid_params
            }.not_to change(Education, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_educations_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the new template' do
            post admin_educations_path, params: invalid_params
            expect(response).to render_template(:new)
          end
        end

        context 'when start_year is before 1960' do
          let(:invalid_params) do
            {
              education: {
                school_name: 'Test University',
                degree: 'Bachelor of Science',
                field_of_study: 'Computer Science',
                start_year: 1950,
                end_year: 1954
              }
            }
          end

          it 'does not create a new education' do
            expect {
              post admin_educations_path, params: invalid_params
            }.not_to change(Education, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_educations_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when start_year is after current_year + 8' do
          let(:invalid_params) do
            {
              education: {
                school_name: 'Test University',
                degree: 'Bachelor of Science',
                field_of_study: 'Computer Science',
                start_year: Date.current.year + 10,
                end_year: Date.current.year + 14
              }
            }
          end

          it 'does not create a new education' do
            expect {
              post admin_educations_path, params: invalid_params
            }.not_to change(Education, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_educations_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when end_year is before start_year' do
          let(:invalid_params) do
            {
              education: {
                school_name: 'Test University',
                degree: 'Bachelor of Science',
                field_of_study: 'Computer Science',
                start_year: 2022,
                end_year: 2020
              }
            }
          end

          it 'does not create a new education' do
            expect {
              post admin_educations_path, params: invalid_params
            }.not_to change(Education, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_educations_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end

    describe 'PATCH /admin/educations/:id' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            education: {
              school_name: 'Updated University',
              degree: 'Master of Engineering',
              field_of_study: 'Software Engineering',
              start_year: 2021,
              end_year: 2023
            }
          }
        end

        it 'updates the education' do
          patch admin_education_path(education), params: valid_params
          education.reload
          expect(education.school_name).to eq('Updated University')
          expect(education.degree).to eq('Master of Engineering')
          expect(education.field_of_study).to eq('Software Engineering')
          expect(education.start_year).to eq(2021)
          expect(education.end_year).to eq(2023)
        end

        it 'redirects to the educations index' do
          patch admin_education_path(education), params: valid_params
          expect(response).to redirect_to(admin_educations_path)
        end

        it 'sets a success flash message' do
          patch admin_education_path(education), params: valid_params
          expect(flash[:notice]).to eq('Education was successfully updated.')
        end
      end

      context 'with invalid parameters' do
        context 'when school_name is blank' do
          let(:invalid_params) do
            {
              education: {
                school_name: '',
                degree: 'Bachelor of Science',
                field_of_study: 'Computer Science',
                start_year: 2020,
                end_year: 2022
              }
            }
          end

          it 'does not update the education' do
            original_name = education.school_name
            patch admin_education_path(education), params: invalid_params
            education.reload
            expect(education.school_name).to eq(original_name)
          end

          it 'returns unprocessable entity status' do
            patch admin_education_path(education), params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the edit template' do
            patch admin_education_path(education), params: invalid_params
            expect(response).to render_template(:edit)
          end
        end

        context 'when start_year is before 1960' do
          let(:invalid_params) do
            {
              education: {
                school_name: 'Test University',
                degree: 'Bachelor of Science',
                field_of_study: 'Computer Science',
                start_year: 1950,
                end_year: 1954
              }
            }
          end

          it 'does not update the education' do
            original_start_year = education.start_year
            patch admin_education_path(education), params: invalid_params
            education.reload
            expect(education.start_year).to eq(original_start_year)
          end

          it 'returns unprocessable entity status' do
            patch admin_education_path(education), params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when start_year is after current_year + 8' do
          let(:invalid_params) do
            {
              education: {
                school_name: 'Test University',
                degree: 'Bachelor of Science',
                field_of_study: 'Computer Science',
                start_year: Date.current.year + 10,
                end_year: Date.current.year + 14
              }
            }
          end

          it 'does not update the education' do
            original_start_year = education.start_year
            patch admin_education_path(education), params: invalid_params
            education.reload
            expect(education.start_year).to eq(original_start_year)
          end

          it 'returns unprocessable entity status' do
            patch admin_education_path(education), params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when end_year is before start_year' do
          let(:invalid_params) do
            {
              education: {
                school_name: 'Test University',
                degree: 'Bachelor of Science',
                field_of_study: 'Computer Science',
                start_year: 2022,
                end_year: 2020
              }
            }
          end

          it 'does not update the education' do
            original_end_year = education.end_year
            patch admin_education_path(education), params: invalid_params
            education.reload
            expect(education.end_year).to eq(original_end_year)
          end

          it 'returns unprocessable entity status' do
            patch admin_education_path(education), params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end

    describe 'DELETE /admin/educations/:id' do
      let!(:education_to_delete) { create(:education) }

      it 'destroys the education' do
        expect {
          delete admin_education_path(education_to_delete)
        }.to change(Education, :count).by(-1)
      end

      it 'redirects to the educations index' do
        delete admin_education_path(education_to_delete)
        expect(response).to redirect_to(admin_educations_path)
      end

      it 'returns see other status' do
        delete admin_education_path(education_to_delete)
        expect(response).to have_http_status(:see_other)
      end

      it 'sets a success flash message' do
        delete admin_education_path(education_to_delete)
        expect(flash[:notice]).to eq('Education was successfully destroyed.')
      end
    end
  end

  describe 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
    end

    it 'redirects to login for index' do
      get admin_educations_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for new' do
      get new_admin_education_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for edit' do
      get edit_admin_education_path(education)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for create' do
      post admin_educations_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for update' do
      patch admin_education_path(education)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login for destroy' do
      delete admin_education_path(education)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
