class PagesController < ApplicationController
  include HighVoltage::StaticPage

  def home
    @jobs_search_form = VacancyAlgoliaSearchForm.new(params)
    @selected_page = params[:page]
    @selected_component = params[:component]

    @counties = LocationCategory.counties
    @cities_primary = LocationCategory.cities_primary
    @cities_secondary = LocationCategory.cities_secondary
    @regions = LocationCategory.regions
  end

  def invalid_page
    redirect_to '/404'
  end

  def set_headers
    true

    # return super if root_path? || page_path.include?('user-not-authorised') || page_path.include?('home')

    # response.set_header('X-Robots-Tag', 'index, nofollow')
  end

  def root_path?
    request.path == root_path
  end

  private
end
