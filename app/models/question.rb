#  (c) goodprogrammer.ru
#
# Вопрос — основная смысловая единица базы вопросов. Из вопросов разных уровней
# сложности формируются все игры.
class Question < ActiveRecord::Base

  QUESTION_LEVELS = (0..14).freeze

  # У вопроса обязательно должен быть уровень сложности. Это целое число
  # от 0 до 14.
  validates :level, presence: true, inclusion: {in: QUESTION_LEVELS}

  # Варианты ответов — это строки, по условиям игры, вариантов ответов всегда
  # должно быть 4. В первом всегда храним правильный.
  validates :text, presence: true, uniqueness: true, allow_blank: false

  # Варианты ответов (в первом всегда храним правильный)
  validates :answer1, :answer2, :answer3, :answer4, presence: true
end
