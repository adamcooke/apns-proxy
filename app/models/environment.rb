# == Schema Information
#
# Table name: environments
#
#  id             :integer          not null, primary key
#  application_id :integer
#  name           :string(255)
#  certificate    :text
#  created_at     :datetime
#  updated_at     :datetime
#

class Environment < ActiveRecord::Base
  
  belongs_to :application
  
  validates :name, :presence => true, :length => {:maximum => 50}
  validates :certificate, :presence => true
  
  scope :asc, -> { order(:name) }
  
end
