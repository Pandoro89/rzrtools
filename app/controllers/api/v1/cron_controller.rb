class Api::V1::CronController < Api::V1::BaseController

  def run
    pp params

    if params[:j] and params[:k] and params[:k] == 'vmEAzt6XmrOkT3sA'
      Resque.enqueue params[:j].constantize

      render(json: {}, status: 200)
    end

    render(json: {}, status: 403)
  end

end