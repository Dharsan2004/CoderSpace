class User < ApplicationRecord
  has_secure_password
  has_one_attached :profile_image

  #many to many assocation
  has_many :solved_problems,dependent: :destroy
  has_many :coding_problems, through: :solved_problems

  validates :name, presence: true, length: { maximum: 30 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :college, presence: true
  validates :linkedin_link, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }

  validate :validate_profile_image

  private

  def validate_profile_image
    if profile_image.attached?
      if profile_image.blob.byte_size > 2.megabytes
        errors.add(:profile_image, 'size must be less than 2MB')
      end

      acceptable_types = ["image/jpeg", "image/png"]
      unless acceptable_types.include?(profile_image.content_type)
        errors.add(:profile_image, 'must be a JPEG or PNG')
      end
    else
      errors.add(:profile_image, 'must be attached')
    end
  end
end
