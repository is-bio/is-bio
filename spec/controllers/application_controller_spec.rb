require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  describe "#raise_404" do
    it "raises a RoutingError with message 'Not Found'" do
      expect {
        controller.send(:raise_404)
      }.to raise_error(ActionController::RoutingError, "Not Found")
    end
  end
end
