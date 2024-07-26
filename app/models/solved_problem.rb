class SolvedProblem < ApplicationRecord
  belongs_to :user
  belongs_to :coding_problem
end
