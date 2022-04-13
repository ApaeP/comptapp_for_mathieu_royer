class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[ show destroy pdf mark_as_paid mark_as_unpaid ]
  before_action :set_invoice_item_names, only: %i[ new ]

  def index
    @invoices_by_year = current_user.invoices.includes(:invoice_items, :client).group_by(&:year)
    @invoice = Invoice.new
  end

  def show
    @client = @invoice.client
    @user = @invoice.user
  end

  def new
    @invoice = Invoice.new
    @clients = current_user.clients
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.user = current_user

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to invoice_url(@invoice), notice: "invoice was successfully created." }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @invoice.destroy
        format.html { redirect_to request.referer, notice: "invoice was successfully deleted." }
        format.json { render :index, status: :destroyed }
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def pdf
    send_data(PdfGenerator.call(@invoice), filename: "#{@invoice.name}.pdf", type: "application/pdf")
  end

  def mark_as_paid
    @invoice.paid!
    redirect_to request.referer
  end

  def mark_as_unpaid
    @invoice.unpaid!
    redirect_to request.referer
  end

  private

  def invoice_params
    params.require(:invoice).permit(
      :description,
      :client_id,
      invoice_items_attributes: [
        :id,
        :name,
        :unit_price,
        :quantity,
        :_destroy
      ]
    )
  end

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def set_invoice_item_names
    @invoice_item_names = InvoiceItem.joins(invoice: :user).where(users: { id: current_user.id }).pluck(:name).uniq
  end
end
