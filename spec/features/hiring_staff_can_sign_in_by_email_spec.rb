require 'rails_helper'

RSpec.feature 'Hiring staff signing in with fallback email authentication' do
  let!(:school) { create(:school) }
  let!(:other_school) { create(:school) }

  let!(:user_dsi_data) do
    { 'school_urns'=>[school.urn, other_school.urn], 'school_group_uids'=>['3409', '1623'] }
  end

  let!(:user_dsi_data_with_single_school) do
    { 'school_urns'=>[school.urn], 'school_group_uids'=>[] }
  end

  let!(:user) { create(:user, dsi_data: user_dsi_data, accepted_terms_at: 1.day.ago) }

  let!(:user_with_single_school) do
    create(:user, dsi_data: user_dsi_data_with_single_school, accepted_terms_at: 1.day.ago)
  end
  
  let(:login_key) do
    user.emergency_login_keys.create(
      not_valid_after: Time.zone.now + HiringStaff::SignIn::Email::SessionsController::EMERGENCY_LOGIN_KEY_DURATION
    )
  end

  let(:login_key_2) do
    user.emergency_login_keys.create(
      not_valid_after: Time.zone.now + HiringStaff::SignIn::Email::SessionsController::EMERGENCY_LOGIN_KEY_DURATION
    )
  end

  before do
    allow(AuthenticationFallback).to receive(:enabled?) { true }
  end

  scenario 'can reach email request page by nav-bar link' do
    visit root_path

    within('.govuk-header__navigation.mobile-header-top-border') { click_on(I18n.t('nav.sign_in')) }
    expect(page).to have_content(I18n.t('hiring_staff.temp_login.heading'))
    expect(page).to have_content(I18n.t('hiring_staff.temp_login.please_use_email'))
  end

  scenario 'can reach email request page by sign in button' do
    visit root_path

    within('.signin') { click_on(I18n.t('sign_in.link')) }
    expect(page).to have_content(I18n.t('hiring_staff.temp_login.heading'))
    expect(page).to have_content(I18n.t('hiring_staff.temp_login.please_use_email'))
  end

  context 'user flow' do
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    context 'a user with multiple organisations' do
      before do
        allow_any_instance_of(HiringStaff::SignIn::Email::SessionsController)
          .to receive(:generate_login_key)
          .with(user: user)
          .and_return(login_key)
        allow(AuthenticationFallbackMailer).to receive(:sign_in_fallback)
          .with(login_key: login_key, email: user.email)
          .and_return(message_delivery)
      end

      scenario 'can sign in, choose an org, change org, sign out' do
        freeze_time do
          visit root_path
          click_sign_in

          # Expect to send an email
          expect(message_delivery).to receive(:deliver_later)

          fill_in 'user[email]', with: user.email
          click_on 'commit'
          expect(page).to have_content(I18n.t('hiring_staff.temp_login.check_your_email.sent'))

          # Expect that the link in the email goes to the landing page
          visit auth_email_choose_organisation_path(login_key: login_key.id)

          expect(page).to have_content('Choose your organisation')
          expect(page).not_to have_content(I18n.t('hiring_staff.temp_login.denial.title'))
          expect(page).to have_content(other_school.name)
          click_on school.name

          expect(page).to have_content("Jobs at #{school.name}")
          expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound

          # Can switch organisations
          allow_any_instance_of(HiringStaff::SignIn::Email::SessionsController)
            .to receive(:generate_login_key)
            .with(user: user)
            .and_return(login_key_2)
          click_on I18n.t('sign_in.organisation.change')
          click_on(other_school.name)
          expect(page).to have_content("Jobs at #{other_school.name}")
          expect { login_key_2.reload }.to raise_error ActiveRecord::RecordNotFound

          # Can sign out
          click_on(I18n.t('nav.sign_out'))

          within('.govuk-header__navigation') { expect(page).to have_content(I18n.t('nav.sign_in')) }
          expect(page).to have_content(I18n.t('messages.access.signed_out'))

          # Login link no longer works
          visit auth_email_choose_organisation_path(login_key: login_key.id)
          expect(page).to have_content('used')
          expect(page).not_to have_content('Choose your organisation')
        end
      end

      scenario 'cannot sign in if key has expired' do
        visit new_identifications_path
        fill_in 'user[email]', with: user.email
        expect(message_delivery).to receive(:deliver_later)
        click_on 'commit'
        travel 5.hours do
          visit auth_email_choose_organisation_path(login_key: login_key.id)
          expect(page).to have_content('expired')
          expect(page).not_to have_content('Choose your organisation')
        end
      end
    end

    context 'a user with only one organisation' do
      let(:login_key_3) do
        user_with_single_school.emergency_login_keys.create(
          not_valid_after: Time.zone.now + HiringStaff::SignIn::Email::SessionsController::EMERGENCY_LOGIN_KEY_DURATION
        )
      end

      before do
        allow_any_instance_of(HiringStaff::SignIn::Email::SessionsController)
          .to receive(:generate_login_key)
          .with(user: user_with_single_school)
          .and_return(login_key_3)
        allow(AuthenticationFallbackMailer).to receive(:sign_in_fallback)
          .with(login_key: login_key_3, email: user_with_single_school.email)
          .and_return(message_delivery)
      end

      scenario 'can sign in and bypass choice of org' do
        freeze_time do
          visit root_path
          click_sign_in

          # Expect to send an email
          expect(message_delivery).to receive(:deliver_later)

          fill_in 'user[email]', with: user_with_single_school.email
          click_on 'commit'
          expect(page).to have_content(I18n.t('hiring_staff.temp_login.check_your_email.sent'))

          # Expect that the link in the email goes to the landing page
          visit auth_email_choose_organisation_path(login_key: login_key_3.id)

          expect(page).not_to have_content('Choose your organisation')
          expect(page).to have_content("Jobs at #{school.name}")
          expect { login_key_3.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end

  private

  def click_sign_in
    within('.signin') { click_on(I18n.t('sign_in.link')) }
  end
end
