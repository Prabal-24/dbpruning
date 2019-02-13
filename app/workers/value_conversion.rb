module ValueConversions
  def values_generator(table)
    values = ""
    table.num_tuples.times do |i|
      tuple_values = table[i].map{|v| if v[1].is_a?(String) then "'#{v[1]}'" else "#{v[1]}" end}.join(',')
      if i == 0
        values = "(#{tuple_values})"
      else
        values = values + ",(#{tuple_values})"
      end
    end
    return values
  end
  def where_clause_generator(col_conditions)
    where_conditions = ""
    col_conditions.length.times do |i|
      condition = operator_case_condition(col_conditions[i])
      if i == 0
        where_conditions = "WHERE #{condition}"
      elsif col_conditions[i][4] == "OR"
        where_conditions = where_conditions + " OR #{condition}"
      else
        where_conditions = where_conditions + " AND #{condition}"
      end 
    end
    return where_conditions 
  end
  def operator_case_condition(condition_tuple)
    condition = ""
    case condition_tuple[1]
    when "<"||">"||"="||"<="||">="||"!="||"<>"||"IS"
      condition = condition_tuple[0] + " " + condition_tuple[1] + " " + condition_tuple[2]
    when "LIKE"
      condition = condition_tuple[0] + " " + condition_tuple[1] + " " + "'#{condition_tuple[2]}'"
    when "BETWEEN"
      condition = condition_tuple[0] + " " + condition_tuple[1] + " " + condition_tuple[2][0] + " AND " + condition_tuple[2][1]
    when "IN"||"NOT IN"
      values_array = condition_tuple[2].map{|v| if v.is_a?(String) then "'#{v}'" else "#{v}" end}.join(',')
      condition = condition_tuple[0] + " " + condition_tuple[1] + " " + "(#{values_array})"
    else
      condition = ""
    end
    return condition 
  end
end 