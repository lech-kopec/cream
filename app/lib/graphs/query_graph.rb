module Graph
  class QueryGraph

    def initialize(input)
      @input = input
      @resources = {}
      @attributes = []
      @outputs = []
      @selectors = []
      @collection = @input[:nodes].first[1]
      @root_object = @input[:nodes].first[1][:value].constantize

      traverse
      process_resources
      build_query
    end

    def traverse
      @input[:nodes].each_value do |node|
        #@resources.push node if node[:type] == 'Resource'
        if node[:type] == 'Resource'
          if @resources[node[:value]]
            @resources[node[:value]][:selectors].concat node[:selectors]
          else
            @resources[node[:value]] = node
          end
        end
        @attributes.push node if node[:type] == 'Attribute'
      end
    end

    def build_query
      query_parts = []
      apply_scopes
      @resources.each do |resource|
        query = @root_object.select( attribute_list_for(resource[0]) ).where(ticker: '11B')
          .joins(resource[1][:value].pluralize.underscore.to_sym)
        query = query.where(resource[1][:selector_string]) if resource[1][:selector_string]
        # add join with resource and selectors
        query_parts.push query
      end
      # perform union
      binding.irb
    end

    def apply_scopes
      @collection[:selectors].each do |selector|
        selector.each_pair do |key, value|
          if key == :scope
            @root_object = @root_object.send(value)
          end
        end
      end
    end

    def attribute_list_for(resource)
      list = ""
      @attributes.each do |attribute|
        parent = parents(attribute)[0]
        sql_alias = attribute[:value].gsub('.', '__')
        if parent[:value] == @collection[:value] || parent[:value] == resource
          list += "#{attribute[:value]} as #{sql_alias}, "
        else
          list += "null as #{sql_alias}, "
        end
      end
      return list.gsub(/, $/,'')
    end

    def process_resources
      @resources.each do |resource|
        selector_array = []
        resource[1][:selectors].each do |selector|
          # selector = {year: " in (2015), cash: " > 0"}
          local_selector = []
          selector.each_pair do |key, value|
            add_helper_attributes key #add fake attributes based on selector keys so they would available for later processing
            local_selector.push "#{key} #{value}"
          end
          selector_array.push local_selector.join(" AND ").gsub(/^/,'(').gsub(/$/,')')
        end
        resource[1][:selector_string] = selector_array.join(' OR ')
      end
    end

    def add_helper_attributes
    end

    private

    def parents(node)
      parents = []
      node[:inputs].each do |input|
        parents.push @input[:nodes][input]
      end
      return parents
    end

  end
end
