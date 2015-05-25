class DevController < ActionController::Base
  RAILS_BOOTED_AT = Time.zone.now

  http_basic_authenticate_with name: 'dev', password: 'ved'

  def self.route!
    Rails.application.routes.draw do
      match 'dev(/:action(/:id))', controller: 'dev', via: :all
    end
  end

  def index
    render json: JSON.pretty_generate(
      time: Time.zone.now,
      elapsed: (Time.zone.now - RAILS_BOOTED_AT).to_i,
      session: session.to_hash
    )
  end

  def form
    @model = DevModel.new(params[:dev_model])
    @model.validate if request.post?
  end
end

class DevModel
  include ActiveModel::Model

  attr_accessor :email, :message, :uf, :ativo, :sexo

  validates :email, presence: true

  def collection_for_sexo
    [['Masculino', 'M'], ['Feminino', 'F']]
  end
end
