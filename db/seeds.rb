raise if Rails.env.production?

require "faker"
require "factory_bot_rails"

school_one = FactoryBot.create(:school,
                               name: "Bexleyheath Academy",
                               urn: "137138",
                               phase: :secondary,
                               url: "http://www.bexleyheathacademy.org/",
                               minimum_age: 11,
                               maximum_age: 18,
                               address: "Woolwich Road",
                               town: "Bexleyheath",
                               county: "Kent",
                               postcode: "DA6 7DA",
                               region: "London",
                               easting: "549194",
                               northing: "175388",
                               geolocation: "(51.4578146490981,0.146065490118642)",
                               readable_phases: %w[secondary],
                               detailed_school_type: "Academy sponsor led",
                               school_type: "Academy",
                               gias_data: { 'ReligiousCharacter (name)': "None" })

school_two = FactoryBot.create(:school,
                               name: "Upton Cross ACE Academy",
                               urn: "144523",
                               phase: :primary,
                               url: "http://www.uptoncross.kernowlearning.co.uk",
                               minimum_age: 4,
                               maximum_age: 11,
                               address: "Upton Cross",
                               town: "Liskeard",
                               county: "Cornwall",
                               postcode: "PL14 5AX",
                               region: "London",
                               easting: "228041",
                               northing: "72116",
                               geolocation: "(50.52350433336815,-4.427269703777728)",
                               readable_phases: %w[primary],
                               detailed_school_type: "Academy converter",
                               school_type: "Academy",
                               gias_data: { 'ReligiousCharacter (name)': "None" })

trust_one = FactoryBot.create(:trust,
                              name: "Weydon Multi Academy Trust",
                              uid: "16644",
                              group_type: "Multi-academy trust",
                              address: "Weydon Lane",
                              town: "Farnham",
                              county: "Not recorded",
                              postcode: "GU9 8UG",
                              geolocation: "(51.2023732521965,0.814476304733643)")

local_authority_one = FactoryBot.create(:local_authority,
                                        name: "Southampton",
                                        local_authority_code: "852",
                                        group_type: "local_authority")

SchoolGroupMembership.create(school_group: trust_one, school: school_one)
SchoolGroupMembership.create(school_group: local_authority_one, school: school_two)

FactoryBot.create(:vacancy,
                  id: "20cc99ff-4fdb-4637-851a-68cf5f8fea9f",
                  job_title: "Physics Teacher",
                  subjects: %w[Physics],
                  working_patterns: %w[full_time],
                  salary: "£35,000",
                  organisation_vacancies_attributes: [{ organisation: school_one }])

FactoryBot.create(:vacancy,
                  id: "67991ea9-431d-4d9d-9c99-a78b80108fe1",
                  job_title: "Maths Teacher",
                  subjects: %w[Maths],
                  working_patterns: %w[part_time],
                  salary: "£35,000",
                  organisation_vacancies_attributes: [{ organisation: school_two }])

FactoryBot.create(:vacancy,
                  id: "9910d184-5686-4ffc-9322-69aa150c19d3",
                  job_title: "PE Teacher",
                  subjects: ["Physical Education"],
                  working_patterns: %w[full_time],
                  salary: "£30,000",
                  total_pageviews: 4,
                  total_get_more_info_clicks: 2,
                  organisation_vacancies_attributes: [{ organisation: school_one }])

FactoryBot.create(:vacancy,
                  id: "3bf67da6-039c-4ee1-bf59-8475672a0d2b",
                  job_title: "Chemistry Teacher",
                  subjects: %w[Chemistry],
                  working_patterns: %w[full_time part_time job_share],
                  salary: "£55,000",
                  organisation_vacancies_attributes: [{ organisation: school_two }])

FactoryBot.create(:vacancy,
                  id: "e750baf6-cc9a-4b93-84cf-ee4e5f8a7ee4",
                  job_title: "Geography Teacher",
                  subjects: %w[Geography],
                  working_patterns: %w[part_time job_share],
                  salary: "£25,000",
                  organisation_vacancies_attributes: [{ organisation: school_one }])

