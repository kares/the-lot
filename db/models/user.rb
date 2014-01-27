class User < ActiveRecord::Base

  validates_presence_of :name

  alias_attribute :username, :name

  has_many :tasks, -> { order('priority ASC, created_at ASC') }

  #def self.by_name(name)
  #  where(:name => name).take || create!(:name => name)
  #end

  def self.auth(username, password = nil)
    user = where(:name => username).take
    return user if user && ( password.blank? || password == user[:password] )
  end

  def all_tasks
    tasks.to_a
  end

  def find_task(id)
    tasks.find_by!(id: id)
  end

end