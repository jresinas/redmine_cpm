class CpmUserCapacity < ActiveRecord::Base
	belongs_to :user

  unloadable
  validates :capacity, :presence => true, numericality: { only_integer: true }, :inclusion => (0..100).step(5)
  validates :from_date,	:presence => true, 
  						:format => {:with => /^\d{4}-\d{2}-\d{2}/, :message => " tiene que ser una fecha válida" }
  validates :to_date, 	:presence => true, 
  						:format => {:with => /^\d{4}-\d{2}-\d{2}/, :message => " tiene que ser una fecha válida" }
=begin
  def get_capacity(i)
  	logger.info "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  	logger.info self.to_date
  	logger.info Date.today
  	today = Date.today

  	if today >= self.from_date && today <= self.to_date
  		"Hola"
  	end
  end
=end
end
