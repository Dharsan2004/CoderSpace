module ApplicationHelper



  def bootstrap_class_for(flash_type)
    case flash_type
    when 'success'
      'success'
    when 'error'
      'danger'
    when 'alert'
      'warning'
    when 'notice'
      'info'
    else
      flash_type.to_s
    end
  end

   def difficulty_color(difficulty)


    case difficulty
    when "Easy"
      'bg-success'
    when "Medium"
      'bg-warning'
    when "Hard"
      'bg-danger'
    else
      ''
    end
  end

end
