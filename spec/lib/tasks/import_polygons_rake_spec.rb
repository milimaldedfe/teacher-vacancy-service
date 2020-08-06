RSpec.describe 'rake location_polygons:import_regions', type: :task do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'queues the import location polygons job' do
    expect { task.execute }.to have_enqueued_job(ImportAllLocationPolygonsJob)
  end
end
