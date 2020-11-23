#  (c) goodprogrammer.ru
require 'game_help_generator'

# Игровой вопрос — модель, которая связывает игру и вопрос. При создании новой
# игры формируется массив из 15 игровых вопросов для конкретной игры.
class GameQuestion < ActiveRecord::Base

  belongs_to :game

  # вопрос из которого берется вся информация
  belongs_to :question

  # Создаем в этой модели виртуальные геттеры text, level, значения которых
  # автоматически берутся из связанной модели question
  delegate :text, :level, to: :question, allow_nil: true

  # Без игры и вопроса - игровой вопрос не имеет смысла
  validates :game, :question, presence: true

  # В полях a,b,c,d прячутся индексы ответов из объекта :game
  validates :a, :b, :c, :d, inclusion: {in: 1..4}

  # Автоматическая сериализация поля в базу (мы юзаем как обычный хэш,
  # а рельсы в базе хранят как строчку)
  serialize :help_hash, Hash

  # help_hash у нас имеет такой формат:
  # {
  #   При использовании подсказски остались варианты a и b
  #   fifty_fifty: ['a', 'b'],
  #
  #   Распределение голосов по вариантам a, b, c, d
  #   audience_help: {'a' => 42, 'c' => 37 ...},
  #
  #   Друг решил, что правильный ответ А (просто пишем текстом)
  #   friend_call: 'Василий Петрович считает, что правильный ответ A'
  # }
  #


  # ----- Основные методы для доступа к данным в шаблонах и контроллерах -----------

  # Возвращает хэш, отсортированный по ключам:
  # {'a' => 'Текст ответа Х', 'b' => 'Текст ответа У', ... }
  def variants
    {
      'a' => question.read_attribute("answer#{a}"),
      'b' => question.read_attribute("answer#{b}"),
      'c' => question.read_attribute("answer#{c}"),
      'd' => question.read_attribute("answer#{d}")
    }
  end

  # Возвращает истину, если переданная буква (строка или символ) содержит верный ответ
  def answer_correct?(letter)
    correct_answer_key == letter.to_s.downcase
  end

  # Ключ правильного ответа 'a', 'b', 'c', или 'd'
  def correct_answer_key
    {a => 'a', b => 'b', c => 'c', d => 'd'}[1]
  end

  # Текст правильного ответа
  def correct_answer
    variants[correct_answer_key]
  end

  # Добавляем в help_hash по ключю fifty_fifty - массив из двух вариантов:
  # правильный и случайный и сохраняем объект.
  def add_fifty_fifty
    self.help_hash[:fifty_fifty] = [
      correct_answer_key,
      (%w[a b c d] - [correct_answer_key]).sample
    ]
    save
  end

  # Генерируем в help_hash случайное распределение по вариантам и сохраняем объект
  def add_audience_help
    # Массив ключей
    keys_to_use = keys_to_use_in_help
    self.help_hash[:audience_help] =
      GameHelpGenerator.audience_distribution(keys_to_use, correct_answer_key)

    save
  end

  # Добавляем в help_hash подсказку друга и сохраняем объект
  def add_friend_call
    # Массив ключей
    keys_to_use = keys_to_use_in_help
    self.help_hash[:friend_call] =
      GameHelpGenerator.friend_call(keys_to_use, correct_answer_key)

    save
  end

  private

  # Рассчитываем какие ключи нам доступны в подсказках
  def keys_to_use_in_help
    keys_to_use = variants.keys
    # Учитываем наличие подсказки 50/50
    keys_to_use = help_hash[:fifty_fifty] if help_hash.has_key?(:fifty_fifty)
    keys_to_use
  end
end
