require "rails_helper"

RSpec.describe PostsController do
  describe "GET index" do
    # This is just for example purpose.
    # it "assigns @teams" do
    #   team = Team.create
    #   get :index
    #   expect(assigns(:teams)).to eq([team])
    # end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end
end
