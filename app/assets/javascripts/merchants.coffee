#= require admin
#= require bootstrap/transition
#= require bootstrap/tooltip
#= require bootstrap/popover
#= require Chart
#= require Chart.Scatter
#= require select2

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

  $('.select2').select2
    theme: 'bootstrap'
