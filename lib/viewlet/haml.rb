Haml::Parser.class_eval do
  # `%simple_viewlet` becomes `= viewlet(:simple)`
  # `%complex_viewlet` becomes `= viewlet(:complex) do |viewlet_0|`
  def push_with_viewlet_tag(node)
    if node.value[:name].try(:end_with?, "_viewlet")
      node = build_viewlet_node(node)
    end
    push_without_viewlet_tag(node)
  end
  alias_method_chain :push, :viewlet_tag

  raise "Haml::Parser#close_script already defined" if private_method_defined?(:close_script)
  def close_script(node)
    viewlet_pop
  end

  # `- prop "whatever"` becomes `- viewlet_0.prop "whatever"`
  def silent_script_with_viewlet_parent_tag(text)
    if viewlet_definition?
      text = "- #{viewlet_peek}.#{text.gsub(/^\-\s*/, "")}"
    end
    silent_script_without_viewlet_parent_tag(text)
  end
  alias_method_chain :silent_script, :viewlet_parent_tag

  # `prop "whatever"` becomes `- viewlet_0.prop "whatever"`
  def plain_with_viewlet_parent_tag(text, escape_html=nil)
    if viewlet_definition?
      silent_script_without_viewlet_parent_tag(" #{viewlet_peek}.#{text}")
    else
      plain_without_viewlet_parent_tag(text, escape_html)
    end
  end
  alias_method_chain :plain, :viewlet_parent_tag

  private

  def build_viewlet_node(node)
    name = node.value[:name].gsub(/_viewlet$/, "")
    attrs = attributes_string(node.value[:attributes_hashes])
    block = "do |#{viewlet_push}|" if block_opened?
    script(" viewlet(:#{name} #{attrs}) #{block}")
  end

  def attributes_string(attributes_hashes)
    if attributes_hashes.empty?
      attributes_hashes = ""
    elsif attributes_hashes.size == 1
      attributes_hashes = ", #{attributes_hashes.first}"
    else
      attributes_hashes = ", (#{attributes_hashes.join(").merge(")})"
    end
  end

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