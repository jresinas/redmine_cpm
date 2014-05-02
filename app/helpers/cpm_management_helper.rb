module CpmManagementHelper
	# Controls CPM tab selected
	def selected_tab_class(tab)
    'selected' if case tab
                  when 'assignments'
                    params[:controller] == 'cpm_management' and params[:action] == 'assignments'
                  when 'show'
                    params[:controller] == 'cpm_management' and params[:action] == 'show'
               end
	end

	# Get week or month name for planning columns
	def get_column_name(type,index)
		case type
			when 'week'
				get_from_date(type,index)+" - "+get_to_date(type,index)
			when 'month'
				date = Date.today+index.month
				l(:"cpm.months.#{date.strftime('%B')}")+" "+date.strftime('%Y')
		end
	end

	def get_from_date(type,index)
		case type
			when 'week'
				date = Date.today.+index.week
				(date.beginning_of_week).strftime('%d/%m/%y')
			when 'month'
				date = Date.today+index.month
				(date.beginning_of_month).strftime('%d/%m/%y')
		end
	end

	def get_to_date(type,index)
		case type
			when 'week'
				date = Date.today.+index.week
				(date.end_of_week - 2.day).strftime('%d/%m/%y')
			when 'month'
				date = Date.today+index.month
				(date.end_of_month).strftime('%d/%m/%y')
		end
	end
end