class Shoes
  module Swt
    class Progress
      def fraction=(value)
        @real.selection = (value*100).to_i unless @real.disposed?
      end
    end

    class TextBlockPainter

      # added the return statement on line 8
      def paintControl(paint_event)
        graphics_context = paint_event.gc
        gcs_reset graphics_context
        @text_layout.setText @dsl.text
        set_styles
        if @dsl.width
          @text_layout.setWidth @dsl.width
          return if @dsl.absolute_left.nil? || @dsl.margin_left.nil? || @dsl.absolute_top.nil? || @dsl.margin_top.nil?
          @text_layout.draw graphics_context, @dsl.absolute_left + @dsl.margin_left, @dsl.absolute_top + @dsl.margin_top
          if @dsl.cursor
            move_text_cursor
          else
            (@dsl.textcursor.remove; @dsl.textcursor = nil) if @dsl.textcursor
          end
        end
      end
    end
  end
end
