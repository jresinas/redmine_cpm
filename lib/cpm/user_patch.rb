require 'dispatcher' unless Rails::VERSION::MAJOR >= 3
# Patches Redmine's Issue dynamically.  Adds relationships
# Issue +has_one+ to Incident and ImprovementAction
module CPM
  unloadable
  module UserPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development

        has_many :cpm_user_capacity, :dependent => :destroy
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def get_capacity(type,i,projects)
        case type
          when 'week'
            date = Date.today + i.week
           
            start_day = date.beginning_of_week
            end_day = start_day+4.day
          when 'month'
            date = Date.today + i.month

            start_day = date.beginning_of_month
            end_day = start_day+(date.end_of_month).day
        end
        

        if projects.present?
          query = "from_date <= ? AND to_date >= ? AND project_id IN ("+projects.join(',')+")"
        else
          query = "from_date <= ? AND to_date >= ?"
        end

        suma = self.cpm_user_capacity.where(query, end_day+1, start_day).inject(0) { |sum, e| 
          # Min and max day for capacity calculation
          iday = [Date.parse(e.from_date.to_s),start_day].max
          eday = [Date.parse(e.to_date.to_s),end_day].min
          
          # Number of incurred and max days for capacity calculation
          ndays = (eday - iday + 1).to_f
          maxdays = (end_day - start_day + 1).to_f

          sum += (e.capacity * (ndays/maxdays)).to_i
        }

        suma
      end

      # Show tooltip message for the user row
      def get_tooltip(type,i,projects)
        case type
          when 'week'
            date = Date.today + i.week
           
            start_day = date.beginning_of_week
            end_day = start_day+4.day
          when 'month'
            date = Date.today + i.month

            start_day = date.beginning_of_month
            end_day = start_day+(date.end_of_month).day
        end

        if projects.present?
          query = "from_date <= ? AND to_date >= ? AND project_id IN ("+projects.join(',')+")"
        else
          query = "from_date <= ? AND to_date >= ?"
        end

        self.cpm_user_capacity.where(query, end_day+1, start_day).collect{|e| Project.find_by_id(e.project_id).name+": "+(e.capacity).to_s+"%. "+e.from_date.strftime('%d/%m/%y')+" - "+e.to_date.strftime('%d/%m/%y')}.join("<br>")
      end
      
=begin
      # Show tooltip message for the user row
      def get_tooltip(project)
        cpm = CpmUserCapacity.where('user_id = ?',self.id).collect{|e| Project.find_by_id(e.project_id).name+": "+(e.capacity).to_s+". "+e.from_date.strftime('%d/%m/%y')+" - "+e.to_date.strftime('%d/%m/%y')}.join("<br>")       
      end
=end
    end
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'user'
    User.send(:include, CPM::UserPatch)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'user'
    User.send(:include, CPM::UserPatch)
  end
end
