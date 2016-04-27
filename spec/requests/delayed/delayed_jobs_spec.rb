require 'rails_helper'

RSpec.describe "Delayed::Jobs", type: :request do
  describe "GET /delayed_jobs" do
    it "works! (now write some real specs)" do
      get delayed_jobs_path
      expect(response).to have_http_status(200)
    end
  end
end
