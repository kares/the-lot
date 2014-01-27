class Task < ActiveRecord::Base
  
  belongs_to :user

  def completed
    ! completed_at.nil?
  end

  def completed=(flag)
    update_attribute(:completed_at, flag ? Time.current : nil) unless new_record?
  end

  validates :name, presence: true

  validates :priority, numericality: {
      greater_than_or_equal_to: 0, less_than: 10, only_integer: true, allow_nil: true
  }

end