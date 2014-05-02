module CPM
  class CpmDate
    unloadable

    def self.get_start_date(time_unit,index)
      case time_unit
        when 'week'
          date = Date.today + index.week
          start_date = date.beginning_of_week
        when 'month'
          date = Date.today + index.month
          start_date = date.beginning_of_month
      end
      start_date
    end

    def self.get_due_date(time_unit,index)
      case time_unit
        when 'week'
          date = Date.today + index.week
          due_date = date.end_of_week-2
        when 'month'
          date = Date.today + index.month
          due_date = date.end_of_month
      end
      due_date
    end
  end
end
