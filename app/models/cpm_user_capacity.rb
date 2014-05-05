class CpmUserCapacity < ActiveRecord::Base
	belongs_to :user

#  before_save :process_dates

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

  # get the beginning of day for "from_date" and the end of the day for "to_date"
#  def process_dates
    #zone = User.current.preference.others[:time_zone]
#    zone = ActiveSupport::TimeZone.new("Madrid")
    #self.from_date = (self.from_date).beginning_of_day #change({:hour=>0,:min=>0,:sec=>0})
    #self.to_date = (self.to_date).end_of_day #change({:hour=>21,:min=>59,:sec=>59})
#    self.from_date = (self.from_date).in_time_zone(zone).beginning_of_day+1.minute
#    self.to_date = (self.to_date).in_time_zone(zone).end_of_day
#  end

  # send a notice if user's total capacity on a day is higher than 100
  def check_capacity
    result = true

    user = User.find_by_id(self.user_id)
    days = (Date.parse(self.to_date.to_s) - Date.parse(self.from_date.to_s)).to_i

begin
    (0..days).each do |i|
      date = self.from_date + i.day

      if get_total_capacity(self.user_id, date) > 100    
        result = false
      end

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
