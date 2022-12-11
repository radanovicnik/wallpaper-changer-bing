module ConsoleHelper
  # Format a record from recents for printing
  def self.recent_to_string(record)
    start_date = Date.strptime(record[:start_date], '%Y%m%d').strftime('%d.%m.%Y.')
    end_date = Date.strptime(record[:end_date], '%Y%m%d').strftime('%d.%m.%Y.')
    recent_str = <<~TEXT
      #{start_date} - #{end_date}
      Description: #{record[:copyright]}
      Filename: #{record[:file_name]}

    TEXT

    recent_str
  end

  # Print info about recent pictures
  def self.print_recents(history, args = [])
    opts = {
      :count => {:command => '-n'},
      :date => {:command => '-d'},
      :word => {:command => '-w'}
    }
  
    # Parse options
    %i(count date word).each do |opt|
      opt_index = args.find_index { |x| x == opts[opt][:command] }
  
      if !opt_index.nil? && args.size > opt_index + 1
        value = args[opt_index + 1]
  
        begin
          case opt
          when :count
            opts[opt][:value] = Integer(value)
  
          when :date
            case value
            when /^(\d{8})[-_](\d{8})$/
              opts[opt][:start] = Date.strptime($1, '%Y%m%d')
              opts[opt][:end] = Date.strptime($2, '%Y%m%d')
            when /^(\d{2}\.\d{2}.\d{4})[-_](\d{2}\.\d{2}.\d{4})$/
              opts[opt][:start] = Date.strptime($1, '%d.%m.%Y')
              opts[opt][:end] = Date.strptime($2, '%d.%m.%Y')
            when /^(\d{8})$/
              opts[opt][:start] = Date.strptime($1, '%Y%m%d')
            when /^(\d{2}\.\d{2}.\d{4})$/
              opts[opt][:start] = Date.strptime($1, '%d.%m.%Y')
            else
              raise ArgumentError.new('Wrong argument for date.')
            end
  
          when :word
            opts[opt][:value] = args[opt_index + 1]
          end
  
        rescue ArgumentError => e
          STDERR.puts "Option #{opts[:date][:command]} (#{opt}) requires a valid format. You gave: #{value}"
          exit false
        rescue StandardError => e
          STDERR.puts "Wrong input.\n[#{e.class}] #{e.message} - #{e.backtrace[0]}"
          exit false
        end
      end
    end

    # Apply each option

    unless opts[:date][:start].nil?
      history.filter! do |record|
        opts[:date][:start] <= Date.strptime(record[:start_date], '%Y%m%d')
      end
    end
  
    unless opts[:date][:end].nil?
      history.filter! do |record|
        Date.strptime(record[:start_date], '%Y%m%d') <= opts[:date][:end]
      end
    end
  
    unless opts[:word][:value].nil?
      history.filter! do |record|
        %i(copyright file_name).any? do |key|
          record[key].downcase.include? opts[:word][:value]
        end
      end
    end
  
    history = history.last(opts[:count][:value]) unless opts[:count][:value].nil?
  
    # Print the final results
    puts unless history.empty?
    history.reverse_each do |record|
      puts recent_to_string(record)
    end
  end

  # Print program help text
  def self.print_help
    puts <<~TEXT
      Program for updating wallpapers on GNOME desktops, fetches daily pictures from Bing.

      Normal use: To update your wallpaper, just call the program without any arguments.

      Additional (call with these arguments):

        recent - show information about recently downloaded pictures

          Options:
            -n NUMBER - get only a NUMBER of last records
            -d DATE_START-DATE_END - get only the records which were valid from DATE_START 
                and to DATE_END. Dates are given in one of these formats: 
                YYYYMMDD or DD.MM.YYYY (both dates have to be in the same format) 
            -w SEARCH_WORD - get only the records containing this SEARCH_WORD (letter case 
                isn't important). If SEARCH_WORD consists of multiple actual words (example: 
                "azure coast") they must be written between paranthesis.
          
          If none of the options are given, "recent" will print all records!

        help - show this help message

    TEXT
  end

  # Print the program's title text
  def self.print_title
    puts "\n### Wallpaper downloader - Bing ###\n\n"
  end
end
