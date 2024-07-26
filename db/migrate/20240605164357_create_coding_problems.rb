class CreateCodingProblems < ActiveRecord::Migration[7.1]
  def change
    create_table :coding_problems do |t|
      t.string :problem_name
      t.text :problem_statement
      t.text :sample_input
      t.text :sample_output
      t.integer :difficulty
      t.string :topic

      t.timestamps
    end
  end
end
