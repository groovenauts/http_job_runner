require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe Delayed::JobsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Delayed::Job. As you add validations to Delayed::Job, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    FactoryGirl.attributes_for(:delayed_job)
  }

  let(:valid_params) {
    FactoryGirl.attributes_for(:delayed_job).tap{|d| d.delete("handler"); d["command"] = "date" }
  }

  let(:invalid_attributes) {
    valid_params.tap{|d| d["command"] = nil}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Delayed::JobsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all delayed_jobs as @delayed_jobs" do
      job = Delayed::Job.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:delayed_jobs)).to eq([job])
    end
  end

  describe "GET #show" do
    it "assigns the requested delayed_job as @delayed_job" do
      job = Delayed::Job.create! valid_attributes
      get :show, {:id => job.to_param}, valid_session
      expect(assigns(:delayed_job)).to eq(job)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Delayed::Job" do
        expect {
          post :create, {:job => valid_params}, valid_session
        }.to change(Delayed::Job, :count).by(1)
      end

      it "assigns a newly created delayed_job as @delayed_job" do
        post :create, {:job => valid_params}, valid_session
        expect(assigns(:delayed_job)).to be_a(Delayed::Job)
        expect(assigns(:delayed_job)).to be_persisted
      end

      it "redirects to the created delayed_job" do
        post :create, {:job => valid_params}, valid_session
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved delayed_job as @delayed_job" do
        post :create, {:job => invalid_attributes}, valid_session
        expect(assigns(:delayed_job)).to be_a_new(Delayed::Job)
      end

      it "re-renders the 'new' template" do
        post :create, {:job => invalid_attributes}, valid_session
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {"priority" => 2}
      }

      it "updates the requested delayed_job" do
        job = Delayed::Job.create! valid_attributes
        put :update, {:id => job.to_param, :job => new_attributes}, valid_session
        job.reload
        expect(job.priority).to eq 2
      end

      it "assigns the requested delayed_job as @delayed_job" do
        job = Delayed::Job.create! valid_attributes
        put :update, {:id => job.to_param, :job => valid_attributes}, valid_session
        expect(assigns(:delayed_job)).to eq(job)
      end

      it "redirects to the delayed_job" do
        job = Delayed::Job.create! valid_attributes
        put :update, {:id => job.to_param, :job => valid_attributes}, valid_session
        expect(response).to have_http_status(:no_content)
      end
    end

    context "with invalid params" do
      it "assigns the delayed_job as @delayed_job" do
        job = Delayed::Job.create! valid_attributes
        put :update, {:id => job.to_param, :job => invalid_attributes}, valid_session
        expect(assigns(:delayed_job)).to eq(job)
      end

      it "re-renders the 'edit' template" do
        job = Delayed::Job.create! valid_attributes
        put :update, {:id => job.to_param, :job => invalid_attributes}, valid_session
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested delayed_job" do
      job = Delayed::Job.create! valid_attributes
      expect {
        delete :destroy, {:id => job.to_param}, valid_session
      }.to change(Delayed::Job, :count).by(-1)
    end

    it "redirects to the delayed_jobs list" do
      job = Delayed::Job.create! valid_attributes
      delete :destroy, {:id => job.to_param}, valid_session
      expect(response).to have_http_status(:no_content)
    end
  end

end
