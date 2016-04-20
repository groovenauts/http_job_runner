require "rails_helper"

RSpec.describe Delayed::JobsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/delayed/jobs").to route_to("delayed/jobs#index")
    end

    it "routes to #new" do
      expect(:get => "/delayed/jobs/new").to route_to("delayed/jobs#new")
    end

    it "routes to #show" do
      expect(:get => "/delayed/jobs/1").to route_to("delayed/jobs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/delayed/jobs/1/edit").to route_to("delayed/jobs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/delayed/jobs").to route_to("delayed/jobs#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/delayed/jobs/1").to route_to("delayed/jobs#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/delayed/jobs/1").to route_to("delayed/jobs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/delayed/jobs/1").to route_to("delayed/jobs#destroy", :id => "1")
    end

  end
end
