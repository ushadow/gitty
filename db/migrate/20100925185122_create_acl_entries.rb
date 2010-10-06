class CreateAclEntries < ActiveRecord::Migration
  def self.up
    create_table :acl_entries do |t|
      t.string :role, :length => 16, :null => false
      t.integer :subject_id, :null => false
      t.string :subject_type, :null => false, :length => 16
      t.integer :principal_id, :null => false
      t.string :principal_type, :null => false, :length => 16
      t.timestamps
    end
    
    add_index :acl_entries, [:principal_id, :principal_type, :subject_id,
        :subject_type], :null => false, :unique => true
    add_index :acl_entries, [:subject_id, :subject_type, :principal_id,
        :principal_type], :null => false, :unique => true
  end

  def self.down
    drop_table :acl_entries
  end
end