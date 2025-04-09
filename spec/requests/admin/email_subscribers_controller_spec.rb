require "rails_helper"

RSpec.describe Admin::EmailSubscribersController, type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }
  let(:email_subscriber) { create(:email_subscriber) }

  before do
    allow_any_instance_of(Admin::BaseController).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Admin::BaseController).to receive(:resume_session).and_return(session)
  end

  describe "GET /admin/email_subscribers" do
    it "returns http success" do
      get admin_email_subscribers_path
      expect(response).to have_http_status(:success)
    end

    it "displays all email subscribers" do
      subscribers = create_list(:email_subscriber, 3)
      get admin_email_subscribers_path
      expect(response.body).to include(subscribers[0].email)
      expect(response.body).to include(subscribers[1].email)
      expect(response.body).to include(subscribers[2].email)
    end
  end

  describe "GET /admin/email_subscribers/new" do
    it "returns http success" do
      get new_admin_email_subscriber_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/email_subscribers" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          email_subscriber: {
            email: "test@example.com",
            confirmed: false
          }
        }
      end

      it "creates a new email subscriber" do
        expect {
          post admin_email_subscribers_path, params: valid_params
        }.to change(EmailSubscriber, :count).by(1)
      end

      it "redirects to the subscribers list" do
        post admin_email_subscribers_path, params: valid_params
        expect(response).to redirect_to(admin_email_subscribers_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          email_subscriber: {
            email: "invalid-email",
            confirmed: false
          }
        }
      end

      it "does not create a new email subscriber" do
        expect {
          post admin_email_subscribers_path, params: invalid_params
        }.not_to change(EmailSubscriber, :count)
      end

      it "returns unprocessable entity status" do
        post admin_email_subscribers_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /admin/email_subscribers/:id" do
    it "deletes the email subscriber" do
      subscriber = create(:email_subscriber)
      expect {
        delete admin_email_subscriber_path(subscriber)
      }.to change(EmailSubscriber, :count).by(-1)
    end

    it "redirects to the subscribers list" do
      delete admin_email_subscriber_path(email_subscriber)
      expect(response).to redirect_to(admin_email_subscribers_path)
    end
  end

  describe "POST /admin/email_subscribers/:id/send_verification_email" do
    let(:unconfirmed_subscriber) { create(:email_subscriber, confirmed: false) }

    context "when subscriber is not confirmed" do
      it "sends verification email" do
        expect {
          post send_verification_email_admin_email_subscriber_path(unconfirmed_subscriber)
        }.to have_enqueued_job.on_queue("default")
      end

      it "redirects with success notice" do
        post send_verification_email_admin_email_subscriber_path(unconfirmed_subscriber)
        expect(response).to redirect_to(admin_email_subscribers_path)
        expect(flash[:notice]).to include("Verification email has been sent")
      end
    end

    context "when subscriber is already confirmed" do
      let(:confirmed_subscriber) { create(:email_subscriber, confirmed: true) }

      it "redirects with alert" do
        post send_verification_email_admin_email_subscriber_path(confirmed_subscriber)
        expect(response).to redirect_to(admin_email_subscribers_path)
        expect(flash[:alert]).to eq("Subscriber is already confirmed.")
      end
    end
  end
end
