class CreateKanbanSystem < ActiveRecord::Migration[7.1]
  def change
    create_table :kanban_settings do |t|
      t.references :account, null: false, foreign_key: true
      t.jsonb :column_settings, default: []
      t.timestamps
    end

    unless column_exists?(:labels, :position)
      add_column :labels, :position, :integer, default: 0
      add_index :labels, :position
    end
  end
end
