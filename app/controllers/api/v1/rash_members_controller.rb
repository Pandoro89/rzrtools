class Api::V1::RashMemebersController < Api::V1::BaseController

  before_action :authenticate_by_user

  def index
    return render(json: [], status: 200) if !@current_user

    rash = RashMember.where(:user_id => @current_id.id).first

    render(json: rash.to_json)
  end

  def report
    if params[:account_name] and params[:data]
      notifier = Slack::Notifier.new RASH_CHANNEL, channel: '#rash', username: 'Razor Bot'

      notifier.ping(params[:data])
    end

    render(json: {}, status: 200)
  end

end