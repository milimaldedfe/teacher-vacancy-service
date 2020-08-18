class SearchComponent < ViewComponent::Base

  def initialize(selected_page:)
    @selected_page = selected_page&.to_sym
  end
end
