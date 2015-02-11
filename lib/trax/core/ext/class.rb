class Class
  # def inherited(subclass, &blk)
  #   try(:super, subclass, &blk)
  #
  #   # try(:after_class_inherited, subclass, &blk)
  #
  #   # if(respond_to?(:after_inherited))
  #   #   after_class_inherited(subclass)
  #   #
  #   #   end
  #   # end
  #   # after_inherited
  # end

  # def after_class_inherited(child = nil, &blk)
  #   line_class = nil
  #   set_trace_func(lambda do |event, file, line, id, binding, classname|
  #     unless line_class
  #       # save the line of the inherited class entry
  #       line_class = line if event == 'class'
  #     else
  #       # check the end of inherited class
  #       if line == line_class && event == 'end'
  #         # if so, turn off the trace and call the block
  #         set_trace_func nil
  #         blk.call child
  #       end
  #     end
  #   end)
  # end

  def after_inherited(child = nil, &blk)
    line_class = nil
    set_trace_func(lambda do |event, file, line, id, binding, classname|
      unless line_class
        # save the line of the inherited class entry
        line_class = line if event == 'class'
      else
        # check the end of inherited class
        if line == line_class && event == 'end'
          # if so, turn off the trace and call the block

          set_trace_func nil
          blk.call child
        end
      end
    end)
  end
end
