require "rails_helper"

RSpec.describe Admin::SubdomainsController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let(:locale) { Locale.find_or_create_by(key: 'en') }
  let(:subdomain) { Subdomain.find_or_create_by(locale: locale) }
  let(:new_locale) { Locale.find_or_create_by(key: 'es') }

  before do
    allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
  end

  describe "GET /admin/subdomains" do
    it "returns http success" do
      get admin_subdomains_path
      expect(response).to have_http_status(:success)
    end

    it "displays all subdomains" do
      subdomains = create_list(:subdomain, 3)
      get admin_subdomains_path
      expect(response.body).to include(subdomains[0].value)
      expect(response.body).to include(subdomains[1].value)
      expect(response.body).to include(subdomains[2].value)
    end
  end

  describe "GET /admin/subdomains/new" do
    it "returns http success" do
      get new_admin_subdomain_path
      expect(response).to have_http_status(:success)
    end

    it "initializes a new subdomain" do
      get new_admin_subdomain_path
      expect(assigns(:subdomain)).to be_a_new(Subdomain)
    end

    it "loads all available locales" do
      locales = create_list(:locale, 3)
      get new_admin_subdomain_path
      expect(assigns(:locales)).not_to be_nil
    end
  end

  describe "POST /admin/subdomains" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          subdomain: {
            value: "test-sub",
            locale_id: locale.id
          }
        }
      end

      it "creates a new subdomain" do
        expect {
          post admin_subdomains_path, params: valid_params
        }.to change(Subdomain, :count).by(1)
      end

      it "redirects to the subdomains list" do
        post admin_subdomains_path, params: valid_params
        expect(response).to redirect_to(admin_subdomains_path)
      end

      it "sets a success flash message" do
        post admin_subdomains_path, params: valid_params
        expect(flash[:notice]).to eq("Subdomain was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          subdomain: {
            value: "",
            locale_id: nil
          }
        }
      end

      it "does not create a new subdomain" do
        expect {
          post admin_subdomains_path, params: invalid_params
        }.not_to change(Subdomain, :count)
      end

      it "returns unprocessable entity status" do
        post admin_subdomains_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the new template" do
        post admin_subdomains_path, params: invalid_params
        expect(response).to render_template(:new)
      end

      it "assigns locales for the form" do
        post admin_subdomains_path, params: invalid_params
        expect(assigns(:locales)).not_to be_nil
      end
    end

    context "with duplicate value" do
      let!(:existing) { create(:subdomain, value: "duplicate") }

      it "shows validation error" do
        post admin_subdomains_path, params: {
          subdomain: { value: "duplicate", locale_id: locale.id }
        }
        expect(response.body).to include("has already been taken")
      end
    end
  end

  describe "GET /admin/subdomains/:id/edit" do
    it "returns http success" do
      get edit_admin_subdomain_path(subdomain)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested subdomain" do
      get edit_admin_subdomain_path(subdomain)
      expect(assigns(:subdomain)).to eq(subdomain)
    end

    it "loads all available locales" do
      get edit_admin_subdomain_path(subdomain)
      expect(assigns(:locales)).not_to be_nil
    end
  end

  describe "PATCH /admin/subdomains/:id" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          subdomain: {
            value: "updated-value",
            locale_id: new_locale.id
          }
        }
      end

      it "updates the subdomain" do
        patch admin_subdomain_path(subdomain), params: valid_params
        subdomain.reload
        expect(subdomain.value).to eq("updated-value")
        expect(subdomain.locale_id).to eq(new_locale.id)
      end

      it "redirects to the subdomains list" do
        patch admin_subdomain_path(subdomain), params: valid_params
        expect(response).to redirect_to(admin_subdomains_path)
      end

      it "sets a success flash message" do
        patch admin_subdomain_path(subdomain), params: valid_params
        expect(flash[:notice]).to eq("Subdomain was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          subdomain: {
            value: "",
            locale_id: nil
          }
        }
      end

      it "does not update the subdomain" do
        original_value = subdomain.value
        patch admin_subdomain_path(subdomain), params: invalid_params
        subdomain.reload
        expect(subdomain.value).to eq(original_value)
      end

      it "returns unprocessable entity status" do
        patch admin_subdomain_path(subdomain), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        patch admin_subdomain_path(subdomain), params: invalid_params
        expect(response).to render_template(:edit)
      end

      it "assigns locales for the form" do
        patch admin_subdomain_path(subdomain), params: invalid_params
        expect(assigns(:locales)).not_to be_nil
      end
    end
  end

  describe "DELETE /admin/subdomains/:id" do
    let!(:subdomain_to_delete) { create(:subdomain) }

    it "destroys the subdomain" do
      expect {
        delete admin_subdomain_path(subdomain_to_delete)
      }.to change(Subdomain, :count).by(-1)
      expect(Subdomain.exists?(subdomain_to_delete.id)).to be false

      it "redirects to the subdomains list" do
        delete admin_subdomain_path(subdomain_to_delete)
        expect(response).to redirect_to(admin_subdomains_path)
      end

      it "sets a success flash message" do
        delete admin_subdomain_path(subdomain_to_delete)
        expect(flash[:notice]).to eq("Subdomain was successfully deleted.")
      end

      context "when an error occurs during deletion" do
        before do
          allow_any_instance_of(Subdomain).to receive(:destroy).and_raise(StandardError.new("Test error"))
        end

        it "redirects to the subdomains list with error message" do
          delete admin_subdomain_path(subdomain_to_delete)
          expect(response).to redirect_to(admin_subdomains_path)
          expect(flash[:alert]).to include("Error deleting subdomain")
        end
      end
    end

    context "when not authenticated" do
      before do
        allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
        allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(nil)
      end

      it "redirects to login page when trying to access subdomains index" do
        get admin_subdomains_path
        expect(response).to redirect_to(new_session_path)
      end

      it "redirects to login page when trying to create a subdomain" do
        post admin_subdomains_path, params: { subdomain: { value: "test" } }
        expect(response).to redirect_to(new_session_path)
      end

      it "redirects to login page when trying to edit a subdomain" do
        get edit_admin_subdomain_path(subdomain)
        expect(response).to redirect_to(new_session_path)
      end

      it "redirects to login page when trying to delete a subdomain" do
        delete admin_subdomain_path(subdomain)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
