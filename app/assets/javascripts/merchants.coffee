#= require admin

$.fn.extend
  removeOptions: ->
    @find("option:not(:first-child)").remove()

  appendOptions: (values) ->
    return unless values
    for value in values
      @append("<option value=\"#{value[1]}\">#{value[0]}</option>")
