class PdfGenerator
  include MoneyRails::ActionViewExtension
  require 'open-uri'
  require "prawn/measurement_extensions"

  def self.call(invoice)
    new(invoice).generate!
  end

  def initialize(invoice)
    @invoice       = invoice
    @user          = invoice.user
    @client        = invoice.client
    @invoice_items = invoice.invoice_items
    set_pdf_values
  end

  def generate!
    Prawn::Document.new({
                         page_layout: @layout,
                         left_margin: @margin_left,
                         right_margin:@margin_right,
                         top_margin: @margin_top,
                         bottom_margin: @margin_bottom,
                         page_size: @page_size }) do |pdf|
     pdf.font_families.clear
     pdf.font_families.update(
       "Source Sans Pro" => {
        extra_light:        Rails.root.join("lib/assets/fonts/SourceSansPro-ExtraLightItalic.ttf"),
        extra_light_italic: Rails.root.join("lib/assets/fonts/SourceSansPro-ExtraLight.ttf"),
        light:              Rails.root.join("lib/assets/fonts/SourceSansPro-Light.ttf"),
        light_italic:       Rails.root.join("lib/assets/fonts/SourceSansPro-LightItalic.ttf"),
        normal:             Rails.root.join("lib/assets/fonts/SourceSansPro-Regular.ttf"),
        italic:             Rails.root.join("lib/assets/fonts/SourceSansPro-Italic.ttf"),
        semibold:           Rails.root.join("lib/assets/fonts/SourceSansPro-SemiBold.ttf"),
        semibold_italic:    Rails.root.join("lib/assets/fonts/SourceSansPro-SemiBoldItalic.ttf"),
        bold:               Rails.root.join("lib/assets/fonts/SourceSansPro-Bold.ttf"),
        bold_italic:        Rails.root.join("lib/assets/fonts/SourceSansPro-BoldItalic.ttf"),
        black:              Rails.root.join("lib/assets/fonts/SourceSansPro-Black.ttf"),
        black_italic:       Rails.root.join("lib/assets/fonts/SourceSansPro-BlackItalic.ttf")
      })
      @pdf = pdf
      calculate_borders
      @last_measured_y = @pdf.cursor
      paint
      add_logo
      @pdf.move_down @initialmove_y
      set_font_style
      print_user_infos
      @pdf.move_cursor_to @last_measured_y
      @pdf.move_down 65
      @last_measured_y = @pdf.cursor
      print_client_info
      @pdf.move_cursor_to @last_measured_y
      separator(y_pos: 185.mm)
      @pdf.move_down 45
      print_invoice_description
      @pdf.move_down 12
      print_invoice_items_table
      separator(y_pos: @pdf.cursor - 12.mm)
      @pdf.move_down 12
      @pdf.move_down 70
      print_invoice_payment_info
      @pdf.move_down 70
    end.render
  end

  private

  def paint
    @pdf.canvas do
      @pdf.fill_color @invoice.rand_color
      @pdf.fill_polygon [@pdf.bounds.left, @pdf.bounds.top], [@pdf.bounds.left + 9.cm, @pdf.bounds.top], [@pdf.bounds.left, @pdf.bounds.top - 9.cm]
    end
    @pdf.fill_color '000000'
  end

  def add_logo
    @pdf.image URI.open(@logopath), width: 80, height: 80, at: [1.5.cm - @margin_left, 25.cm + @margin_top]
  end

  def set_pdf_values
    @layout           = :portrait
    @page_size        = 'A4'
    @margin_left      = 50.mm
    @margin_right     = 15.mm
    @margin_top       = 20.mm
    @margin_bottom    = 10.mm
    @logopath         = @user.logo.url || "#{Rails.root}/app/assets/images/logo_alpha0.png"
    @initial_y        = 50
    @initialmove_y    = 5
    @address_x        = 35
    @invoice_header_x = 32
    @lineheight_y     = 12
    @font_size        = 8
  end

  def calculate_borders
    @top_border       = @pdf.bounds.top_left.last + @margin_top
    @left_border      = -@margin_left
    @right_border     = @pdf.bounds.top_right.first + @margin_right
    @bottom_border    = -@margin_bottom
  end

  def set_font_style
    @pdf.font 'Source Sans Pro'
    @pdf.font_size @font_size
  end

  def print_user_infos
    height = 25.mm
    y_position = height
    @pdf.bounding_box([0.cm,  225.mm], width: 5.cm, height: height) do
      y_position -= 3.mm
      @pdf.draw_text @user.full_name, at: [0.cm, y_position], size: 9

      y_position -= 5.mm
      @user.business_address.lines.each_with_index do |line, index|
        y_position -= 4.5.mm * index
        @pdf.draw_text line, at: [0, y_position], style: :light
      end

      y_position -= 4.5.mm
      @pdf.draw_text @user.business_country, at: [0, y_position], style: :light

      y_position -= 4.5.mm
      @pdf.draw_text @user.siret, at: [0, y_position], style: :light
    end
  end

  def print_client_info
    height = 25.mm
    y_position = height
    @pdf.bounding_box([8.cm, 225.mm], width: 5.cm, height: height) do
      y_position -= 3.mm
      @pdf.draw_text @client.name, at: [0.cm, y_position], size: 9

      y_position -= 5.mm
      @client.address.lines.each_with_index do |line, index|
        y_position -= 4.5.mm * index
        @pdf.draw_text line, at: [0, y_position], style: :light
      end

      y_position -= 4.5.mm
      @pdf.draw_text @client.country, at: [0, y_position], style: :light

      if @client.siret.present?
        y_position -= 4.5.mm
        @pdf.draw_text @client.siret, at: [0, y_position], style: :light
      end

      if @client.rcs.present?
        y_position -= 4.5.mm
        @pdf.draw_text @client.rcs, at: [0, y_position], style: :light
      end
    end
  end

  def separator(width: 320, y_pos: 0.mm)
    stroke_start = (@pdf.bounds.width - width).fdiv(2)
    stroke_end = @pdf.bounds.width - stroke_start
    @pdf.stroke do
      @pdf.stroke_color 100, 100, 100, 0.5
      @pdf.line_width = 0.1
      @pdf.horizontal_line stroke_start, stroke_end, at: y_pos
    end
  end

  def print_invoice_description
    @pdf.move_down 55.mm
    @pdf.text_box @invoice.name, at: [0, @pdf.cursor]
    @pdf.text_box I18n::l(@invoice.created_at, format: '%d %B %Y' ), at: [0, @pdf.cursor], align: :right
    @pdf.move_down 6.mm
    @pdf.text_box @invoice.description, at: [0, @pdf.cursor]
  end

  def get_invoice_items_data
    @invoice.invoice_items.map { |e| [e.name, e.quantity, e.unit_price.to_i, "#{e.vat_rate} %", humanized_money_with_symbol(e.amount_without_vat)] }
    .prepend(["Détail", "Quantité", "Prix unitaire", "TVA", "Total HT"])
    .append(
      [ {content: "", colspan: 3}, "Sous-total HT", humanized_money_with_symbol(@invoice.amount_without_vat)],
      [ {content: "", colspan: 3}, "TVA", humanized_money_with_symbol(@invoice.vat_amount) ],
      [ {content: "", colspan: 3}, "TOTAL TTC", humanized_money_with_symbol(@invoice.amount)],
      [ {content: @invoice.subject_to_vat ? "" : "TVA non applicable, article 293B du CGI", colspan: 5} ])
  end

  def print_invoice_items_table
    @pdf.move_down 2.mm
    @pdf.table(get_invoice_items_data, width: @pdf.bounds.width) do
      style(row(1..-1).columns(0..-1), padding: [1, 1], borders: [], size: 7)
      style(row(0), border_color: '444444', padding: [6, 1], font_style: :light, border_width: 0.5)
      style(row(0).columns(0..-1), borders: [:top, :bottom])
      style(row(1), padding: [4, 1, 1, 1])
      style(row(-1), border_width: 2)
      style(column(1..-1), align: :right)
      style(row(1..-5), height: 4.5.mm)

      style(row(-5), height: 10.mm)
      style(row(-4), height: 5.mm, font_style: :light)
      style(row(-3), height: 8.mm, font_style: :light)
      style(row(-2), height: 4.mm, size: 8, font_style: :semibold)
      style(row(-4..-1).columns(0..-2), align: :left)
      style(row(-1), align: :right, size: 5)
    end
  end

  def print_invoice_payment_info
    invoice_payment_info = [
      ["IBAN", @user.iban],
      ["BIC", @user.bic]
    ]

    @pdf.table(invoice_payment_info) do
      style(column(0), padding: [2, 0], borders: [], align: :left, font_style: :light)
      style(column(1), padding: [2, 5.mm], borders: [], align: :right)
    end
  end

  # def print_invoice_notes
  #   note = "M. #{@user.full_name} a émis cette facture le #{I18n::l(@invoice.created_at, format: '%d %B %Y')}.\n
  #       Celle-ci doit être réglée sous 30 jours à compter de cette date\n
  #       Pas d’escompte pour règlement anticipé"

  #   note.lines.each do |line|
  #     @pdf.text_box line, at: [@address_x,  @pdf.cursor], align: :center, size: 7
  #     @pdf.move_down 4
  #   end
  # end
end
