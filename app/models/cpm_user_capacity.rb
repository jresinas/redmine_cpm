class CpmUserCapacity < ActiveRecord::Base
	belongs_to :user

  unloadable
  validates :capacity, :presence => true, numericality: { only_integer: true }, :inclusion => (0..100).step(5)
  validates :from_date,	:presence => true, 
  						:format => {:with => /^\d{4}-\d{2}-\d{2}/, :message => " tiene que ser una fecha válida" }
  validates :to_date, 	:presence => true, 
  						:format => {:with => /^\d{4}-\d{2}-\d{2}/, :message => " tiene que ser una fecha válida" }

end
