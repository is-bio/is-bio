require "rails_helper"

RSpec.describe Admin::ThemesController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let(:theme) { create(:theme) }

  before do
    allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
  end

  describe "GET /admin/themes" do
    it "returns http success" do
      get admin_themes_path
      expect(response).to have_http_status(:success)
    end

    it "displays all themes" do
      themes = create_list(:theme, 3)
      get admin_themes_path
      expect(response.body).to include(themes[0].name)
      expect(response.body).to include(themes[1].name)
      expect(response.body).to include(themes[2].name)
    end

    it "includes theme colors" do
      theme = create(:theme, color: 3)
      get admin_themes_path
      expect(response.body).to include("Color #{theme.color}")
    end
  end

  describe "GET /admin/themes/:id/edit" do
    it "returns http success" do
      get edit_admin_theme_path(theme)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested theme" do
      get edit_admin_theme_path(theme)
      expect(assigns(:theme)).to eq(theme)
    end

    it "displays the theme name in the form" do
      get edit_admin_theme_path(theme)
      expect(response.body).to include(theme.name)
    end

    it "includes color options" do
      get edit_admin_theme_path(theme)
      (1..8).each do |i|
        expect(response.body).to include("Color #{i}")
      end
    end
  end

  describe "PATCH /admin/themes/:id" do
    context "with valid parameters" do
      let(:new_color) { theme.color == 1 ? 2 : 1 } # Choose a different color
      let(:valid_params) do
        {
          theme: {
            color: new_color
          }
        }
      end

      it "updates the theme" do
        patch admin_theme_path(theme), params: valid_params
        theme.reload
        expect(theme.color).to eq(new_color)
      end

      it "redirects to the themes list" do
        patch admin_theme_path(theme), params: valid_params
        expect(response).to redirect_to(admin_themes_path)
      end

      it "sets a success flash message" do
        patch admin_theme_path(theme), params: valid_params
        expect(flash[:notice]).to eq("Theme was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          theme: {
            color: 10 # Out of valid range (1-8)
          }
        }
      end

      it "does not update the theme" do
        original_color = theme.color
        patch admin_theme_path(theme), params: invalid_params
        theme.reload
        expect(theme.color).to eq(original_color)
      end

      it "returns unprocessable entity status" do
        patch admin_theme_path(theme), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        patch admin_theme_path(theme), params: invalid_params
        expect(response).to render_template(:edit)
      end
    end

    context "with non-numeric color" do
      let(:invalid_params) do
        {
          theme: {
            color: "invalid"
          }
        }
      end

      it "does not update the theme" do
        original_color = theme.color
        patch admin_theme_path(theme), params: invalid_params
        theme.reload
        expect(theme.color).to eq(original_color)
      end
    end
  end

  context "when not authenticated" do
    before do
      allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(false)
      allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(nil)
    end

    it "redirects to login page when trying to access themes index" do
      get admin_themes_path
      expect(response).to redirect_to(new_session_path)
    end

    it "redirects to login page when trying to edit a theme" do
      get edit_admin_theme_path(theme)
      expect(response).to redirect_to(new_session_path)
    end

    it "redirects to login page when trying to update a theme" do
      patch admin_theme_path(theme), params: { theme: { color: 1 } }
      expect(response).to redirect_to(new_session_path)
    end
  end
end
