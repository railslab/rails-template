module SimpleFormHelper
  # simple_form with bootstrap horizontal layout
  def horizontal_form_for(resource, options = {}, &block)
    options ||= {}
    options[:html] ||= {}
    # append form-horizontal class
    options[:html][:class] = [options[:html][:class], 'form-horizontal'].compact.join ' '
    options[:wrapper] = :horizontal_form
    # map inputs to horizontal
    options[:wrapper_mappings] = {
      check_boxes: :horizontal_radio_and_checkboxes,
      radio_buttons: :horizontal_radio_and_checkboxes,
      file: :horizontal_file_input,
      boolean: :horizontal_boolean
    }
    simple_form_for(resource, options, &block)
  end
end
