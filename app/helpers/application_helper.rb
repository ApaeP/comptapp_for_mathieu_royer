module ApplicationHelper
  def confirmable_link_to(text, url, **attr)
    attr[:data] ||= {}
    attr[:controller] = attr[:data]&.delete(:controller)
    simple_form_for :link,
                    url: url,
                    data: {
                      controller: "alerts #{attr[:controller]}",
                      alerts_message_value: attr[:message]
                    }.merge(attr[:data]) do |f|
      f.submit text, class: "cursor-pointer #{attr[:klass]}"
    end
  end

  def human_price(price)
    humanized_money_with_symbol price
  end

  def human_percentage(percentage)
    "#{number_with_delimiter(percentage, locale: :fr, precision: 3)} %"
  end

  def money_sum(elements)
    humanized_money_with_symbol elements.sum(Money.new(0)) { |e| e.amount }
  end
end
