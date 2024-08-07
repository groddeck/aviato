class AddWidgetDataToMessage < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :widget_data, :string
  end
end
