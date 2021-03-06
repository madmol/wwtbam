# (c) goodprogrammer.ru

require 'rails_helper'
# Наш собственный класс с вспомогательными методами
require 'support/my_spec_helper'

# Тестовый сценарий для игрового контроллера
# Самые важные здесь тесты:
#   1. на авторизацию (чтобы к чужим юзерам не утекли не их данные)
#   2. на четкое выполнение самых важных сценариев (требований) приложения
#   3. на передачу граничных/неправильных данных в попытке сломать контроллер
#
RSpec.describe GamesController, type: :controller do
  # обычный пользователь
  let(:user) { FactoryBot.create(:user) }
  # админ
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  # группа тестов для незалогиненного юзера (Анонимус)
  context 'Anon' do
    # из экшена show анона посылаем
    it 'kick from #show' do
      # вызываем экшен
      get :show, id: game_w_questions.id
      # проверяем ответ
      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен
      # отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    it 'kicks from #create' do
      post :create

      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен
      # отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    it 'kicks from #answer' do
      put :answer, id: game_w_questions.id

      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен
      # отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    it 'kicks from #take_money' do
      put :take_money, id: game_w_questions.id

      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен
      # отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    it 'kicks from #help' do
      put :help, id: game_w_questions.id

      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен
      # отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end
  end

  # Группа тестов на экшены контроллера, доступных залогиненным юзерам
  context 'Usual user' do
    # Перед каждым тестом в группе логиним юзера user с помощью спец. Devise
    # метода sign_in
    before(:each) { sign_in user }

    # Юзер может создать новую игру
    it 'creates game' do
      # Сперва накидаем вопросов, из чего собирать новую игру
      generate_questions(15)

      post :create
      game = assigns(:game) # вытаскиваем из контроллера поле @game

      # Проверяем состояние этой игры
      expect(game.finished?).to be false
      expect(game.user).to eq(user)
      # и редирект на страницу этой игры
      expect(response).to redirect_to(game_path(game))
      expect(flash[:notice]).to be
    end

    # Юзер видит свою игру
    it '#show game' do
      get :show, id: game_w_questions.id
      game = assigns(:game) # вытаскиваем из контроллера поле @game
      expect(game.finished?).to be false
      expect(game.user).to eq(user)

      expect(response.status).to eq(200) # должен быть ответ HTTP 200
      expect(response).to render_template('show') # и отрендерить шаблон show
    end

    # юзер отвечает на игру корректно - игра продолжается
    it 'answers correct' do
      # передаем параметр params[:letter]
      put :answer, id: game_w_questions.id,
          letter: game_w_questions.current_game_question.correct_answer_key
      game = assigns(:game)

      expect(game.finished?).to be false
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be_truthy # удачный ответ не заполняет flash
    end

    it 'answers incorrect' do
      game_w_questions.update_attribute(:current_level, 11)
      # передаем параметр params[:letter]
      put :answer, id: game_w_questions.id, letter: [*'a'..'c'].sample
      game = assigns(:game)

      expect(game.finished?).to be true
      expect(game.prize).to eq(32_000)
      expect(flash[:alert]).to be

      user.reload
      expect(response).to redirect_to(user_path(user))
      expect(user.balance).to eq(32_000)
    end

    # Тест на отработку "помощи зала"
    it 'uses audience help' do
      # Сперва проверяем что в подсказках текущего вопроса пусто
      expect(game_w_questions.current_game_question.help_hash[:audience_help])
        .not_to be
      expect(game_w_questions.audience_help_used).to be_falsey

      # Фигачим запрос в контроллен с нужным типом
      put :help, id: game_w_questions.id, help_type: :audience_help
      game = assigns(:game)

      # Проверяем, что игра не закончилась, что флажок установился, и подсказка
      # записалась
      expect(game.finished?).to be false
      expect(game.audience_help_used).to be true
      expect(game.current_game_question.help_hash[:audience_help]).to be
      expect(
        game.current_game_question.help_hash[:audience_help].keys
      ).to contain_exactly('a', 'b', 'c', 'd')
      expect(response).to redirect_to(game_path(game))
    end

    # Тест на отработку "50/50"
    it 'uses fifty_fifty_help' do
      # Сперва проверяем что в подсказках текущего вопроса пусто
      expect(
        game_w_questions.current_game_question.help_hash[:fifty_fifty]
      ).not_to be
      expect(game_w_questions.fifty_fifty_used).to be false

      # Фигачим запрос в контроллен с нужным типом
      put :help, id: game_w_questions.id, help_type: :fifty_fifty
      game = assigns(:game)

      # Проверяем, что игра не закончилась, что флажок установился, и подсказка
      # записалась
      expect(game.finished?).to be false
      expect(game.fifty_fifty_used).to be true
      expect(game.current_game_question.help_hash[:fifty_fifty]).to be_an Array
      expect(game.current_game_question.help_hash[:fifty_fifty].size).to eq(2)
      expect(game.current_game_question.help_hash[:fifty_fifty]).to include('d')
      expect(response).to redirect_to(game_path(game))
    end

    it "can't see other user game" do
      other_user_game_w_questions = FactoryBot.create(:game_with_questions)

      get :show, id: other_user_game_w_questions.id

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be
    end

    it 'takes money' do
      game_w_questions.update_attribute(:current_level, 2)

      put :take_money, id: game_w_questions.id
      game = assigns(:game)
      expect(game.finished?).to be true
      expect(game.prize).to eq(200)

      user.reload
      expect(user.balance).to eq(200)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to be
    end

    it "tries to create second game" do
      # Убедились что есть игра в работе
      expect(game_w_questions.finished?).to be false

      # Отправляем запрос на создание, убеждаемся что новых Game не создалось
      expect { post :create }.to change(Game, :count).by(0)

      game = assigns(:game) # вытаскиваем из контроллера поле @game
      expect(game).to be_nil

      # и редирект на страницу старой игры
      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).to be
    end
  end
end
