require 'rails_helper'

RSpec.feature "USER views other user profile", type: :feature do
  let!(:user_unauthorized) { FactoryBot.create :user }

  let(:user_authorized) { FactoryBot.create :user }

  let!(:game1) {
    FactoryBot.create :game_with_questions,
    user: user_unauthorized,
    current_level: 15,
    finished_at: "2020-11-14 00:10:26",
    fifty_fifty_used: true,
    audience_help_used: true,
    friend_call_used: false,
    prize: 1000000
  }

  let!(:game2) {
    FactoryBot.create :game_with_questions,
    user: user_unauthorized,
    current_level: 1,
    finished_at: "2020-11-23 20:54:01",
    fifty_fifty_used: false,
    audience_help_used: false,
    friend_call_used: false,
    is_failed: true
  }

  let!(:game3) {
    FactoryBot.create :game_with_questions,
    user: user_unauthorized,
    current_level: 5
  }

  before(:each) do
    login_as user_authorized
  end

  scenario 'successfully' do
    visit '/'

    click_link "#{user_unauthorized.name}"

    expect(page).to have_current_path "/users/#{user_unauthorized.id}"

    expect(page).to have_selector :table

    save_and_open_page

    # expect(page).to have_current_path '/games/1'
  end
end
