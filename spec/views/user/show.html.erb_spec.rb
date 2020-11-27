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

      stub_template("users/_game.html.erb" => "User game goes here")

      render
    end

    it 'renders player names' do
      expect(rendered).to match 'Вадик'
    end

    it 'user can see link to change pass' do
      expect(rendered).to have_link('Сменить имя и пароль', href: '/users/edit.10')
    end

    it 'shows games list' do
      expect(rendered).to match 'User game goes here'
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

      render
    end

    it 'renders player names' do
      expect(rendered).to match 'Вадик'
    end

    it 'checks that other user cant see link to change pass' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end
  end
end
