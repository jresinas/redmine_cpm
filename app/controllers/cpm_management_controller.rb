class CpmManagementController < ApplicationController
  unloadable

  helper :cpm_management

  # Main page for capacities search and management
  def show
    @filters = [['','default']] + ['users','groups','projects','time_unit','time_unit_num'].collect{|f| [l(:"cpm.label_#{f}"),f]}
  end

  # Form for add capacities to users
  def assignments
    # load users options
    ignored_users = Setting.plugin_redmine_cpm['ignored_users'] || [0]
    @users_for_selection = User.where("id NOT IN (?)", ignored_users).collect{|u| [u.login,u.id]}

    # load pojects options
    ignored_projects = Setting.plugin_redmine_cpm['ignored_projects'] || [0]
    @projects_for_selection = Project.where("id NOT IN (?)", ignored_projects).collect{|p| [p.name,p.id]}

    @cpm_user_capacity = CpmUserCapacity.new
  end

  def add_capacity_assignment
    add_capacity
    redirect_to action: 'assignments'
  end

  def add_capacity_modal
    add_capacity
    redirect_to action:'edit_form', 
                    user_id:@cpm_user_capacity.user_id, 
                    from_date:params[:start_date], 
                    to_date:params[:due_date], 
                    projects:params[:projects]
  end

  # Add new capacity to an user for a project
  def add_capacity
  	@cpm_user_capacity = CpmUserCapacity.new(params[:cpm_user_capacity])

  	if @cpm_user_capacity.save
  		flash[:notice] = l(:"cpm.msg_save_success")  
    else
  		error_msg = ""
  		
      # get errors list
  		@cpm_user_capacity.errors.full_messages.each do |msg|
  			if error_msg != ""
  				error_msg << "<br>"
  			end
	  		error_msg << msg
	  	end

	  	flash[:error] = error_msg
    end
  end

  # Capacity search result
  def planning
    @users = []

    # add users specified by users filter
    if params[:users].present?
      @users += User.where("id IN (?)", params[:users])
    end

    # add users specified by groups filter
    if params[:groups].present?
      @users += Group.where("id IN (?)", params[:groups]).collect{|g| g.users}.flatten
    end

    # join users
    @users = @users.uniq

    # get users specified by project if there are not using filter for users or groups
    if params[:projects].present? && !params[:users].present? && !params[:groups].present?
      projects = Project.where("id IN ("+params[:projects].join(',')+")")

      members = projects.collect{|p| p.members.collect{|m| m.user_id}}.flatten
      time_entries = projects.collect{|p| p.time_entries.collect{|te| te.user_id}}.flatten

      @users = User.where("id IN (?)", (members+time_entries).uniq)
    end

    @projects = params[:projects]
    @time_unit = params[:time_unit] || 'week'

    if params[:time_unit_num].present?
      @time_unit_num = params[:time_unit_num].to_i
    else
      @time_unit_num = 12
    end

    render layout: false
  end

  # Capacity edit form
  def edit_form
    user = User.find_by_id(params[:user_id])
    
    from_date = Date.strptime(params[:from_date], "%d/%m/%y")
    to_date = Date.strptime(params[:to_date], "%d/%m/%y")

    # load pojects options
    ignored_projects = Setting.plugin_redmine_cpm['ignored_projects'] || [0]
    @projects_for_selection = Project.where("id NOT IN (?)", ignored_projects).collect{|p| [p.name,p.id]}

    @capacities = user.get_range_capacities(from_date,to_date,params[:projects])
    #user.cpm_user_capacity.where('to_date >= ?', Date.today)

    @cpm_user_capacity = CpmUserCapacity.new
    @cpm_user_capacity.user_id = params[:user_id]

    render layout: false
  end

  # Edit a capacity for an user
  def edit_capacity
    cpm = CpmUserCapacity.find_by_id(params[:id])
    data = params[:cpm_user_capacity]
    data[:project_id] = data[:project_id].to_i

    if cpm.update_attributes(data)
      flash[:notice] = l(:"cpm.msg_edit_success")
    else
      error_msg = ""
      
      # get errors list
      cpm.errors.full_messages.each do |msg|
        if error_msg != ""
          error_msg << "<br>"
        end
        error_msg << msg
      end

      flash[:error] = error_msg
    end

    if !cpm.check_capacity
      flash[:warning] = l(:"cpm.msg_capacity_higher_than_100")
    end

    redirect_to action:'edit_form', 
                user_id:cpm.user_id, 
                from_date:params[:start_date], 
                to_date:params[:due_date], 
                projects:params[:projects]
  end

# Search filters
  def get_users_filter
    # load users options
    ignored_users = Setting.plugin_redmine_cpm['ignored_users'] || [0]
    options = User.where("id NOT IN (?)", ignored_users).collect{|u| "<option value='"+(u.id).to_s+"'>"+u.login+"</option>"}

    render text: l(:"cpm.label_users")+" <select name='users[]' class='filter_users' size=10 multiple>"+options.join('')+"</select>"
  end

  def get_groups_filter
    # load users options
    options = Group.all.collect{|g| "<option value='"+(g.id).to_s+"'>"+g.name+"</option>"}

    render text: l(:"cpm.label_groups")+" <select name='groups[]' class='filter_groups' size=10 multiple>"+options.join('')+"</select>"
  end

  def get_projects_filter
    # load projects options
    ignored_projects = Setting.plugin_redmine_cpm['ignored_projects'] || [0]
    options = Project.where("id NOT IN (?)", ignored_projects).collect{|p| "<option value='"+(p.id).to_s+"'>"+p.name+"</option>"}

    render text: l(:"cpm.label_projects")+" <select name='projects[]' class='filter_projects' size=10 multiple>"+options.join('')+"</select>"
  end

  def get_time_unit_filter
    options = "<option value='week'>"+l(:"cpm.label_week")+"</option><option value='month'>"+l(:"cpm.label_month")+"</option>"

    render text: l(:"cpm.label_time_unit")+" <select name='time_unit' class='filter_time_unit'>"+options+"</select>";
  end

  def get_time_unit_num_filter
    render text: l(:"cpm.label_time_unit_num")+" <input name='time_unit_num' type='text' value='12' class='filter_time_unit_num' />"
  end
end
