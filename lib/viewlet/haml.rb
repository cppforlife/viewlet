return unless defined?(Haml)

Haml::Parser.class_eval do
  # `%simple_viewlet` becomes `= viewlet(:simple)`
  # `%complex_viewlet` becomes `= viewlet(:complex) do |viewlet_0|`
  def push_with_viewlet_tag(node)
    if node.value[:name].try(:end_with?, "_viewlet")
      name = node.value[:name].gsub(/_viewlet$/, "")
      node = script(" viewlet(:#{name}) #{"do |#{viewlet_push}|" if block_opened?}")
    end
    push_without_viewlet_tag(node)
  end
  alias_method_chain :push, :viewlet_tag

  raise "Haml::Parser#close_script already defined" if private_method_defined?(:close_script)
  def close_script(node)
    viewlet_pop
  end

  # `prop "whatever"` becomes `- viewlet_0.prop "whatever"`
  def plain_with_viewlet_parent_tag(text, escape_html = nil)
    if viewlet_definition?
      silent_script(" #{viewlet_peek}.#{text}")
    else
      plain_without_viewlet_parent_tag(text, escape_html)
    end
  end
  alias_method_chain :plain, :viewlet_parent_tag

  private

  def viewlet_peek
    viewlet_names.last.try(:first)
  end

  # Viewlet variables can only be configured
  # on the next indentation level from viewlet call
  def viewlet_definition?
    if viewlet_names.last
      @line.tabs == viewlet_names.last.last + 1
    end
  end

  def viewlet_push
    viewlet_names.push(["viewlet_#{viewlet_names.size}", @line.tabs])
    viewlet_peek
  end

  def viewlet_pop
    viewlet_names.pop
  end

  def viewlet_names
    @viewlet_names ||= []
  end
end