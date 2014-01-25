class User < ActiveRecord::Base

  validates_presence_of :name

  has_many :tasks

  @@default_user = nil
  def self.default
    @@default_user ||= begin
      User.new('default')
    end
  end

  #def self.by_name(name)
  #  where(:name => name).take || create!(:name => name)
  #end

  def all_tasks
    tasks.all
  end

  def find_task(id)
    tasks.find_by!(id: id)
  end

end