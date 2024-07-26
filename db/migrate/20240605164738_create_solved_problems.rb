class CreateSolvedProblems < ActiveRecord::Migration[7.1]
  def change
    create_table :solved_problems do |t|
      t.references :user, null: false, foreign_key: true
      t.references :coding_problem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
