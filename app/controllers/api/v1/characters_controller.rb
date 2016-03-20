class Api::V1::CharactersController < Api::V1::BaseController

  before_action :authenticate_by_key

  def index
    render(json: [], status: 200)
  end

  def create
    params[:characters].each do |c|
      Character.create_from_razor_smf(c[:char_id], c[:char_name], c[:main_id], c[:main_name])
    end

    render(json: {}, status: 200)
  end

  def show
    character = Character.find(params[:id])

    render(json: character.to_json)
  end
end