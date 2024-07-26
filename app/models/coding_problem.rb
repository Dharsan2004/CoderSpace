class CodingProblem < ApplicationRecord

  searchkick

  has_one_attached :input_file
  has_one_attached :expected_output_file

  enum difficulty: { easy: 0, medium: 1, hard: 2 }

  # Many-to-many association
  has_many :solved_problems,dependent: :destroy
  has_many :users, through: :solved_problems

  validates :problem_name, presence: true
  validates :problem_statement, presence: true
  validates :sample_input, presence: true
  validates :sample_output, presence: true
  validates :difficulty, presence: true
  validates :topic, presence: true

  validate :validate_input_file
  validate :validate_expected_output_file

  # Callback to downcase the topic before saving
  before_save :downcase_topic

  private

  def downcase_topic
    self.topic = topic.downcase if topic.present?
  end

  def validate_input_file
    if input_file.attached?
      unless input_file.content_type == 'text/plain'
        errors.add(:input_file, 'must be a text file')
      end

      if input_file.blob.byte_size > 2.megabytes
        errors.add(:input_file, 'size must be less than 2MB')
      end
    else
      errors.add(:input_file, 'must be attached')
    end
  end

  def validate_expected_output_file
    if expected_output_file.attached?
      unless expected_output_file.content_type == 'text/plain'
        errors.add(:expected_output_file, 'must be a text file')
      end

      if expected_output_file.blob.byte_size > 2.megabytes
        errors.add(:expected_output_file, 'size must be less than 2MB')
      end
    else
      errors.add(:expected_output_file, 'must be attached')
    end
  end
end
