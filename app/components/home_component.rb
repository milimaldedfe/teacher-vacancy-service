class HomeComponent < ViewComponent::Base

  def initialize(selected_page:, selected_component:)
    @selected_page = selected_page
    @selected_component = selected_component
  end

  def selected_class(page_type)
    'govuk-tabs__list-item--selected' if @selected_page == page_type
  end
end
