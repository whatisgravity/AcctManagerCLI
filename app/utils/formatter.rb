class Formatter
  
  # Format the result.
  #
  # @param result the sql query result
  # @return the result with formatted date
  def self.format(result)
    if result
      result.each do |row|
        row.keys.each do |key|
          format_date(row, key)
          format_nil(row, key)
        end
      end
    end
  end

  # Format the date.
  #
  # @param hash the sql query result
  # @param key the key
  # @result the result with formatted date
  def self.format_date(hash, key)
  	if hash[key].kind_of? Date
  		hash[key] = hash[key].strftime('%Y-%m-%d')
  	end
  end
  private_class_method :format_date

  # Format nil value.
  #
  # @param hash the sql query result
  # @param key the key
  # @return the result with formatted nil
  def self.format_nil(hash, key)
  	if hash[key].nil?
  		hash[key] = 'N/A'
  	end
  end
  private_class_method :format_nil
end
