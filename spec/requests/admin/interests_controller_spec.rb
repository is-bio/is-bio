require 'rails_helper'

RSpec.describe Admin::InterestsController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let!(:resume) { create(:resume) }
  let!(:interest) { create(:interest, resume: resume) }

  describe 'when authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
      allow(Resume).to receive(:first!).and_return(resume)
    end

    describe 'GET /admin/interests' do
      it 'returns http success' do
        get admin_interests_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns @interests with all interests' do
        get admin_interests_path
        expect(assigns(:interests)).to include(interest)
      end

      it 'renders the index template' do
        get admin_interests_path
        expect(response).to render_template(:index)
      end
    end

    describe 'GET /admin/interests/new' do
      it 'returns http success' do
        get new_admin_interest_path
        expect(response).to have_http_status(:success)
      end

      it 'initializes a new interest' do
        get new_admin_interest_path
        expect(assigns(:interest)).to be_a_new(Interest)
      end

      it 'renders the new template' do
        get new_admin_interest_path
        expect(response).to render_template(:new)
      end
    end

    describe 'GET /admin/interests/:id/edit' do
      it 'returns http success' do
        get edit_admin_interest_path(interest)
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested interest to @interest' do
        get edit_admin_interest_path(interest)
        expect(assigns(:interest)).to eq(interest)
      end

      it 'renders the edit template' do
        get edit_admin_interest_path(interest)
        expect(response).to render_template(:edit)
      end

      # context 'when interest does not exist' do
      #   it 'raises ActiveRecord::RecordNotFound' do
      #     expect {
      #       get edit_admin_interest_path(id: 'nonexistent')
      #     }.to raise_error(ActiveRecord::RecordNotFound)
      #   end
      # end
    end

    describe 'POST /admin/interests' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            interest: {
              name: 'Photography'
            }
          }
        end

        it 'creates a new interest' do
          expect {
            post admin_interests_path, params: valid_params
          }.to change(Interest, :count).by(1)
        end

        it 'associates the interest with the first resume' do
          post admin_interests_path, params: valid_params
          created_interest = Interest.last
          expect(created_interest.resume).to eq(resume)
        end

        it 'redirects to the interests index' do
          post admin_interests_path, params: valid_params
          expect(response).to redirect_to(admin_interests_path)
        end

        it 'sets a success flash message' do
          post admin_interests_path, params: valid_params
          expect(flash[:notice]).to eq('Interest was successfully created.')
        end
      end

      context 'with invalid parameters' do
        context 'when name is blank' do
          let(:invalid_params) do
            {
              interest: {
                name: ''
              }
            }
          end

          it 'does not create a new interest' do
            expect {
              post admin_interests_path, params: invalid_params
            }.not_to change(Interest, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_interests_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the new template' do
            post admin_interests_path, params: invalid_params
            expect(response).to render_template(:new)
          end

          it 'assigns the interest with errors' do
            post admin_interests_path, params: invalid_params
            expect(assigns(:interest).errors[:name]).to include("can't be blank")
          end
        end

        context 'when name is not unique' do
          let(:invalid_params) do
            {
              interest: {
                name: interest.name
              }
            }
          end

          it 'does not create a new interest' do
            expect {
              post admin_interests_path, params: invalid_params
            }.not_to change(Interest, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_interests_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the new template' do
            post admin_interests_path, params: invalid_params
            expect(response).to render_template(:new)
          end

          it 'assigns the interest with uniqueness errors' do
            post admin_interests_path, params: invalid_params
            expect(assigns(:interest).errors[:name]).to include("has already been taken")
          end
        end
      end
    end

    describe 'PATCH /admin/interests/:id' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            interest: {
              name: 'Updated Interest'
            }
          }
        end

        it 'updates the interest' do
          patch admin_interest_path(interest), params: valid_params
          interest.reload
          expect(interest.name).to eq('Updated Interest')
        end

        it 'redirects to the interests index' do
          patch admin_interest_path(interest), params: valid_params
          expect(response).to redirect_to(admin_interests_path)
        end

        it 'sets a success flash message' do
          patch admin_interest_path(interest), params: valid_params
          expect(flash[:notice]).to eq('Interest was successfully updated.')
        end
      end

      context 'with invalid parameters' do
        context 'when name is blank' do
          let(:invalid_params) do
            {
              interest: {
                name: ''
              }
            }
          end

          it 'does not update the interest' do
            original_name = interest.name
            patch admin_interest_path(interest), params: invalid_params
            interest.reload
            expect(interest.name).to eq(original_name)
          end

          it 'returns unprocessable entity status' do
            patch admin_interest_path(interest), params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the edit template' do
            patch admin_interest_path(interest), params: invalid_params
            expect(response).to render_template(:edit)
          end

          it 'assigns the interest with errors' do
            patch admin_interest_path(interest), params: invalid_params
            expect(assigns(:interest).errors[:name]).to include("can't be blank")
          end
        end

        context 'when name is not unique' do
          let!(:other_interest) { create(:interest, name: 'Other Interest', resume: resume) }
          let(:invalid_params) do
            {
              interest: {
                name: other_interest.name
              }
            }
          end

          it 'does not update the interest' do
            original_name = interest.name
            patch admin_interest_path(interest), params: invalid_params
            interest.reload
            expect(interest.name).to eq(original_name)
          end

          it 'returns unprocessable entity status' do
            patch admin_interest_path(interest), params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the edit template' do
            patch admin_interest_path(interest), params: invalid_params
            expect(response).to render_template(:edit)
          end

          it 'assigns the interest with uniqueness errors' do
            patch admin_interest_path(interest), params: invalid_params
            expect(assigns(:interest).errors[:name]).to include("has already been taken")
          end
        end
      end

      # context 'when interest does not exist' do
      #   it 'raises ActiveRecord::RecordNotFound' do
      #     expect {
      #       patch admin_interest_path(id: 'nonexistent'), params: { interest: { name: 'Test' } }
      #     }.to raise_error(ActiveRecord::RecordNotFound)
      #   end
      # end
    end

    describe 'DELETE /admin/interests/:id' do
      it 'destroys the interest' do
        expect {
          delete admin_interest_path(interest)
        }.to change(Interest, :count).by(-1)
      end

      it 'redirects to the interests index' do
        delete admin_interest_path(interest)
        expect(response).to redirect_to(admin_interests_path)
      end

      it 'sets the correct redirect status' do
        delete admin_interest_path(interest)
        expect(response).to have_http_status(:see_other)
      end

      it 'sets a success flash message' do
        delete admin_interest_path(interest)
        expect(flash[:notice]).to eq('Interest was successfully destroyed.')
      end

      # context 'when interest does not exist' do
      #   it 'raises ActiveRecord::RecordNotFound' do
      #     expect {
      #       delete admin_interest_path(id: 'nonexistent')
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

    it 'redirects to login page when trying to access interests index' do
      get admin_interests_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to access new interest' do
      get new_admin_interest_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to edit interest' do
      get edit_admin_interest_path(interest)
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to create interest' do
      post admin_interests_path, params: { interest: { name: 'Test' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to update interest' do
      patch admin_interest_path(interest), params: { interest: { name: 'Test' } }
      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login page when trying to destroy interest' do
      delete admin_interest_path(interest)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
