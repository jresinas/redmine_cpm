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
				l(:"cpm.label_week_n", :n => index+1)
				date = Date.today.+index.week
				startw = date.beginning_of_week
				endw = date.end_of_week - 2.day
				startw.strftime('%d/%m/%y')+" - "+endw.strftime('%d/%m/%y')
			when 'month'
				date = Date.today+index.month
				l(:"cpm.months.#{date.strftime('%B')}")+" "+date.strftime('%Y')
		end
	end
end