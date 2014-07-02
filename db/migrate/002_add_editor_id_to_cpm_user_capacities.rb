class AddEditorIdToCpmUserCapacities < ActiveRecord::Migration
  def self.up
    add_column :cpm_user_capacities, :editor_id, :integer, :null => false
  end

  def self.down
    remove_column :cpm_user_capacities, :editor_id
  end
end