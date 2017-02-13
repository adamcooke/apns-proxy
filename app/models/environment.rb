# == Schema Information
#
# Table name: environments
#
#  id               :integer          not null, primary key
#  application_id   :integer
#  name             :string(255)
#  certificate      :text
#  created_at       :datetime
#  updated_at       :datetime
#  apns_environment :string(255)
#
# Indexes
#
#  index_environments_on_application_id  (application_id)
#

class Environment < ActiveRecord::Base

  APNS_ENVIRONMENTS = ['development', 'production']

  belongs_to :application
  has_many :auth_keys, :dependent => :destroy

  validates :name, :presence => true, :length => {:maximum => 50}
  validates :apns_environment, :inclusion => {:in => APNS_ENVIRONMENTS }
  validates :topic, :presence => true
  validates :certificate, :presence => true

  scope :asc, -> { order(:name) }

  def development?
    apns_environment == 'development'
  end

  def certificate_expiry_date
    if self.certificate
      @expiry ||= begin
        c = OpenSSL::X509::Certificate.new(self.certificate)
        c.not_after
      end
    end
  rescue OpenSSL::X509::CertificateError
  end

end
