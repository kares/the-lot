class User < ActiveRecord::Base

  validates_presence_of :name

  alias_attribute :username, :name

  has_many :tasks

  #def self.by_name(name)
  #  where(:name => name).take || create!(:name => name)
  #end

  def self.auth(username, password = nil)
    user = where(:name => username).take
    return user if user && ( password.nil? || password == user[:password] )
  end

  def all_tasks
    tasks.to_a
  end

  def find_task(id)
    tasks.find_by!(id: id)
  end

end