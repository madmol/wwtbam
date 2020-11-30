require 'rails_helper'

RSpec.feature "USER views other user profile", type: :feature do
  let!(:user_games_owner) { FactoryBot.create :user }

  let(:user) { FactoryBot.create :user }

  let!(:game1) {
    FactoryBot.create :game_with_questions,
    user: user_games_owner,
    current_level: 15,
    finished_at: "2020-11-14 00:10:26",
    fifty_fifty_used: true,
    audience_help_used: true,
    friend_call_used: false,
    prize: 1000000
  }

  let!(:game2) {
    FactoryBot.create :game_with_questions,
    user: user_games_owner,
    current_level: 1,
    finished_at: "2020-11-23 20:54:01",
    fifty_fifty_used: false,
    audience_help_used: false,
    friend_call_used: false,
    is_failed: true
  }

  let!(:game3) {
    FactoryBot.create :game_with_questions,
    user: user_games_owner,
    current_level: 5
  }

  scenario 'successfully and user views other user profile' do
    login_as user

    visit '/'

    click_link "#{user_games_owner.name}"

    expect(page).to have_current_path "/users/#{user_games_owner.id}"
    expect(page).to have_no_selector(:link_or_button, 'Сменить имя и пароль')

    expect(page).to have_selector :table

    user_games_owner.games.each do |game|
      expect(page).to have_content game.id
      expect(page).to have_content I18n.l(game.created_at, format: :short)
      expect(page).to have_content game.current_level
      expect(page).to have_content number_to_currency game.prize
      expect(page).to have_content case game.status
                                   when :won
                                     I18n.t('game_statuses.won')
                                   when :fail
                                     I18n.t('game_statuses.fail')
                                   when :in_progress
                                     I18n.t('game_statuses.in_progress')
                                   end
      expect(page).to have_content '50/50'
      expect(page).to have_css(".fa.fa-phone")
      expect(page).to have_css(".fa.fa-users")

      expect(page).to have_content '#'
      expect(page).to have_content 'Дата'
      expect(page).to have_content 'Вопрос'
      expect(page).to have_content 'Выигрыш'
      expect(page).to have_content 'Подсказки'
    end
  end

  scenario 'successfully and user views his own profile' do
    login_as user_games_owner

    visit '/'

    click_link "#{user_games_owner.name}"

    expect(page).to have_current_path "/users/#{user_games_owner.id}"
    expect(page).to have_selector(:link_or_button, 'Сменить имя и пароль')

    expect(page).to have_selector :table

    user_games_owner.games.each do |game|
      expect(page).to have_content game.id
      expect(page).to have_content I18n.l(game.created_at, format: :short)
      expect(page).to have_content game.current_level
      expect(page).to have_content number_to_currency game.prize
      expect(page).to have_content case game.status
                                   when :won
                                     I18n.t('game_statuses.won')
                                   when :fail
                                     I18n.t('game_statuses.fail')
                                   when :in_progress
                                     I18n.t('game_statuses.in_progress')
                                   end
      expect(page).to have_content '50/50'
      expect(page).to have_css(".fa.fa-phone")
      expect(page).to have_css(".fa.fa-users")

      expect(page).to have_content '#'
      expect(page).to have_content 'Дата'
      expect(page).to have_content 'Вопрос'
      expect(page).to have_content 'Выигрыш'
      expect(page).to have_content 'Подсказки'
    end
  end
end
