class Api::V1::RashMembersController < Api::V1::BaseController

  before_action :authenticate_by_user

  def index
    return render(json: [], status: 403) if @current_user.nil?

    rash = RashMember.where(:user_id => @current_user.id).first

    render(json: rash.to_json)
  end

  def report
    return render(json: [], status: 403) if @current_user.nil?

    if params[:account_string] and params[:data]
      logger.debug(RASH_CHANNEL)
      notifier = Slack::Notifier.new RASH_CHANNEL, channel: '#rash', username: 'Razor Bot'

      notifier.ping(params[:data])
    end

    render(json: {}, status: 200)
  end

end