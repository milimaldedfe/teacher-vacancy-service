require 'rails_helper'

RSpec.describe VacanciesController, type: :controller do
  describe 'sets headers' do
    it 'robots are asked to index but not to follow' do
      get :index
      expect(response.headers['X-Robots-Tag']).to eq('noarchive')
    end
  end

  describe '#index' do
    subject { get :index, params: params }

    context 'when parameters include syntax' do
      context 'search params' do
        let(:params) do
          {
            subject: "<body onload=alert('test1')>Text</body>",
            location: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>",
            minimum_salary: '<xml>Foo</xml',
            phases: ['<iframe>Foo</iframe>', 'Bar'],
            working_pattern: '<script>Foo</script>',
          }
        end

        it 'passes only safe values to VacancyFilters' do
          expected_safe_values = {
            'subject' => 'Text',
            'location' => '',
            'minimum_salary' => 'Foo',
            'phases' => '["", "Bar"]',
            'working_pattern' => ''
          }

          expect(VacancyFilters).to receive(:new)
            .with(expected_safe_values)
            .and_call_original

          subject
        end
      end

      context 'sort params' do
        let(:params) do
          {
            sort_column: "<body onload=alert('test1')>Text</script>",
            sort_order: '<xml>Foo</xml',
          }
        end
        it 'passes sanitised params to VacancySort' do
          expected_safe_values = {
            column: 'Text',
            order: 'Foo',
          }

          expect_any_instance_of(VacancySort).to receive(:update)
            .with(expected_safe_values)
            .and_call_original

          subject
        end
      end

      context 'search audiotor' do
        let(:params) do
          {
            subject: 'foo'
          }
        end

        it 'should call the search auditor' do
          expect(AuditSearchEventJob).to receive(:perform_later)

          subject
        end

        it 'should not call the search auditor if its a smoke test' do
          cookies[:smoke_test] = 1
          expect(AuditSearchEventJob).to_not receive(:perform_later)

          subject
        end

        it 'should not call the search auditor if no search parameters are given' do
          expect(AuditSearchEventJob).to_not receive(:perform_later)

          get :index
        end
      end
    end

    context 'feature flagging' do
      render_views

      context 'when the email alerts feature flag is set to true' do
        before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

        it 'shows the subscribe link' do
          get :index, params: { subject: 'English' }
          expect(response.body).to match(I18n.t('subscriptions.button'))
        end
      end

      context 'when the email alerts feature flag is set to false' do
        before { allow(EmailAlertsFeature).to receive(:enabled?) { false } }

        it 'does not show the subscribe link' do
          get :index, params: { subject: 'English' }
          expect(response.body).to_not match(I18n.t('subscriptions.button'))
        end
      end
    end
  end

  describe '#show' do
    subject { get :show, params: params }

    context 'when vacancy is trashed' do
      let(:vacancy) { create(:vacancy, :trashed) }
      let(:params) { { id: vacancy.id } }

      it 'renders errors/trashed_vacancy_found' do
        expect(subject).to render_template('errors/trashed_vacancy_found')
      end

      it 'returns not found' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when vacancy does not exist' do
      let(:params) { { id: 'missing-id' } }

      it 'renders errors/not_found' do
        expect(subject).to render_template('errors/not_found')
      end

      it 'returns not found' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when using cookies' do
      let(:vacancy) { create(:vacancy) }
      let(:params) { { id: vacancy.slug } }
      let(:vacancy_page_view) { instance_double(VacancyPageView) }

      it 'should call the track method if cookies not set' do
        expect(VacancyPageView).to receive(:new).with(vacancy).and_return(vacancy_page_view)
        expect(vacancy_page_view).to receive(:track)

        subject
      end

      it 'should not call the track method if smoke_test cookies set' do
        expect(VacancyPageView).not_to receive(:new).with(vacancy)
        cookies[:smoke_test] = '1'

        subject
      end
    end
  end
end
