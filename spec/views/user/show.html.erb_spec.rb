require 'rails_helper'

# Тест на шаблон users/show.html.erb

RSpec.describe 'users/show', type: :view do
  # Перед каждым шагом мы пропишем в переменную @users пару пользователей
  # как бы имитируя действие контроллера, который эти данные будет брать из базы
  # Обратите внимание, что мы объекты в базу не кладем, т.к. пишем FactoryBot.build_stubbed

  before(:each) do
    user = assign(:user, FactoryBot.build_stubbed(:user, id: 1, name: 'Вадик', balance: 5000))
    allow(view).to receive(:current_user) { user }
    # @user = users[0]
    # game = assigns(:game)
    render
  end
  # Проверяем, что шаблон выводит имена игроков

  it 'renders player names' do
    expect(rendered).to match 'Вадик'
    # expect(rendered).to match 'Миша'
  end

  it 'checks that other user cant see link to change pass' do
    user = assign(:user, FactoryBot.build_stubbed(:user, id: 2, name: 'Миша', balance: 35000))
    allow(view).to receive(:current_user) { user }
    expect(rendered).to match 'Сменить имя и пароль'
    # before do
    #   allow(view).to receive(:admin?).and_return(true)
    # end
    # current_user = user[0]
    # expect(rendered).not_to match 'Вадик'
    # response.body.match have_no_content("Hello world")
    # expect(rendered).to match 'Миша'
  end

  # # Проверяем, что шаблон выводит балансы игроков
  # it 'renders player balances' do
  #   expect(rendered).to match '5 000 ₽'
  #   expect(rendered).to match '3 000 ₽'
  # end
  #
  # # Проверяем, что шаблон выводит игроков в нужном порядке
  # # (вообще говоря, тест избыточный, т.к. за порядок объектов в @users отвечает контроллер,
  # # но чтобы показать, как тестировать порядок элементов на странице, полезно)
  # it 'renders player names in right order' do
  #   expect(rendered).to match /Вадик.*Миша/m
  # end
end
