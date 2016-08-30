module CounterUpdatable
  def update_counters_by_case_result!(automation_case_result)
    case automation_case_result.result
    when 'pass'
      self.pass += 1
    when 'failed'
      self.failed += 1
    when 'warning'
      self.warning += 1
    end

    self.not_run -= 1
    self.save
  end
end