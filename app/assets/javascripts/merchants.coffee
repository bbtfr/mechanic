#= require admin
#= require bootstrap/transition
#= require bootstrap/tooltip
#= require bootstrap/popover

$.fn.extend
  removeOptions: ->
    @find("option:not(:first-child)").remove()

  appendOptions: (values) ->
    return unless values
    for value in values
      @append("<option value=\"#{value[1]}\">#{value[0]}</option>")

$(document).on 'ready page:load', ->
  $('[data-toggle="popover"]').popover
    viewport:
      selector: 'body'
      padding: 30
