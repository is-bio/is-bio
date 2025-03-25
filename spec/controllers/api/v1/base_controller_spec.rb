require "rails_helper"

RSpec.describe Api::V1::BaseController, type: :controller do
  controller(described_class) do
    # We don't need to define actions here since we're testing methods directly
  end

  describe "#raise_404" do
    it "raises a RoutingError with the default message" do
      expect {
        controller.send(:raise_404)
      }.to raise_error(ActionController::RoutingError, "Not Found")
    end

    it "raises a RoutingError with a custom message" do
      custom_message = "Custom error message"
      expect {
        controller.send(:raise_404, custom_message)
      }.to raise_error(ActionController::RoutingError, custom_message)
    end
  end

  describe "#authenticate_sender!" do
    context "when GithubAppSetting with key='app_id' doesn't exist" do
      before do
        relation = instance_double(ActiveRecord::Relation, take: nil)
        allow(GithubAppSetting).to receive(:where).with(key: "app_id").and_return(relation)
      end

      it "raises a RoutingError with appropriate message" do
        expected_message = "There is no record with key='app_id' in the 'github_app_settings' table! Please insert it first."
        expect {
          controller.send(:authenticate_sender!)
        }.to raise_error(ActionController::RoutingError, expected_message)
      end
    end

    context "when X-GitHub-Hook-Installation-Target-ID header doesn't match setting value" do
      let(:setting) { instance_double(GithubAppSetting, value: "12345") }

      before do
        relation = instance_double(ActiveRecord::Relation, take: setting)
        allow(GithubAppSetting).to receive(:where).with(key: "app_id").and_return(relation)
        allow(controller.request).to receive(:headers).and_return({
          "X-GitHub-Hook-Installation-Target-ID" => "54321"
        })
      end

      it "raises a RoutingError with appropriate message" do
        expected_message = "The 'app_id' value is not equal to the value of request header 'X-GitHub-Hook-Installation-Target-ID'. They should be the same！"
        expect {
          controller.send(:authenticate_sender!)
        }.to raise_error(ActionController::RoutingError, expected_message)
      end
    end

    context "when X-GitHub-Event header is not 'push'" do
      let(:setting) { instance_double(GithubAppSetting, value: "12345") }

      before do
        relation = instance_double(ActiveRecord::Relation, take: setting)
        allow(GithubAppSetting).to receive(:where).with(key: "app_id").and_return(relation)
        allow(controller.request).to receive(:headers).and_return({
          "X-GitHub-Hook-Installation-Target-ID" => "12345",
          "X-GitHub-Event" => "pull_request"
        })
      end

      it "raises a RoutingError with appropriate message" do
        expected_message = "The system only handles GitHub 'push' events!"
        expect {
          controller.send(:authenticate_sender!)
        }.to raise_error(ActionController::RoutingError, expected_message)
      end
    end

    context "when all conditions are met" do
      let(:setting) { instance_double(GithubAppSetting, value: "12345") }

      before do
        relation = instance_double(ActiveRecord::Relation, take: setting)
        allow(GithubAppSetting).to receive(:where).with(key: "app_id").and_return(relation)
        allow(controller.request).to receive(:headers).and_return({
          "X-GitHub-Hook-Installation-Target-ID" => "12345",
          "X-GitHub-Event" => "push"
        })
      end

      it "passes authentication without raising an error" do
        expect {
          controller.send(:authenticate_sender!)
        }.not_to raise_error
      end
    end
  end
end
