class Task < ActiveRecord::Base
  
  belongs_to :user

  def completed?
    ! completed_at.nil?
  end
  alias_attribute :completed, :completed?

  def completed=(flag)
    update_attribute(:completed_at, flag ? Time.current : nil)
  end

end