#= require admin
#= require bootstrap/transition
#= require bootstrap/modal

$.fn.extend
  removeOptions: ->
    @find("option:not(:first-child)").remove()

  appendOptions: (values) ->
    return unless values
    for value in values
      @append("<option value=\"#{value[1]}\">#{value[0]}</option>")

$(document).on 'ready page:load', ->
  $(".custom-service-dialog").modal()
