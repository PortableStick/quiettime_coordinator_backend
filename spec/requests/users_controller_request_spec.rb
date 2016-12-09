require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let!(:user) { create(:user) }
  let(:jwt) { JWT.encode({ user: user.id }, Rails.application.secrets.secret_key_base, 'HS256') }
  let(:headers) { { authorization: jwt } }

  describe "POST create" do
    let(:create_params) { { user: { username: "dog1", email: "dog@dogville.com", password: "supercanineman", password_confirmation: "supercanineman" } } }
    let(:invalid_create_params) { { user: { username: "dog1", email: "dog@dogville.com", password: "dirk", password_confirmation: "dirk" } } }

    def post_create
      post api_v1_users_path, params: create_params
    end

    def invalid_create
      post api_v1_users_path, params: invalid_create_params
    end

    context "on successful creation of user" do
      it "returns a status of 201" do
        post_create
        expect(response.status).to eq(201)
      end

      it "returns a success message with a JWT" do
        allow(User).to receive(:create).and_return user
        post_create
        expect(response.body).to eq({message: "User successfully created", user: user, jwt: jwt }.to_json)
      end
    end

    context "on user validation failure" do
      it "returns a status of 400" do
        invalid_create
        expect(response.status).to be(400)
      end

      it "returns a message with the validation error" do
        invalid_create
        expect(response.body).to eq({ message: "User could not be created", error: { password_confirmation: [ "is too short (minimum is 8 characters)" ] } }.to_json)
      end
    end
  end

  describe "PATCH update" do
    context "on successful update" do
      let(:update_params) { { update: { username: "dagdirkwood", email: "2@981273.com", password: "fartknockingbooshboosh", password_confirmation: "fartknockingbooshboosh" } } }
      let(:updated_user) { build(:user, id: 1, username: "dagdirkwood", email: "2@981273.com", password: "fartknockingbooshboosh", password_confirmation: "fartknockingbooshboosh") }

      def valid_update
        patch api_v1_user_path(user.id), params: update_params, headers: headers
      end

      it "returns a 202 status" do
        valid_update
        expect(response.status).to eq(202)
      end

      it "returns a success message with the user's new parameters" do
        allow(User).to receive(:find).and_return(updated_user)
        valid_update
        expect(response.body).to eq({ message: "User successfully updated", user: updated_user }.to_json)
      end
      context "could not find user" do
        def bad_update
          patch api_v1_user_path("dog"), params: update_params, headers: headers
        end

        it "returns a 404 status" do
          bad_update
          expect(response.status).to eq(404)
        end

        it "returns an error message" do
          bad_update
          expect(response.body).to eq({ message: "User could not be found" }.to_json)
        end
      end
    end
  end

  describe "DELETE destroy" do
    context "with a valid user id" do
      def delete_destroy
        delete api_v1_user_path(user.id), headers: headers
      end

      it "returns a 200 status" do
        delete_destroy
        expect(response.status).to eq(200)
      end

      it "returns a success message" do
        delete_destroy
        expect(response.body).to eq({ message: "User successfully deleted" }.to_json)
      end
    end

    context "with an invalid user id" do
      def invalid_delete_destroy
        delete api_v1_user_path("dog"), headers: headers
      end

      it "returns a 404 status" do
        invalid_delete_destroy
        expect(response.status).to eq(404)
      end

      it "returns an error message" do
        invalid_delete_destroy
        expect(response.body).to eq({ message: "User could not be found" }.to_json)
      end
    end
  end
end