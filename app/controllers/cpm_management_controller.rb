class CpmManagementController < ApplicationController
  unloadable
#  after_filter :flash_to_headers

  helper :cpm_management
=begin
  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Message'] = flash[:error] unless flash[:error].blank?
    response.headers['X-Message'] = flash[:notice] unless flash[:notice].blank?

    flash.discard
  end
=end

  # Main page for capacities search and management
  def show
    @filters = [['','default']] + ['users','projects','time_unit','time_unit_num'].collect{|f| [l(:"cpm.label_#{f}"),f]}
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

  # Add new capacity to an user for a project
  def add_capacity
  	@cpm_user_capacity = CpmUserCapacity.new(params[:cpm_user_capacity])

  	if @cpm_user_capacity.save
  		flash[:notice] = "Se ha guardado con exito"
  		redirect_to action: 'edit_form/'+(@cpm_user_capacity.user_id).to_s  #action:'assignments' #request.referer
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

  		redirect_to action: 'edit_form/'+(@cpm_user_capacity.user_id).to_s #'assignments'
  	end
  end

  # Capacity search result
  def planning
    if params[:users].present?
      @users = User.where("id IN (?)", params[:users])
    elsif params[:projects].present?
      @users = Project.where("id IN ("+params[:projects].join(',')+")").collect{|p| p.members.collect{|m| User.find_by_id(m.user_id)}}.flatten.uniq_by{|u| u.id}
    else
      @users = []
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

    # load pojects options
    ignored_projects = Setting.plugin_redmine_cpm['ignored_projects'] || [0]
    @projects_for_selection = Project.where("id NOT IN (?)", ignored_projects).collect{|p| [p.name,p.id]}

    @capacities = user.cpm_user_capacity.where('to_date >= ?', Date.today)

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
      flash[:notice] = "Se ha modificado con exito"
      redirect_to action:'edit_form/'+(cpm.user_id).to_s
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

      redirect_to action:'edit_form/'+(cpm.user_id).to_s
    end
  end

# Search filters
  def get_users_filter
    # load users options
    ignored_users = Setting.plugin_redmine_cpm['ignored_users'] || [0]
    options = User.where("id NOT IN (?)", ignored_users).collect{|u| "<option value='"+(u.id).to_s+"'>"+u.login+"</option>"}

    render text: l(:"cpm.label_users")+" <select name='users[]' class='filter_users' multiple>"+options.join('')+"</select>"
  end

  def get_projects_filter
    # load projects options
    ignored_projects = Setting.plugin_redmine_cpm['ignored_projects'] || [0]
    options = Project.where("id NOT IN (?)", ignored_projects).collect{|p| "<option value='"+(p.id).to_s+"'>"+p.name+"</option>"}

    render text: l(:"cpm.label_projects")+" <select name='projects[]' class='filter_projects' multiple>"+options.join('')+"</select>"
  end

  def get_time_unit_filter
    options = "<option value='week'>"+l(:"cpm.label_week")+"</option><option value='month'>"+l(:"cpm.label_month")+"</option>"

    render text: l(:"cpm.label_time_unit")+" <select name='time_unit' class='filter_time_unit'>"+options+"</select>";
  end

  def get_time_unit_num_filter
    render text: l(:"cpm.label_time_unit_num")+" <input name='time_unit_num' type='text' value='12' class='filter_time_unit_num' />"
  end
end
