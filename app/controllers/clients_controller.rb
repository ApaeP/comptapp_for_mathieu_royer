class ClientsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ home ]
  before_action :set_client, only: %i[ edit update destroy ]

  def index
    @clients = current_user.clients.includes(:invoices, logo_attachment: :blob)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    @client.user = current_user

    respond_to do |format|
      if @client.save
        flash[:success] = "#{@client.name} has been succesfully created"
        format.turbo_stream
        format.html { redirect_to clients_path, notice: "Client was successfully created." }
      else
        flash[:success] = "#{@client.name} wasn't created"
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      flash[:success] = "#{@client.name} has been succesfully updated"
      render :edit
    else
      flash[:warning] = "#{@client.name} was not updated (#{@client.errors.full_messages.join(', ')})"
      redirect_to request.referer
    end
  end

  def destroy
    if @client.destroy
      flash[:success] = "#{@client.name} has been succesfully destroyed"
      redirect_to request.referer
    else
      flash[:warning] = "#{@client.name} was not destroyed (#{@client.errors.full_messages.join(', ')})"
      redirect_to request.referer
    end
  end

  private

  def client_params
    params.require(:client).permit(:name, :address, :country, :rcs, :siret, :logo)
  end

  def set_client
    @client = Client.find(params[:id])
  end
end
