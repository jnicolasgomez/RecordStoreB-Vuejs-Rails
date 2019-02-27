class SigninController < ApplicationController
    before_action :authorize_access_request!, only: [:destroy]

    def create
        user = User.fin_by(email: params[:email])

        if user.authenticate(params[:password])
            payload = {user_id: user.id}
            session = JWTSession::Session.new(payload: payload, refresh_by_access_allowed: true)
            tokens = session.login
            response.set_cookie(JWTSessions.acces_cookie,
                                    value: tokens[:access],
                                    httponly: true,
                                    secure: Rails.env.production?)
            render json {crsf: tokens[:csrf]}
        else
            not_authorized
        end
    end

    def destroy
        session = JWTSession.new(payload: payload)
        session.flush_by_by_access_payload
        render json: :ok

    end

    private

        def not_found
            render json: {error: "Cannot find email/password combination"}, status: :not_found
        end
end