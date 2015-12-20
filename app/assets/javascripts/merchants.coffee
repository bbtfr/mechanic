#= require admin
#= require bootstrap/transition
#= require bootstrap/tooltip
#= require bootstrap/popover
#= require Chart
#= require Chart.Scatter
#= require select2
#= require select2_locale_zh-CN
#= require tinymce-jquery

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
    language: 'zh-CN'

  $('.tinymce').tinymce
    height: 300
    setup: window.tinymceSetup,
    content_style: 'body { font-size: 14px!important; }',
    plugins: 'autolink link textcolor image media lists table colorpicker'
    menubar: false
    toolbar: [
      'undo redo | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image table'
      'styleselect bold italic underline strikethrough | forecolor backcolor'
    ]
    table_class_list: [
      title: 'Default'
      value: ''
    ,
      title: 'Bootstrap'
      value: 'table table-hover'
    ]

$(document).on 'page:receive', ->
  tinymce.remove()
