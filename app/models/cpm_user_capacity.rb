class CpmUserCapacity < ActiveRecord::Base
	belongs_to :user

  unloadable
  validates :capacity, :presence => true, numericality: { only_integer: true }, :inclusion => (0..100).step(5)
  validates :from_date,	:presence => true, 
  						:format => {:with => /^\d{4}-\d{2}-\d{2}/, :message => " tiene que ser una fecha válida" }
  validates :to_date, 	:presence => true, 
  						:format => {:with => /^\d{4}-\d{2}-\d{2}/, :message => " tiene que ser una fecha válida" }
  validate :to_date_after_from_date

  def to_date_after_from_date
    if from_date.present? && to_date.present?
      errors.add(:to_date, :msg_to_date_after_from_date) if to_date < from_date
    end
  end

  # send a notice if user's total capacity on a day is higher than 100
  def check_capacity
    result = true

    user = User.find_by_id(self.user_id)
    days = (self.to_date).day - (self.from_date).day

    (0..days).each do |i|
      date = self.from_date + i.day

      if get_total_capacity(self.user_id, date) > 100    
        result = false
      end

    end

    result
  end

  def get_total_capacity(user_id, date)
    CpmUserCapacity.where("user_id = ? AND from_date <= ? AND to_date >= ?", user_id, date, date).inject(0) { |sum, e| 
      sum += e.capacity  
    }
  end
end
