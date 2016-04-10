class Api::V1::RashMembersController < Api::V1::BaseController

  before_action :authenticate_by_user

  def index
    return render(json: [], status: 403) if @current_user.nil?

    rash = RashMember.where(:user_id => @current_user.id).first

    render(json: rash.to_json)
  end

  def report
    return render(json: [], status: 403) if @current_user.nil?

    rash = RashMember.where(:user_id => @current_user.id).first

    if params[:bot_name] and params[:data]
      

      mark_data = ReverseMarkdown.convert(params[:data].gsub(/<font(.*)">/,'').gsub("</font>",''))

      logger.debug("-- #{RASH_CHANNEL} :: #{params[:data]} :: #{mark_data}")

      notifier = Slack::Notifier.new RASH_CHANNEL, channel: '#rash', username: 'Razor Bot'

      a_ok_note = {
        fallback: params[:data],
        text: mark_data,
        mrkdwn_in: ["text"]
      }

      RashHistory.create(:user_id => @current_user.id, :rash_member_id => rash.id, :bot => params[:bot_name], :message => params[:data], :message_markdown => mark_data)

      if rash.irc? and rash.irc_filter and params[:data] =~ Regexp.union(rash.irc_filter.split("|"))
        notifier.ping(params[:bot_name], attachments: [a_ok_note])
      elsif !rash.irc?
        notifier.ping(params[:bot_name], attachments: [a_ok_note])
      end
    end

    render(json: {}, status: 200)
  end

end