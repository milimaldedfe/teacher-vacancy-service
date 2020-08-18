class BrowseComponent < ViewComponent::Base

  def initialize(selected_page:)
    @selected_page = selected_page&.to_sym
  end

  def get_vacancy_count
    '683'
  end
end
