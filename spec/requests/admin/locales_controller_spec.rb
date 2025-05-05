require "rails_helper"

RSpec.describe Admin::LocalesController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let(:locale) { create(:locale) }

  before do
    allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
  end

  describe "GET /admin/locales" do
    it "returns http success" do
      get admin_locales_path
      expect(response).to have_http_status(:success)
    end

    it "displays all locales" do
      locales = create_list(:locale, 3)
      get admin_locales_path
      expect(response.body).to include(locales[0].key)
      expect(response.body).to include(locales[1].key)
      expect(response.body).to include(locales[2].key)
    end
  end

  describe "GET /admin/locales/new" do
    it "returns http success" do
      get new_admin_locale_path
      expect(response).to have_http_status(:success)
    end

    it "initializes a new locale" do
      get new_admin_locale_path
      expect(assigns(:locale)).to be_a_new(Locale)
    end
  end

  describe "POST /admin/locales" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          locale: {
            key: "fr",
            english_name: "French",
            name: "Français"
          }
        }
      end

      it "creates a new locale" do
        Locale.find_by(key: "fr").destroy!

        expect {
          post admin_locales_path, params: valid_params
        }.to change(Locale, :count).by(1)
      end

      it "redirects to the locales list" do
        post admin_locales_path, params: valid_params
        expect(response).to redirect_to(admin_locales_path)
      end

      it "sets a success flash message" do
        post admin_locales_path, params: valid_params
        expect(flash[:notice]).to eq("Locale was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          locale: {
            key: "invalid-format",
            english_name: "",
            name: ""
          }
        }
      end

      it "does not create a new locale" do
        expect {
          post admin_locales_path, params: invalid_params
        }.not_to change(Locale, :count)
      end

      it "returns unprocessable entity status" do
        post admin_locales_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the new template" do
        post admin_locales_path, params: invalid_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET /admin/locales/:id/edit" do
    it "returns http success" do
      get edit_admin_locale_path(locale)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested locale" do
      get edit_admin_locale_path(locale)
      expect(assigns(:locale)).to eq(locale)
    end
  end

  describe "PATCH /admin/locales/:id" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          locale: {
            key: "es",
            english_name: "Spanish",
            name: "Español"
          }
        }
      end

      it "updates the locale" do
        patch admin_locale_path(locale), params: valid_params
        locale.reload
        expect(locale.key).to eq("es")
        expect(locale.english_name).to eq("Spanish")
        expect(locale.name).to eq("Español")
      end

      it "redirects to the locales list" do
        patch admin_locale_path(locale), params: valid_params
        expect(response).to redirect_to(admin_locales_path)
      end

      it "sets a success flash message" do
        patch admin_locale_path(locale), params: valid_params
        expect(flash[:notice]).to eq("Locale was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          locale: {
            key: "invalid-format",
            english_name: "",
            name: ""
          }
        }
      end

      it "does not update the locale" do
        original_key = locale.key
        patch admin_locale_path(locale), params: invalid_params
        locale.reload
        expect(locale.key).to eq(original_key)
      end

      it "returns unprocessable entity status" do
        patch admin_locale_path(locale), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        patch admin_locale_path(locale), params: invalid_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE /admin/locales/:id" do
    context "when locale has no associated records" do
      it "destroys the locale" do
        locale = create(:locale)
        expect {
          delete admin_locale_path(locale)
        }.to change(Locale, :count).by(-1)
      end

      it "redirects to the locales list" do
        delete admin_locale_path(locale)
        expect(response).to redirect_to(admin_locales_path)
      end

      it "sets a success flash message" do
        delete admin_locale_path(locale)
        expect(flash[:notice]).to eq("Locale was successfully deleted.")
      end
    end
  end

  context "when not authenticated" do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(nil)
    end

    it "redirects to login page when trying to access locales index" do
      get admin_locales_path
      expect(response).to redirect_to(new_session_path)
    end

    it "redirects to login page when trying to create a locale" do
      post admin_locales_path, params: { locale: { key: "fr" } }
      expect(response).to redirect_to(new_session_path)
    end

    it "redirects to login page when trying to edit a locale" do
      get edit_admin_locale_path(locale)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
