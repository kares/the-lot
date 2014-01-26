class Task < ActiveRecord::Base
  
  belongs_to :user

  def completed
    ! completed_at.nil?
  end

  def completed=(flag)
    update_attribute(:completed_at, flag ? Time.current : nil) unless new_record?
  end

end