require 'rails_helper'

# Тест на шаблон users/show.html.erb

RSpec.describe 'users/show', type: :view do
  context 'user = current_user' do
    before(:each) do
      user = assign(:user, FactoryBot.build_stubbed(
        :user,
        id: 10,
        name: 'Вадик',
        balance: 5000
        )
      )
      allow(view).to receive(:current_user) { user }

      assign(:games, [
        double(:name => "First game"),
        double(:name => "Second game")
      ])

      stub_template("users/_game.html.erb" => "<%= game.name %>")

      render
    end

    it 'renders player names' do
      expect(rendered).to match 'Вадик'
    end

    it 'users can see link to change pass' do
      expect(rendered).to have_link('Сменить имя и пароль', href: '/users/edit.10')
    end

    it "shows user's games list" do
      expect(rendered).to match /First game/
      expect(rendered).to match /Second game/
    end
  end

  context 'user != current_user' do
    before(:each) do
      assign(:user, FactoryBot.build_stubbed(
        :user,
        id: 1,
        name: 'Вадик',
        balance: 5000
        )
      )

      allow(view).to receive(:current_user) {
        assign(
          :user, FactoryBot.build_stubbed(
            :user,
            id: 2,
            name: 'Михаил',
            balance: 25000
          )
        )
      }

      assign(:games, [
        double(:name => "First game"),
        double(:name => "Second game")
      ])

      stub_template("users/_game.html.erb" => "<%= game.name %>")

      render
    end

    it 'renders player names' do
      expect(rendered).to match 'Вадик'
    end

    it 'checks that other users cant see link to change pass' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end

    it "shows user's games list" do
      expect(rendered).to match /First game/
      expect(rendered).to match /Second game/
    end
  end
end
