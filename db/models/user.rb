class User < ActiveRecord::Base

  validates_presence_of :name

  @@default_user = nil

  def self.default
    @@default_user ||= begin
      User.new('default')
    end
  end

  def self.by_name(name)
    where(:name => name).first || create!(:name => name)
  end

end