# pending vacancy
FactoryBot.create(:vacancy,
                  job_title: "Teacher of Drama",
                  subjects: %w[Drama],
                  salary: "£28,000",
                  publish_on: 1.month.from_now.to_date,
                  expires_on: 2.month.from_now.to_date,
                  starts_on: 3.month.from_now.to_date,
                  organisation_vacancies_attributes: [{ organisation: school_one }])

# expired vacancy
expired_one = FactoryBot.build(:vacancy,
                               job_title: "Subject lead in Art",
                               subjects: %w[Art],
                               working_patterns: %w[full_time part_time job_share],
                               salary: "£32,000",
                               publish_on: 5.days.ago.to_date,
                               expires_on: 2.days.ago.to_date,
                               organisation_vacancies_attributes: [{ organisation: school_one }])
expired_one.send :set_slug
expired_one.save(validate: false)

expired_two = FactoryBot.build(:vacancy,
                               job_title: "Subject lead in Drama",
                               subjects: %w[Drama],
                               working_patterns: %w[full_time part_time job_share],
                               salary: "£46,000",
                               publish_on: 5.days.ago.to_date,
                               expires_on: 2.days.ago.to_date,
                               organisation_vacancies_attributes: [{ organisation: school_one }])
expired_two.send :set_slug
expired_two.save(validate: false)

Vacancy.index.clear_index
Vacancy.reindex!

User.create(oid: "899808DB-9038-4779-A20A-9E47B9DB99F9",
            email: "alex.bowen@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Bowen",
            given_name: "Alex")

User.create(oid: "B553A9A4-869B-44FA-8146-D35657EAD590",
            email: "ben.mitchell@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Mitchell",
            given_name: "Ben")

User.create(oid: "ED61B414-EFE4-4B32-82BC-FC9751F8443B",
            email: "cesidio.dilanda@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Di Landa",
            given_name: "Cesidio")

User.create(oid: "5A21B414-EFE4-4B32-82BC-FC9751F841A5",
            email: "christian.sutter@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Sutter",
            given_name: "Christian")

User.create(oid: "A120A4FB-B773-4336-9BB5-CDBD1C977A2E",
            email: "chris.taylor@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Taylor",
            given_name: "Chris")

User.create(oid: "421542E6-ED96-4656-B61F-A06D8D487C07",
            email: "colin.saliceti@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Saliceti",
            given_name: "Colin")

User.create(oid: "897A6EE6-83D2-43F2-9E71-22B106541C94",
            email: "connor.mcquillan@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "McQuillan",
            given_name: "Connor")

User.create(oid: "B81FC38C-4122-4BCE-9F1D-8B1A328FA4D8",
            email: "david.mears@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Mears",
            given_name: "David")

User.create(oid: "DF97F25C-3A3E-4655-B7D3-5CDBDCBBBC69",
            email: "joseph.hull@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Hull",
            given_name: "Joseph")

User.create(oid: "CA300D6A-4FC1-4C1E-97E5-D6BD4FDB80D9",
            email: "judith.thrasher@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Thrasher",
            given_name: "Judith")

User.create(oid: "EC3312BA-E33B-4791-A815-4D1907DD578E",
            email: "mili.malde@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Malde",
            given_name: "Mili")

User.create(oid: "B5ECCE49-634C-4212-AC55-07F5C7BE74C2",
            email: "nick.romney@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Romney",
            given_name: "Nick")

User.create(oid: "7AEC8E8D-6036-4E6E-92A4-800E381A12E0",
            email: "valentine.carter@digital.education.gov.uk",
            dsi_data: { "school_urns" => %w[137138 144523], "trust_uids" => %w[16644], "la_codes" => %w[852] },
            family_name: "Carter",
            given_name: "Valentine")
