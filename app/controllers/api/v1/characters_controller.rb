class Api::V1::CharactersController < Api::V1::BaseController

  def index
    render(json: [], status: 200)
  end

  def create
    params[:characters].each do |c|
      create_from_razor_smf(c[:char_id], c[:char_name], c[:main_id], c[:main_name])
    end

    render(json: {}, status: 200)
  end

  def show
    character = Character.find(params[:id])

    render(json: Api::V1::CharacterSerializer.new(character).to_json)
  end
end