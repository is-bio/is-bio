require 'rails_helper'

RSpec.describe Admin::ProjectsController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let!(:project) { create(:project) }

  describe 'when authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
    end

    describe 'GET /admin/projects' do
      it 'returns http success' do
        get admin_projects_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns @projects with all projects' do
        get admin_projects_path
        expect(assigns(:projects)).to include(project)
      end

      it 'renders the index template' do
        get admin_projects_path
        expect(response).to render_template(:index)
      end
    end

    describe 'GET /admin/projects/new' do
      it 'returns http success' do
        get new_admin_project_path
        expect(response).to have_http_status(:success)
      end

      it 'initializes a new project' do
        get new_admin_project_path
        expect(assigns(:project)).to be_a_new(Project)
      end

      it 'renders the new template' do
        get new_admin_project_path
        expect(response).to render_template(:new)
      end
    end

    describe 'GET /admin/projects/:id/edit' do
      it 'returns http success' do
        get edit_admin_project_path(project)
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested project to @project' do
        get edit_admin_project_path(project)
        expect(assigns(:project)).to eq(project)
      end

      it 'renders the edit template' do
        get edit_admin_project_path(project)
        expect(response).to render_template(:edit)
      end
    end

    describe 'POST /admin/projects' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            project: {
              name: 'E-commerce Platform',
              summary: 'A full-featured online shopping platform',
              description: 'Built with Ruby on Rails and React, featuring user authentication, payment processing, and inventory management'
            }
          }
        end

        it 'creates a new project' do
          expect {
            post admin_projects_path, params: valid_params
          }.to change(Project, :count).by(1)
        end

        it 'redirects to the projects index' do
          post admin_projects_path, params: valid_params
          expect(response).to redirect_to(admin_projects_path)
        end

        it 'sets a success flash message' do
          post admin_projects_path, params: valid_params
          expect(flash[:notice]).to eq('Project was successfully created.')
        end
      end

      context 'with invalid parameters' do
        context 'when name is blank' do
          let(:invalid_params) do
            {
              project: {
                name: '',
                summary: 'A web application',
                description: 'Built with Ruby on Rails'
              }
            }
          end

          it 'does not create a new project' do
            expect {
              post admin_projects_path, params: invalid_params
            }.not_to change(Project, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_projects_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'renders the new template' do
            post admin_projects_path, params: invalid_params
            expect(response).to render_template(:new)
          end
        end

        context 'when summary is blank' do
          let(:invalid_params) do
            {
              project: {
                name: 'Test Project',
                summary: '',
                description: 'Built with Ruby on Rails'
              }
            }
          end

          it 'does not create a new project' do
            expect {
              post admin_projects_path, params: invalid_params
            }.not_to change(Project, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_projects_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'when description is blank' do
          let(:invalid_params) do
            {
              project: {
                name: 'Test Project',
                summary: 'A web application',
                description: ''
              }
            }
          end

          it 'does not create a new project' do
            expect {
              post admin_projects_path, params: invalid_params
            }.not_to change(Project, :count)
          end

          it 'returns unprocessable entity status' do
            post admin_projects_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end

    describe 'PATCH /admin/projects/:id' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            project: {
              name: 'Updated Project Name',
              summary: 'Updated project summary',
              description: 'Updated detailed description of the project'
            }
          }
        end

        it 'updates the project' do
          patch admin_project_path(project), params: valid_params
          project.reload
          expect(project.name).to eq('Updated Project Name')
          expect(project.summary).to eq('Updated project summary')
          expect(project.description).to eq('Updated detailed description of the project')
        end

        it 'redirects to the projects index' do
          patch admin_project_path(project), params: valid_params
          expect(response).to redirect_to(admin_projects_path)
        end

        it 'sets a success flash message' do
          patch admin_project_path(project), params: valid_params
          expect(flash[:notice]).to eq('Project was successfully updated.')
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            project: {
              name: '',
              summary: 'Updated summary'
            }
          }
        end

        it 'does not update the project' do
          original_name = project.name
          patch admin_project_path(project), params: invalid_params
          project.reload
          expect(project.name).to eq(original_name)
        end

        it 'returns unprocessable entity status' do
          patch admin_project_path(project), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders the edit template' do
          patch admin_project_path(project), params: invalid_params
          expect(response).to render_template(:edit)
        end
      end
    end

    describe 'DELETE /admin/projects/:id' do
      it 'destroys the project' do
        expect {
          delete admin_project_path(project)
        }.to change(Project, :count).by(-1)
      end

      it 'redirects to the projects index' do
        delete admin_project_path(project)
        expect(response).to redirect_to(admin_projects_path)
      end

      it 'sets a success flash message' do
        delete admin_project_path(project)
        expect(flash[:notice]).to eq('Project was successfully destroyed.')
      end

      it 'returns see_other status' do
        delete admin_project_path(project)
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe 'when not authenticated' do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
    end

    describe 'GET /admin/projects' do
      it 'redirects to login' do
        get admin_projects_path
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'GET /admin/projects/new' do
      it 'redirects to login' do
        get new_admin_project_path
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'GET /admin/projects/:id/edit' do
      it 'redirects to login' do
        get edit_admin_project_path(project)
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'POST /admin/projects' do
      it 'redirects to login' do
        post admin_projects_path, params: { project: { name: 'Test' } }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'PATCH /admin/projects/:id' do
      it 'redirects to login' do
        patch admin_project_path(project), params: { project: { name: 'Test' } }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'DELETE /admin/projects/:id' do
      it 'redirects to login' do
        delete admin_project_path(project)
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
