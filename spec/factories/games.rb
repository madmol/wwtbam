# (c) goodprogrammer.ru
# Объявление фабрики для создания нужных в тестах объектов
#
# См. другие примеры на
#
# http://www.rubydoc.info/gems/factory_girl/file/GETTING_STARTED.md
FactoryBot.define do
  factory :game do
    # Связь с юзером
    association :user

    #  Игра только начата, создаем объект с нужными полями
    finished_at { nil }
    current_level { 0 }
    is_failed { false }
    prize { 0 }
    # ! эта фабрика создает объект Game без дочерних игровых вопросов,
    # в такую игру играть нельзя, расширим фабрику дочерней фабрикой!

    # фабрика наследует все поля от фабрики :game
    factory :game_with_questions do
      # Коллбэк: после того, как игра была создана (:build вызывается до
      # сохранения игры в базу), добавляем 15 вопросов разной сложности.
      after(:build) do |game|
        15.times do |level|
          # factory_bot create - дергает соотв. фабрику
          # Создаем явно вопрос с нужным уровнем
          question = create(:question, level: level)
          # Создаем связанные game_questions с нужной игрой и вопросом
          create(:game_question, game: game, question: question)
        end
      end
    end
  end
end
