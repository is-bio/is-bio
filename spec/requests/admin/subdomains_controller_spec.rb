require "rails_helper"

RSpec.describe Admin::SubdomainsController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let(:locale) { create(:locale) }
  let(:new_locale) { create(:locale) }

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
      subdomains = create_list(:subdomain, 3, locale: locale)
      get admin_subdomains_path
      subdomains.each do |subdomain|
        expect(response.body).to include(subdomain.value)
      end
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
  end

  describe "POST /admin/subdomains" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          subdomain: {
            value: "new-subdomain",
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
    end
  end

  describe "PATCH /admin/subdomains/:id" do
    let!(:test_subdomain) { create(:subdomain, value: "test-subdomain", locale: locale) }

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
        patch admin_subdomain_path(test_subdomain), params: valid_params
        test_subdomain.reload
        expect(test_subdomain.value).to eq("updated-value")
        expect(test_subdomain.locale_id).to eq(new_locale.id)
      end

      it "redirects to the subdomains list" do
        patch admin_subdomain_path(test_subdomain), params: valid_params
        expect(response).to redirect_to(admin_subdomains_path)
      end

      it "sets a success flash message" do
        patch admin_subdomain_path(test_subdomain), params: valid_params
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
        original_value = test_subdomain.value
        patch admin_subdomain_path(test_subdomain), params: invalid_params
        test_subdomain.reload
        expect(test_subdomain.value).to eq(original_value)
      end

      it "returns unprocessable entity status" do
        patch admin_subdomain_path(test_subdomain), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        patch admin_subdomain_path(test_subdomain), params: invalid_params
        expect(response).to render_template(:edit)
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
    end

    it "redirects to the subdomains list" do
      delete admin_subdomain_path(subdomain_to_delete)
      expect(response).to redirect_to(admin_subdomains_path)
    end

    it "sets a success flash message" do
      delete admin_subdomain_path(subdomain_to_delete)
      expect(flash[:notice]).to eq("Subdomain was successfully deleted.")
    end
  end

  context "when not authenticated" do
    let!(:subdomain_to_delete) { create(:subdomain) }

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
      get edit_admin_subdomain_path(subdomain_to_delete)
      expect(response).to redirect_to(new_session_path)
    end

    it "redirects to login page when trying to delete a subdomain" do
      delete admin_subdomain_path(subdomain_to_delete)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
