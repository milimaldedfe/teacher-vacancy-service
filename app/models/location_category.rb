class LocationCategory
  class << self
    OUT_OF_SCOPE_REGIONS = ['Wales (pseudo)', 'Not Applicable']
    LONDON_REGION = 'London'
    OUT_OF_SCOPE_COUNTIES = ['Powys', 'Blaenau Gwent']

    def include?(location)
      ALL_LOCATION_CATEGORIES.include?(location.downcase)
    end

    def export
      base_path = Rails.root.join('lib/tasks/data')

      %w[regions counties boroughs].each do |location_category|
        file_path = base_path.join("#{location_category}.yml")

        File.write(file_path, public_send(location_category).to_yaml)
      end
    end

    def regions
      Region.where.not(name: OUT_OF_SCOPE_REGIONS)
            .limit(20)
            .pluck(:name)
    end

    def boroughs
      School.joins(:region)
            .where(regions: { name: LONDON_REGION })
            .group(:local_authority)
            .order(:local_authority)
            .pluck(:local_authority)
    end

    def counties
      School.joins(:region)
            .where.not(regions: { name: OUT_OF_SCOPE_REGIONS + [LONDON_REGION] })
            .where.not(county: OUT_OF_SCOPE_COUNTIES)
            .group(:county)
            .order('COUNT(*) DESC')
            .order(:county)
            .limit(20)
            .pluck(:county)
    end

    def cities_primary
      School.joins(:region)
            .where.not(regions: { name: OUT_OF_SCOPE_REGIONS + [LONDON_REGION] })
            .where.not(county: OUT_OF_SCOPE_COUNTIES)
            .group(:town)
            .order('COUNT(*) DESC')
            .order(:town)
            .limit(20)
            .pluck(:town)
    end

    def cities_secondary
      School.joins(:region)
            .where.not(regions: { name: OUT_OF_SCOPE_REGIONS + [LONDON_REGION] })
            .where.not(county: OUT_OF_SCOPE_COUNTIES)
            .group(:town)
            .order('COUNT(*) DESC')
            .order(:town)
            .offset(20)
            .limit(20)
            .pluck(:town)
    end
  end
end
