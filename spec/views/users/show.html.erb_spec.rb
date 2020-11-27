require 'rails_helper'

# Тест на шаблон users/show.html.erb

RSpec.describe 'users/show', type: :view do
  let(:user) { FactoryBot.create(:user, name: 'Вадик', id: 10) }

  before(:each) do
    assign(:user, user)

    assign(:games, [
      double(name: "First game"),
      double(name: "Second game")
    ])

    stub_template("users/_game.html.erb" => "<%= game.name %>")
  end

  context 'user != current user' do
    before(:each) { render }

    it 'renders player names' do
      expect(rendered).to match 'Вадик'
    end

    it "shows user's games list" do
      expect(rendered).to match /First game/
      expect(rendered).to match /Second game/
    end

    it 'renders player names' do
      expect(rendered).to match 'Вадик'
    end

    it 'checks that other users cant see link to change pass' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end
  end

  context 'user == current_user' do
    before(:each) do
      sign_in user
      render
    end

    it 'users can see link to change pass' do
      expect(rendered).to have_link('Сменить имя и пароль', href: '/users/edit.10')
    end
  end
end
